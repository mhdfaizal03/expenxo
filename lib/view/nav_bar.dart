import 'dart:ui' as ui;
import 'package:expenxo/utils/constands/colors.dart';
import 'package:expenxo/view/responsive/responsive_layout.dart';
import 'package:expenxo/view/screens/nav_items/ai_assistant_page.dart';
import 'package:expenxo/view/screens/nav_items/analytics_page.dart';
import 'package:expenxo/view/screens/nav_items/budget_planner_page.dart';
import 'package:expenxo/view/screens/nav_items/home_screen.dart';
import 'package:expenxo/view/screens/nav_items/settings_page.dart';
import 'package:expenxo/view/screens/nav_items/transaction_page.dart';
import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> navItems = [
    {"name": "Home", "icon": "assets/icons/home.png", "page": const HomePage()},
    {
      "name": "Transactions",
      "icon": "assets/icons/transaction.png",
      "page": TransactionsPage(),
    },
    {
      "name": "Analytics",
      "icon": "assets/icons/analytics.png",
      "page": AnalyticsPage(),
    },
    {
      "name": "Budget",
      "icon": "assets/icons/budget.png",
      "page": BudgetPlannerPage(),
    },
    {
      "name": "ChatAI",
      "icon": "assets/icons/ai.png",
      "page": AIAssistantPage(),
    },
    {
      "name": "Settings",
      "icon": "assets/icons/settings.png",
      "page": SettingsPage(),
    },
  ];

  void _onNavTap(int index) {
    setState(() => selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobileScaffold: _buildMobileScaffold(),
      desktopScaffold: _buildDesktopScaffold(),
    );
  }

  Widget _buildMobileScaffold() {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: navItems.map((e) => e["page"] as Widget).toList(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          height: 65,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50)),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(navItems.length, (index) {
                    final item = navItems[index];
                    return _buildNavItem(index, item);
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopScaffold() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 250,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 30),
                // Logo or Title
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Image.asset('assets/logo1.png', height: 40, width: 40),
                      SizedBox(width: 12),
                      Text(
                        'Expenxo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Nav Items
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: navigationItems.length,
                    separatorBuilder: (c, i) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = navigationItems[index];
                      final isSelected = selectedIndex == index;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _onNavTap(index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.mainColor.withOpacity(0.1)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  item["icon"],
                                  height: 24,
                                  color: isSelected
                                      ? AppColors.mainColor
                                      : Theme.of(
                                          context,
                                        ).iconTheme.color?.withOpacity(0.5),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  item["name"],
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? AppColors.mainColor
                                        : Theme.of(
                                            context,
                                          ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: IndexedStack(
              index: selectedIndex,
              children: navItems.map((e) => e["page"] as Widget).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Helper for Mobile Item to reduce DRY
  Widget _buildNavItem(int index, Map<String, dynamic> item) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () => _onNavTap(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            item["icon"],
            height: 24,
            color: isSelected
                ? AppColors.mainColor
                : Theme.of(context).iconTheme.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 4),
          Text(
            item["name"],
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? AppColors.mainColor
                  : Theme.of(context).textTheme.bodySmall?.color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // Getter for navigation items to ensure consistency
  List<Map<String, dynamic>> get navigationItems => navItems;
}
