import 'package:currency_picker/currency_picker.dart';
import 'package:expenxo/providers/preferences_provider.dart';
import 'package:expenxo/services/firestore_service.dart';
import 'package:expenxo/view/auth/login_page.dart';
import 'package:expenxo/view/screens/notification_page.dart';
import 'package:expenxo/view/screens/settings/edit_profile_page.dart';
import 'package:expenxo/view/screens/settings/help_support_page.dart';
import 'package:expenxo/view/screens/settings/privacy_settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<PreferencesProvider>(
      builder: (context, prefs, child) {
        return SingleChildScrollView(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15.0,
                    vertical: 10,
                  ),
                  child: SizedBox(
                    height: 40,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Settings',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          IconButton(
                            icon: Icon(
                              Icons.notifications_none,
                              color: Theme.of(context).iconTheme.color,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NotificationPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: Flex(
                    direction: Axis.vertical,
                    children: [
                      // User Profile Header
                      _buildProfileHeader(context),
                      const SizedBox(height: 16),

                      // Notifications Section
                      _buildSection(
                        context,
                        title: "Notifications",
                        children: [
                          _buildSwitchTile(
                            context,
                            icon: Icons.notifications_none_outlined,
                            title: "General Notifications",
                            subtitle:
                                "Receive updates about new features and promotions.",
                            value: prefs.generalNotifications,
                            onChanged: (val) =>
                                prefs.setGeneralNotifications(val),
                          ),
                          _buildSwitchTile(
                            context,
                            icon: Icons.list_alt_outlined,
                            title: "Transaction Alerts",
                            subtitle: "Get notified for every transaction.",
                            value: prefs.transactionAlerts,
                            onChanged: (val) => prefs.setTransactionAlerts(val),
                          ),
                          _buildSwitchTile(
                            context,
                            icon: Icons.notifications_active_outlined,
                            title: "Budget Reminders",
                            subtitle:
                                "Alerts for approaching or exceeded budgets.",
                            value: prefs.budgetReminders,
                            onChanged: (val) => prefs.setBudgetReminders(val),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // App Preferences Section
                      _buildSection(
                        context,
                        title: "App Preferences",
                        children: [
                          _buildThemeTile(context, prefs),
                          _buildNavigationTile(
                            context,
                            icon: Icons.attach_money,
                            title: "Currency",
                            trailingText:
                                "${prefs.currencyCode} (${prefs.currencySymbol})",
                            onTap: () {
                              showCurrencyPicker(
                                context: context,
                                showFlag: true,
                                showCurrencyName: true,
                                showCurrencyCode: true,
                                onSelect: (Currency currency) {
                                  prefs.setCurrency(
                                    currency.symbol,
                                    currency.code,
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Account & Privacy Section
                      _buildSection(
                        context,
                        title: "Account & Privacy",
                        children: [
                          _buildNavigationTile(
                            context,
                            icon: Icons.lock_outline,
                            title: "Privacy Settings",
                            subtitle:
                                "Manage your data and privacy preferences.",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const PrivacySettingsPage(),
                                ),
                              );
                            },
                          ),
                          _buildNavigationTile(
                            context,
                            icon: Icons.logout,
                            title: "Logout",
                            subtitle: "Sign out from your account.",
                            titleColor: Colors.redAccent,
                            iconColor: Colors.redAccent,
                            onTap: () => _showLogoutDialog(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Help & Support Section
                      _buildSection(
                        context,
                        title: "Help & Support",
                        children: [
                          _buildNavigationTile(
                            context,
                            icon: Icons.help_outline,
                            title: "FAQ & Support",
                            subtitle: "Find answers and contact us.",
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HelpSupportPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- UI Component Helpers ---

  Widget _buildProfileHeader(BuildContext context) {
    return FutureBuilder<String>(
      future: Provider.of<FirestoreService>(
        context,
        listen: false,
      ).getUserName(),
      builder: (context, snapshot) {
        final name = snapshot.data ?? 'User';
        final email = FirebaseAuth.instance.currentUser?.email ?? 'No Email';

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const EditProfilePage()),
            ).then((_) => setState(() {})); // Refresh on return
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Theme.of(
                    context,
                  ).primaryColor.withOpacity(0.1),
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  Icons.edit,
                  size: 20,
                  color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          "Logout?",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        content: Text(
          "Are you sure you want to log out?",
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00C9A7), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF00C9A7),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context, PreferencesProvider prefs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          const Icon(Icons.palette_outlined, color: Color(0xFF00C9A7)),
          const SizedBox(width: 16),
          Text(
            "Theme",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const Spacer(),
          // Light Mode
          GestureDetector(
            onTap: () => prefs.toggleTheme(false),
            child: Row(
              children: [
                Radio<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: prefs.themeMode,
                  activeColor: const Color(0xFF00C9A7),
                  onChanged: (val) => prefs.toggleTheme(false),
                ),
                Text(
                  "Light",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
          // Dark Mode
          GestureDetector(
            onTap: () => prefs.toggleTheme(true),
            child: Row(
              children: [
                Radio<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: prefs.themeMode,
                  activeColor: const Color(0xFF00C9A7),
                  onChanged: (val) => prefs.toggleTheme(true),
                ),
                Text(
                  "Dark",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    Color? titleColor,
    Color iconColor = const Color(0xFF00C9A7),
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color:
                          titleColor ??
                          Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
