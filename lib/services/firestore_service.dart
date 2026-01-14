import 'package:shared_preferences/shared_preferences.dart';
import 'package:expenxo/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expenxo/models/budget_model.dart';
import 'package:expenxo/models/category_model.dart';
import 'package:expenxo/models/notification_model.dart';
import 'package:expenxo/models/transaction_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // --- User ---
  Future<String> getUserName() async {
    if (_userId == null) return 'User';
    try {
      final doc = await _firestore.collection('users').doc(_userId).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data() as Map<String, dynamic>;
        return data['name'] ?? 'User';
      }
      return 'User';
    } catch (e) {
      print("Error fetching user name: $e");
      return 'User';
    }
  }

  Future<void> updateUserName(String name) async {
    if (_userId == null) return;
    try {
      await _firestore.collection('users').doc(_userId).update({'name': name});
    } catch (e) {
      print("Error updating user name: $e");
      rethrow;
    }
  }

  // --- Transactions ---

  final NotificationService _notificationService = NotificationService();

  // Add Transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .add(transaction.toMap());

      // Trigger Smart Checks
      await _checkSmartNotifications(transaction);
    } catch (e) {
      print("Error adding transaction: $e");
      rethrow;
    }
  }

  // Get Transactions Stream
  Stream<List<TransactionModel>> getTransactions() {
    if (_userId == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .toList();
        });
  }

  // Get Transactions Once (Future)
  Future<List<TransactionModel>> getTransactionsOnce() async {
    if (_userId == null) return [];
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print("Error fetching transactions once: $e");
      return [];
    }
  }

  // Delete Transaction
  Future<void> deleteTransaction(String transactionId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }

  // --- Budgets ---

  // Add Budget
  Future<void> addBudget(BudgetModel budget) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('budgets')
          .add(budget.toMap());
    } catch (e) {
      print("Error adding budget: $e");
      rethrow;
    }
  }

  // Get Budgets Stream
  Stream<List<BudgetModel>> getBudgets() {
    if (_userId == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('budgets')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => BudgetModel.fromFirestore(doc))
              .toList();
        });
  }

  // Delete Budget
  Future<void> deleteBudget(String budgetId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('budgets')
        .doc(budgetId)
        .delete();
  }

  // --- Categories ---

  // Add Category
  Future<void> addCategory(CategoryModel category) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('categories')
          .add(category.toMap());
    } catch (e) {
      print("Error adding category: $e");
      rethrow;
    }
  }

  // Get Categories Stream
  Stream<List<CategoryModel>> getCategories() {
    if (_userId == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('categories')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => CategoryModel.fromFirestore(doc))
              .toList();
        });
  }

  // Delete Category
  Future<void> deleteCategory(String categoryId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('categories')
        .doc(categoryId)
        .delete();
  }
  // --- Notifications ---

  // Add Notification
  Future<void> addNotification(NotificationModel notification) async {
    if (_userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('notifications')
          .add(notification.toMap());
    } catch (e) {
      print("Error adding notification: $e");
    }
  }

  // Get Notifications Stream
  Stream<List<NotificationModel>> getNotifications() {
    if (_userId == null) return Stream.value([]);
    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList();
        });
  }

  // Mark Notification as Read
  Future<void> markNotificationAsRead(String notificationId) async {
    if (_userId == null) return;
    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Clear All Notifications
  Future<void> clearAllNotifications() async {
    if (_userId == null) return;
    final batch = _firestore.batch();
    final snapshots = await _firestore
        .collection('users')
        .doc(_userId)
        .collection('notifications')
        .get();

    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // --- Smart Notifications Logic ---

  Future<void> _checkSmartNotifications(TransactionModel newTransaction) async {
    if (_userId == null) return;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final allTransactions = await getTransactionsOnce();

    // Filter for this month
    final monthTransactions = allTransactions
        .where(
          (t) => t.date.isAfter(startOfMonth) && t.date.isBefore(endOfMonth),
        )
        .toList();

    // 1. Check Income vs Expense
    double totalIncome = 0;
    double totalExpense = 0;
    for (var t in monthTransactions) {
      if (t.type == 'Income')
        totalIncome += t.amount;
      else
        totalExpense += t.amount;
    }

    if (totalExpense > totalIncome && totalIncome > 0) {
      // Prevent duplicate alerts logic could go here
      const title = "Warning: Expenses Exceed Income";
      const body =
          "Your total expenses for this month have surpassed your income. Review your spending!";

      _notificationService.showLocalNotification(title: title, body: body);
      addNotification(
        NotificationModel(
          id: '',
          title: title,
          body: body,
          timestamp: DateTime.now(),
          type: 'alert',
        ),
      );
    }

    // 2. Check Budget for Category
    if (newTransaction.type == 'Expense') {
      final category = newTransaction.category;

      final prefs = await SharedPreferences.getInstance();
      final currencySymbol = prefs.getString('currencySymbol') ?? '\$';

      // Get budgets for this category
      final budgetsSnapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('budgets')
          .where('category', isEqualTo: category)
          .get();

      final budgets = budgetsSnapshot.docs
          .map((d) => BudgetModel.fromFirestore(d))
          .toList();

      if (budgets.isNotEmpty) {
        // Calculate total spend for this category
        double categorySpend = 0;
        for (var t in monthTransactions) {
          if (t.type == 'Expense' && t.category == category) {
            categorySpend += t.amount;
          }
        }

        for (var budget in budgets) {
          if (categorySpend > budget.amount) {
            final title = "Budget Exceeded: $category";
            final body =
                "You've spent $currencySymbol${categorySpend.toStringAsFixed(1)} on $category, which is over your budget of $currencySymbol${budget.amount.toStringAsFixed(1)}.";

            _notificationService.showLocalNotification(
              title: title,
              body: body,
            );

            addNotification(
              NotificationModel(
                id: '',
                title: title,
                body: body,
                timestamp: DateTime.now(),
                type: 'alert',
              ),
            );
          }
        }
      }
    }
  }

  // --- Data Management ---

  Future<void> deleteAllData() async {
    if (_userId == null) return;

    try {
      // 1. Delete Transactions
      final tSnap = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('transactions')
          .get();
      for (var doc in tSnap.docs) {
        await doc.reference.delete();
      }

      // 2. Delete Budgets
      final bSnap = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('budgets')
          .get();
      for (var doc in bSnap.docs) {
        await doc.reference.delete();
      }

      // 3. Delete Categories
      final cSnap = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('categories')
          .get();
      for (var doc in cSnap.docs) {
        await doc.reference.delete();
      }

      // 4. Delete Notifications
      await clearAllNotifications();

      // 5. Reset SMS Sync
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('lastSmsSyncTime');
    } catch (e) {
      print("Error deleting all data: $e");
      rethrow;
    }
  }
}
