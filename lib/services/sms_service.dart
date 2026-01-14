import 'package:expenxo/models/transaction_model.dart';
import 'package:expenxo/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SmsService {
  final SmsQuery _query = SmsQuery();

  Future<void> init() async {
    // 1. Request Permissions
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
      if (!status.isGranted) {
        debugPrint("SMS Permission denied");
        return;
      }
    }

    // 2. Sync Messages
    await _syncMessages();
  }

  Future<void> _syncMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool isPremium = prefs.getBool('isPremium') ?? false;

      if (!isPremium) {
        debugPrint("SMS Sync skipped: Not a Premium User");
        return;
      }

      final int lastSyncTime = prefs.getInt('lastSmsSyncTime') ?? 0;
      final DateTime lastSyncDate = DateTime.fromMillisecondsSinceEpoch(
        lastSyncTime,
      );

      // Fetch inbox messages
      debugPrint("Fetching SMS...");
      List<SmsMessage> messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        // count: 50, // Limit to recent 50 to avoid slow load if filtering locally
        // Sorting or filtering API might be limited, handling locally
      );

      debugPrint("Fetched ${messages.length} messages");

      int newMaxTime = lastSyncTime;
      int addedCount = 0;

      for (final message in messages) {
        if (message.date == null || message.body == null) continue;

        // Filter by date (only new messages)
        // Adding a small buffer or strict check.
        if (message.date!.isAfter(lastSyncDate)) {
          if (message.date!.millisecondsSinceEpoch > newMaxTime) {
            newMaxTime = message.date!.millisecondsSinceEpoch;
          }

          if (_processSms(message)) {
            addedCount++;
          }
        }
      }

      // Update sync time
      if (newMaxTime > lastSyncTime) {
        await prefs.setInt('lastSmsSyncTime', newMaxTime);
      }

      if (addedCount > 0) {
        debugPrint("Sync complete: Added $addedCount new transaction(s)");
      }
    } catch (e) {
      debugPrint("Error syncing SMS: $e");
    }
  }

  bool _processSms(SmsMessage message) {
    final String body = message.body ?? "";

    if (!_isTransactionalSms(body)) return false;

    final double? amount = _extractAmount(body);
    if (amount == null) return false;

    final DateTime date = message.date ?? DateTime.now();

    // Determine Type (Income/Expense)
    String type = 'Expense'; // Default
    final lower = body.toLowerCase();

    if (lower.contains('credited') ||
        lower.contains('deposited') ||
        lower.contains('received')) {
      type = 'Income';
    } else if (lower.contains('transferred')) {
      // "Transferred to" = Expense, "Transferred from" = Income
      if (lower.contains('from')) {
        type = 'Income';
      }
    }

    // Attempt to extract merchant/payee/sender
    String merchant = "Unknown";

    // Body heuristic for merchant
    if (type == 'Expense') {
      if (lower.contains("to ")) {
        final parts = body.split(RegExp(r'to\s', caseSensitive: false));
        if (parts.length > 1) {
          merchant = parts[1].split(RegExp(r'\s|on|at'))[0];
        }
      } else if (lower.contains("at ")) {
        final parts = body.split(RegExp(r'at\s', caseSensitive: false));
        if (parts.length > 1) {
          merchant = parts[1].split(RegExp(r'\s|on'))[0];
        }
      } else if (lower.contains("paid ")) {
        final parts = body.split(RegExp(r'paid\s', caseSensitive: false));
        if (parts.length > 1) {
          merchant = parts[1].split(RegExp(r'\s|to|on'))[0];
        }
      } else if (lower.contains("spent on ")) {
        final parts = body.split(RegExp(r'spent on\s', caseSensitive: false));
        if (parts.length > 1) {
          merchant = parts[1].split(RegExp(r'\s|at'))[0];
        }
      }
    } else {
      // Income heuristic
      if (lower.contains("from ")) {
        final parts = body.split(RegExp(r'from\s', caseSensitive: false));
        if (parts.length > 1) {
          merchant = parts[1].split(RegExp(r'\s|at|on'))[0];
        }
      } else if (lower.contains("received ")) {
        final parts = body.split(RegExp(r'received\s', caseSensitive: false));
        if (parts.length > 1) {
          merchant = parts[1].split(RegExp(r'\s|from|at'))[0];
        }
      }
    }

    // Clean merchant name
    merchant = merchant.replaceAll(RegExp(r'[^\w\s]'), '').trim();
    if (merchant.isEmpty || merchant == "Unknown") {
      // Fallback: Check sender name/address
      merchant = message.address ?? "Bank Transaction";
    }

    // Create Transaction
    final transaction = TransactionModel(
      id: '',
      userId: '', // Service handles user ID
      title: merchant,
      type: type,
      amount: amount,
      category: 'Others',
      date: date,
      description: body,
      isSms: true,
    );

    final firestoreService = FirestoreService();
    // Fire and forget, or await? Awaiting ensures completion but might slow down loop.
    // Ideally we batch, but addTransaction is single.
    firestoreService.addTransaction(
      transaction,
    ); // Not awaiting to speed up loop
    return true;
  }

  bool _isTransactionalSms(String body) {
    final lower = body.toLowerCase();
    // Common Banking and Transactional keywords
    return (lower.contains("debited") ||
        lower.contains("spent") ||
        lower.contains("paid") ||
        lower.contains("sent") ||
        lower.contains("withdrawal") ||
        lower.contains("purchase") ||
        lower.contains("transferred") ||
        lower.contains("credited") ||
        lower.contains("deposited") ||
        lower.contains("received") ||
        lower.contains("txn") ||
        lower.contains("upi") ||
        lower.contains("bank") ||
        lower.contains("amount") ||
        lower.contains("vpa") ||
        lower.contains("a/c"));
  }

  double? _extractAmount(String body) {
    // Regex for money: Rs. 100, INR 100, Rs 100.00, Amt: 100
    // Regex 1: Prefix Currency (Rs. 100, INR 100)
    final RegExp regex1 = RegExp(
      r"(?:Rs\.?|INR|₹)\s*([\d,]+(?:\.\d{1,2})?)",
      caseSensitive: false,
    );
    // Regex 2: Suffix Currency (100 Rs)
    final RegExp regex2 = RegExp(
      r"([\d,]+(?:\.\d{1,2})?)\s*(?:Rs\.?|INR|₹)",
      caseSensitive: false,
    );
    // Regex 3: Contextual (credited with 100, Amt: 100)
    final RegExp regex3 = RegExp(
      r"(?:credited|debited|sent|paid|received|spent|transferred|amt|amount)\s+(?:with|of|by|:)?\s*([0-9,]+(?:\.[0-9]{1,2})?)",
      caseSensitive: false,
    );

    var match = regex1.firstMatch(body);
    match ??= regex2.firstMatch(body);
    match ??= regex3.firstMatch(body);

    if (match != null) {
      String cleanAmount = match.group(1)!.replaceAll(',', '');
      return double.tryParse(cleanAmount);
    }
    return null;
  }
}
