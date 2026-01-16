import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileScaffold;
  final Widget desktopScaffold;

  const ResponsiveLayout({
    super.key,
    required this.mobileScaffold,
    required this.desktopScaffold,
  });

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 900;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 900) {
          return mobileScaffold;
        } else {
          return desktopScaffold;
        }
      },
    );
  }
}
