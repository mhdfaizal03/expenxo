import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Toggle states
  bool _generalNotifications = true;
  bool _transactionAlerts = true;
  bool _budgetReminders = false;
  String _selectedTheme = 'Light';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 10,
              ),
              child: Container(
                height: 40,
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        icon: const Icon(
                          Icons.notifications_none,
                          color: Colors.black,
                        ),
                        onPressed: () {},
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
                  _buildProfileHeader(),
                  const SizedBox(height: 16),

                  // Notifications Section
                  _buildSection(
                    title: "Notifications",
                    children: [
                      _buildSwitchTile(
                        icon: Icons.notifications_none_outlined,
                        title: "General Notifications",
                        subtitle:
                            "Receive updates about new features and promotions.",
                        value: _generalNotifications,
                        onChanged: (val) =>
                            setState(() => _generalNotifications = val),
                      ),
                      _buildSwitchTile(
                        icon: Icons.list_alt_outlined,
                        title: "Transaction Alerts",
                        subtitle: "Get notified for every transaction.",
                        value: _transactionAlerts,
                        onChanged: (val) =>
                            setState(() => _transactionAlerts = val),
                      ),
                      _buildSwitchTile(
                        icon: Icons.notifications_active_outlined,
                        title: "Budget Reminders",
                        subtitle: "Alerts for approaching or exceeded budgets.",
                        value: _budgetReminders,
                        onChanged: (val) =>
                            setState(() => _budgetReminders = val),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // App Preferences Section
                  _buildSection(
                    title: "App Preferences",
                    children: [
                      _buildThemeTile(),
                      _buildNavigationTile(
                        icon: Icons.attach_money,
                        title: "Currency",
                        trailingText: "USD",
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Account & Privacy Section
                  _buildSection(
                    title: "Account & Privacy",
                    children: [
                      _buildNavigationTile(
                        icon: Icons.cloud_outlined,
                        title: "Data Backup & Sync",
                        subtitle: "Securely back up your data to the cloud.",
                      ),
                      _buildNavigationTile(
                        icon: Icons.lock_outline,
                        title: "Privacy Settings",
                        subtitle: "Manage your data and privacy preferences.",
                      ),
                      _buildNavigationTile(
                        icon: Icons.logout,
                        title: "Logout",
                        subtitle: "Sign out from your account.",
                        titleColor: Colors.redAccent,
                        iconColor: Colors.redAccent,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Help & Support Section
                  _buildSection(
                    title: "Help & Support",
                    children: [
                      _buildNavigationTile(
                        icon: Icons.help_outline,
                        title: "FAQ",
                        subtitle: "Find answers to common questions.",
                      ),
                      _buildNavigationTile(
                        icon: Icons.mail_outline,
                        title: "Contact Support",
                        subtitle: "Get in touch with our support team.",
                      ),
                      _buildNavigationTile(
                        icon: Icons.chat_bubble_outline,
                        title: "Send Feedback",
                        subtitle: "Share your suggestions and ideas.",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // --- UI Component Helpers ---

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?u=alex',
            ), // Replace with local asset
          ),
          const SizedBox(width: 16),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Alex Johnson",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "alex.j@example.com",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
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
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
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

  Widget _buildThemeTile() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          const Icon(Icons.palette_outlined, color: Color(0xFF00C9A7)),
          const SizedBox(width: 16),
          const Text("Theme", style: TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Radio<String>(
            value: 'Light',
            groupValue: _selectedTheme,
            activeColor: const Color(0xFF00C9A7),
            onChanged: (val) => setState(() => _selectedTheme = val!),
          ),
          const Text("Light", style: TextStyle(fontSize: 12)),
          Radio<String>(
            value: 'Dark',
            groupValue: _selectedTheme,
            activeColor: const Color(0xFF00C9A7),
            onChanged: null, // Disabled as per "Coming Soon"
          ),
          const Text(
            "Dark (Coming Soon)",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    Color titleColor = Colors.black,
    Color iconColor = const Color(0xFF00C9A7),
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: () {},
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
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                ],
              ),
            ),
            if (trailingText != null)
              Text(trailingText, style: const TextStyle(color: Colors.grey)),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }
}
