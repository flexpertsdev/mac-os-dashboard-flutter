import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return 1;
    } else if (width < tabletBreakpoint) {
      return 2;
    } else if (width < desktopBreakpoint) {
      return 3;
    } else {
      return 4;
    }
  }

  static double getSidebarWidth(BuildContext context) {
    if (isMobile(context)) {
      return 280.0;
    } else {
      return 240.0;
    }
  }

  static double getCollapsedSidebarWidth() {
    return 72.0;
  }

  static EdgeInsets getContentPadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(20.0);
    } else {
      return const EdgeInsets.all(24.0);
    }
  }

  static double getCardSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 12.0;
    } else {
      return 16.0;
    }
  }

  static CrossAxisAlignment getCardAlignment(BuildContext context) {
    return isMobile(context) 
        ? CrossAxisAlignment.center 
        : CrossAxisAlignment.start;
  }
}