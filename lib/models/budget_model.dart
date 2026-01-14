
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  final String id;
  final String userId;
  final String category;
  final double amount;
  final String period; // 'Monthly', 'Weekly', 'Custom'
  final DateTime startDate;
  final DateTime endDate;
  final bool autoRepeat;
  final bool notifyExceed;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.amount,
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.autoRepeat,
    required this.notifyExceed,
  });

  factory BudgetModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BudgetModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      category: data['category'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      period: data['period'] ?? 'Monthly',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      autoRepeat: data['autoRepeat'] ?? false,
      notifyExceed: data['notifyExceed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'category': category,
      'amount': amount,
      'period': period,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'autoRepeat': autoRepeat,
      'notifyExceed': notifyExceed,
    };
  }
}
