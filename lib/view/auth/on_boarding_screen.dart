import 'package:expenxo/utils/constands/colors.dart';
import 'package:expenxo/view/auth/login_page.dart';
import 'package:flutter/material.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> pageList = [
    {
      "image": "assets/selection.png",
      "title": "Track expenses easily",
      "subtitle":
          "Effortlessly log your daily spending and keep a clear overview of where your money goes.",
    },
    {
      "image": "assets/selection.png",
      "title": "Smart AI insights & budgeting",
      "subtitle":
          "Let AI analyze your habits, suggest budgets, and help you save smarter.",
    },
    {
      "image": "assets/selection.png",
      "title": "Secure Cloud Sync",
      "subtitle":
          "Your financial data is safe, secure, and accessible across all your devices with Firebase.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// 🔹 Skip Button
              _currentIndex == pageList.length - 1
                  ? SizedBox()
                  : Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          _pageController.jumpToPage(pageList.length - 1);
                        },
                        child: const Text("Skip"),
                      ),
                    ),

              /// 🔹 PageView
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pageList.length,
                  onPageChanged: (index) {
                    setState(() => _currentIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final item = pageList[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(item["image"]!, height: size.height * 0.3),
                        const SizedBox(height: 30),
                        Text(
                          item["title"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            item["subtitle"]!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              /// 🔹 Page Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      pageList.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        height: 8,
                        width: _currentIndex == index ? 20 : 8,
                        decoration: BoxDecoration(
                          color: _currentIndex == index
                              ? AppColors.mainColor
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// 🔹 Continue Button
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: MaterialButton(
                      textColor: Colors.white,
                      color: AppColors.mainColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10),
                      ),
                      onPressed: () {
                        if (_currentIndex == pageList.length - 1) {
                          // Navigate to Login
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                            (route) => false,
                          );
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Text(
                        _currentIndex == pageList.length - 1
                            ? "Get Started"
                            : "Next",
                        style: TextStyle(fontSize: 19),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
