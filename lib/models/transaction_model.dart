import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String type; // 'Income' or 'Expense'
  final String category;
  final DateTime date;
  final String description;
  final bool isSms; // New field to identify SMS transactions

  TransactionModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.description,
    this.isSms = false,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      type: data['type'] ?? 'Expense',
      category: data['category'] ?? 'General',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'] ?? '',
      isSms: data['isSms'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': Timestamp.fromDate(date),
      'description': description,
      'isSms': isSms,
    };
  }

  List<String> toCsvRow() {
    return [
      date.toIso8601String(),
      title,
      category,
      type,
      amount.toString(),
      description,
      isSms ? "Yes" : "No",
    ];
  }
}
