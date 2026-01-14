import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String
  userId; // null or empty for default categories if mixed, but better to copy defaults to user or have a separate "defaults" list.
  // Actually, simplest approach: App has hardcoded defaults. User categories are stored in Firestore.
  // UI merges [Defaults] + [Firestore User Categories].

  final String name;
  final int iconCode; // Store icon as integer codePoint to save in DB
  final String colorHex; // Store color as hex string
  final String type; // 'Income' or 'Expense'

  CategoryModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.iconCode,
    required this.colorHex,
    required this.type,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      iconCode: data['iconCode'] ?? 58835, // Default icon (e.g., category)
      colorHex: data['colorHex'] ?? 'FF000000',
      type: data['type'] ?? 'Expense',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'iconCode': iconCode,
      'colorHex': colorHex,
      'type': type,
    };
  }
}
