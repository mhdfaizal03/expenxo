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
        final parts = body.split("to ");
        if (parts.length > 1) {
          merchant = parts[1].split(" ")[0];
        }
      } else if (lower.contains("at ")) {
        final parts = body.split("at ");
        if (parts.length > 1) {
          merchant = parts[1].split(" ")[0];
        }
      } else if (lower.contains("paid ")) {
        final parts = body.split("paid ");
        if (parts.length > 1) {
          merchant = parts[1].split(" ")[0];
        }
      }
    } else {
      // Income heuristic
      if (lower.contains("from ")) {
        final parts = body.split("from ");
        if (parts.length > 1) {
          merchant = parts[1].split(" ")[0];
        }
      } else if (lower.contains("received ")) {
        final parts = body.split("received ");
        if (parts.length > 1) {
          merchant = parts[1].split(" ")[0];
        }
      }
    }

    // Clean merchant name
    merchant = merchant.replaceAll(RegExp(r'[^\w\s]'), '').trim();
    if (merchant.isEmpty) merchant = "Unknown Transaction";

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
    // Common Banking keywords
    return (lower.contains("debited") ||
        lower.contains("spent") ||
        lower.contains("paid") ||
        lower.contains("sent") ||
        lower.contains("withdrawal") ||
        lower.contains("purchase") ||
        lower.contains("transferred") ||
        lower.contains("credited") ||
        lower.contains("deposited") ||
        lower.contains("received"));
  }

  double? _extractAmount(String body) {
    // Regex for money: Rs. 100, INR 100, Rs 100.00
    // Improved regex to capture comma separated values
    // Regex 1: Prefix Currency (Rs. 100)
    final RegExp regex1 = RegExp(
      r"(?:Rs\.?|INR)\s*([\d,]+(?:\.\d{2})?)",
      caseSensitive: false,
    );
    // Regex 2: Suffix Currency (100 Rs)
    final RegExp regex2 = RegExp(
      r"([\d,]+(?:\.\d{2})?)\s*(?:Rs\.?|INR)",
      caseSensitive: false,
    );
    // Regex 3: Contextual (credited with 100)
    final RegExp regex3 = RegExp(
      r"(?:credited|debited|sent|paid|received|spent|transferred)\s+(?:with|of|by)?\s*([0-9,]+(?:\.[0-9]+)?)",
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
