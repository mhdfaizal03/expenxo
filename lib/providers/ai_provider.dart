import 'package:expenxo/models/transaction_model.dart';
import 'package:expenxo/services/ai_service.dart';
import 'package:expenxo/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();
}

class AIProvider extends ChangeNotifier {
  final AIService _aiService = AIService();
  final FirestoreService _firestoreService;

  List<ChatMessage> _messages = [
    ChatMessage(
      text: "Hi there! Welcome to Expenxo. How can I help you today?",
      isUser: false,
    ),
  ];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  AIProvider(this._firestoreService);

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Add User Message
    _messages.add(ChatMessage(text: text, isUser: true));
    _isLoading = true;
    notifyListeners();

    try {
      // Temporary Placeholder Logic (as requested)
      await Future.delayed(const Duration(seconds: 1)); // Simulate thinking

      const responseText =
          "Hi, This is an upcoming feature of Expenxo app. Please wait for the update, and keep maintaining your Savings!";

      /* 
      // Real AI Logic (Disabled for now)
      // 2. Prepare Context (Fetch recent stats)
      final transactions = await _firestoreService.getTransactionsOnce(); 
      final contextData = _generateFinancialContext(transactions);

      // 3. Get AI Response
      final responseText = await _aiService.sendMessage(text, contextData);
      */

      // 4. Add AI Message
      _messages.add(ChatMessage(text: responseText, isUser: false));
    } catch (e) {
      _messages.add(
        ChatMessage(text: "Sorry, I encountered an error: $e", isUser: false),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _generateFinancialContext(List<TransactionModel> transactions) {
    if (transactions.isEmpty) return "No transaction data available yet.";

    double totalIncome = 0;
    double totalExpense = 0;
    Map<String, double> categorySpend = {};

    final now = DateTime.now();
    final thisMonth = transactions.where(
      (t) => t.date.year == now.year && t.date.month == now.month,
    );

    for (var t in thisMonth) {
      if (t.type == 'Income') {
        totalIncome += t.amount;
      } else {
        totalExpense += t.amount;
        categorySpend[t.category] = (categorySpend[t.category] ?? 0) + t.amount;
      }
    }

    final buffer = StringBuffer();
    buffer.writeln(
      "Financial Context for ${DateFormat('MMMM yyyy').format(now)}:",
    );
    buffer.writeln("- Total Income: \$${totalIncome.toStringAsFixed(2)}");
    buffer.writeln("- Total Expense: \$${totalExpense.toStringAsFixed(2)}");
    buffer.writeln(
      "- Net Savings: \$${(totalIncome - totalExpense).toStringAsFixed(2)}",
    );
    buffer.writeln("- Top Spending Categories:");

    var sortedCategories = categorySpend.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    for (var entry in sortedCategories.take(5)) {
      // Top 5
      buffer.writeln("  * ${entry.key}: \$${entry.value.toStringAsFixed(2)}");
    }

    return buffer.toString();
  }
}
