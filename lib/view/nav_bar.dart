import 'package:expenxo/utils/constands/colors.dart';
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
  late final PageController _pageController;
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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    _pageController.jumpToPage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        itemCount: navItems.length,
        physics: ClampingScrollPhysics(),
        onPageChanged: (index) {
          setState(() => selectedIndex = index);
        },
        itemBuilder: (context, index) {
          return navItems[index]["page"];
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),

        child: Container(
          margin: EdgeInsets.only(bottom: 15),
          height: 65,
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                color: Theme.of(context).shadowColor.withOpacity(0.1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(navItems.length, (index) {
              final item = navItems[index];
              final isSelected = selectedIndex == index;

              return GestureDetector(
                // behavior: HitTestBehavior.opaque,
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
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? AppColors.mainColor
                            : Theme.of(context).textTheme.bodySmall?.color,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
