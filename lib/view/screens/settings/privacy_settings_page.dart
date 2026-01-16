import 'package:expenxo/utils/constands/colors.dart';
import 'package:expenxo/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:expenxo/services/firestore_service.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  String _lastSyncStr = "Never";
  bool _isSyncing = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadSyncStatus();
  }

  Future<void> _loadSyncStatus() async {
    final firestoreService = Provider.of<FirestoreService>(
      context,
      listen: false,
    );
    final lastSync = await firestoreService.getLastSyncTime();
    if (lastSync != null) {
      final dateTime = DateTime.parse(lastSync);
      setState(() {
        _lastSyncStr = DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
      });
    }
  }

  Future<void> _handleManualSync() async {
    setState(() => _isSyncing = true);
    try {
      final firestoreService = Provider.of<FirestoreService>(
        context,
        listen: false,
      );
      await firestoreService.manualSync();
      await _loadSyncStatus();
      if (mounted) {
        ToastUtil.showToast(context, "Data synced successfully!");
      }
    } catch (e) {
      if (mounted) {
        ToastUtil.showToast(context, "Sync failed: $e", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _handleExport() async {
    setState(() => _isExporting = true);
    try {
      final firestoreService = Provider.of<FirestoreService>(
        context,
        listen: false,
      );
      await firestoreService.exportTransactionsToCsv();
    } catch (e) {
      if (mounted) {
        ToastUtil.showToast(context, "Export failed: $e", isError: true);
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Privacy & Data",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              "Data Sync",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: Text(
              "Last Synced: $_lastSyncStr\nYour data is synced securely with Firebase Cloud.",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
                height: 1.4,
              ),
            ),
            trailing: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: const Icon(Icons.sync, color: AppColors.mainColor),
                    onPressed: _handleManualSync,
                  ),
          ),
          const Divider(),
          _buildInfoTile(
            context,
            "Local Backup",
            "All transactions are cached locally on your device for offline access.",
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: _isExporting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download, color: AppColors.mainColor),
            title: Text(
              "Export Data (CSV)",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            subtitle: Text(
              "Download your transaction history.",
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
            onTap: _isExporting ? null : _handleExport,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.error.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // Show delete confirmation
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Delete Account Data?"),
                    content: const Text(
                      "This will permanently delete all your transactions and budgets. This action cannot be undone.",
                    ),
                    actions: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                      TextButton(
                        child: const Text(
                          "Delete",
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () async {
                          Navigator.pop(ctx);
                          try {
                            // Show loading indicator
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );

                            await Provider.of<FirestoreService>(
                              context,
                              listen: false,
                            ).deleteAllData();

                            // Hide loading
                            Navigator.pop(context);

                            ToastUtil.showToast(
                              context,
                              "All data deleted successfully!",
                              isError: true,
                            );

                            _loadSyncStatus(); // Refresh status
                          } catch (e) {
                            Navigator.pop(context); // Hide loading
                            ToastUtil.showToast(
                              context,
                              "Error deleting data: $e",
                              isError: true,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                "Delete All Data",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(BuildContext context, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodySmall?.color,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
