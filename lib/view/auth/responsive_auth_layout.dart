import 'package:flutter/material.dart';
import 'package:expenxo/utils/constands/colors.dart';

class ResponsiveAuthLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final String subtitle;

  const ResponsiveAuthLayout({
    super.key,
    required this.child,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Breakpoint: 800px width for desktop split view
    bool isDesktop = size.width > 800;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          // Desktop Left Side (Branding/Hero)
          if (isDesktop)
            Expanded(
              flex: 5,
              child: Container(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[900]
                    : AppColors.mainColor.withOpacity(0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 500, // Fixed height for hero stack
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Illustration/Logo
                          Positioned(
                            top: 0,
                            bottom: 50,
                            left: 0,
                            right: 0,
                            child: Image.asset(
                              Theme.of(context).brightness == Brightness.light
                                  ? 'assets/logo3.png'
                                  : 'assets/logo2.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          // Text Overlay
                          Positioned(
                            bottom: 20,
                            left: 40,
                            right: 40,
                            child: Column(
                              children: [
                                Text(
                                  "Expenxo",
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyLarge?.color,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Track expenses, manage budgets, and achieve financial freedom.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Right Side (Form)
          Expanded(
            flex: 4,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 480,
                    ), // Slightly wider
                    decoration: isDesktop
                        ? BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          )
                        : null, // No card decoration on mobile
                    padding: isDesktop
                        ? const EdgeInsets.all(40)
                        : const EdgeInsets.all(0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Mobile Logo
                        if (!isDesktop) ...[
                          Center(
                            child: SizedBox(
                              height: 80,
                              child: Image.asset(
                                Theme.of(context).brightness == Brightness.light
                                    ? 'assets/logo3.png'
                                    : 'assets/logo2.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],

                        // Header
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                          textAlign: isDesktop
                              ? TextAlign.left
                              : TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                          textAlign: isDesktop
                              ? TextAlign.left
                              : TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // Form Content
                        child,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
