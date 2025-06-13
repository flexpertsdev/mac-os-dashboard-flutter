import 'package:flutter/material.dart';
import 'dart:math' as math;

class ResponsiveHelper {
  // Fluid breakpoints - no hard edges, smooth transitions
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1200;
  static const double ultraWideBreakpoint = 1800;

  // Minimum touch target size for accessibility
  static const double minTouchTarget = 44.0;

  // Base font size for scaling calculations
  static const double baseFontSize = 16.0;

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

  static bool isUltraWide(BuildContext context) {
    return MediaQuery.of(context).size.width >= ultraWideBreakpoint;
  }

  // Fluid grid columns based on available width
  static int getGridColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Fluid calculation: aim for ~300px per column with min 1, max 6
    return math.max(1, math.min(6, (width / 300).floor()));
  }

  // Dynamic sidebar width based on screen size percentage
  static double getSidebarWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (isMobile(context)) {
      return width * 0.85; // 85% of mobile screen
    } else if (isTablet(context)) {
      return math.min(320, width * 0.4); // Max 320px or 40% of screen
    } else {
      return math.min(280, width * 0.25); // Max 280px or 25% of screen
    }
  }

  static double getCollapsedSidebarWidth(BuildContext context) {
    return math.max(minTouchTarget + 16, MediaQuery.of(context).size.width * 0.08);
  }

  // Fluid padding based on screen size
  static EdgeInsets getContentPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final paddingValue = math.max(16.0, width * 0.02); // Min 16px, max 2% of width
    return EdgeInsets.all(math.min(32.0, paddingValue)); // Cap at 32px
  }

  // Dynamic spacing that scales with screen size
  static double getCardSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return math.max(12.0, math.min(24.0, width * 0.015)); // Between 12-24px
  }

  static CrossAxisAlignment getCardAlignment(BuildContext context) {
    return isMobile(context) 
        ? CrossAxisAlignment.center 
        : CrossAxisAlignment.start;
  }

  // RESPONSIVE TYPOGRAPHY SYSTEM
  
  // Get responsive font size based on screen width and text scale factor
  static double getResponsiveFontSize(BuildContext context, double baseFontSize) {
    final mediaQuery = MediaQuery.of(context);
    final width = mediaQuery.size.width;
    final textScaler = mediaQuery.textScaler;
    final textScaleFactor = textScaler.scale(1.0);
    
    // Scale factor based on screen width (0.85 to 1.3)
    double screenScale;
    if (width < mobileBreakpoint) {
      screenScale = 0.85 + (width / mobileBreakpoint) * 0.25; // 0.85 to 1.1
    } else if (width < tabletBreakpoint) {
      screenScale = 1.1 + ((width - mobileBreakpoint) / (tabletBreakpoint - mobileBreakpoint)) * 0.1; // 1.1 to 1.2
    } else {
      screenScale = 1.2 + ((width - tabletBreakpoint) / (ultraWideBreakpoint - tabletBreakpoint)) * 0.1; // 1.2 to 1.3
    }
    
    // Apply both screen scaling and accessibility text scaling
    return baseFontSize * screenScale * textScaleFactor;
  }

  // Typography scale - all sizes scale responsively
  static double getDisplayLarge(BuildContext context) => getResponsiveFontSize(context, 45.0);
  static double getDisplayMedium(BuildContext context) => getResponsiveFontSize(context, 36.0);
  static double getDisplaySmall(BuildContext context) => getResponsiveFontSize(context, 32.0);
  
  static double getHeadlineLarge(BuildContext context) => getResponsiveFontSize(context, 28.0);
  static double getHeadlineMedium(BuildContext context) => getResponsiveFontSize(context, 24.0);
  static double getHeadlineSmall(BuildContext context) => getResponsiveFontSize(context, 20.0);
  
  static double getTitleLarge(BuildContext context) => getResponsiveFontSize(context, 18.0);
  static double getTitleMedium(BuildContext context) => getResponsiveFontSize(context, 16.0);
  static double getTitleSmall(BuildContext context) => getResponsiveFontSize(context, 14.0);
  
  static double getBodyLarge(BuildContext context) => getResponsiveFontSize(context, 16.0);
  static double getBodyMedium(BuildContext context) => getResponsiveFontSize(context, 14.0);
  static double getBodySmall(BuildContext context) => getResponsiveFontSize(context, 12.0);
  
  static double getLabelLarge(BuildContext context) => getResponsiveFontSize(context, 14.0);
  static double getLabelMedium(BuildContext context) => getResponsiveFontSize(context, 12.0);
  static double getLabelSmall(BuildContext context) => getResponsiveFontSize(context, 10.0);

  // DYNAMIC SIZING SYSTEM

  // Get responsive height that scales with screen size
  static double getResponsiveHeight(BuildContext context, double baseHeight) {
    final height = MediaQuery.of(context).size.height;
    final scale = math.max(0.7, math.min(1.3, height / 800)); // Scale between 70% and 130%
    return baseHeight * scale;
  }

  // Get responsive width that scales with screen size
  static double getResponsiveWidth(BuildContext context, double baseWidth) {
    final width = MediaQuery.of(context).size.width;
    final scale = math.max(0.8, math.min(1.2, width / 1200)); // Scale between 80% and 120%
    return baseWidth * scale;
  }

  // Ensure minimum touch target size
  static double ensureMinTouchTarget(double size) {
    return math.max(minTouchTarget, size);
  }

  // Get safe icon size that meets touch target requirements
  static double getIconSize(BuildContext context, {double baseSize = 24.0}) {
    final responsiveSize = getResponsiveWidth(context, baseSize);
    return ensureMinTouchTarget(responsiveSize);
  }

  // CONTAINER AND LAYOUT HELPERS

  // Get container constraints that adapt to screen size
  static BoxConstraints getContainerConstraints(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return BoxConstraints(
      minHeight: getResponsiveHeight(context, 100),
      maxWidth: math.min(width * 0.9, 1200), // Max 90% of screen or 1200px
    );
  }

  // Get card constraints with minimum sizes
  static BoxConstraints getCardConstraints(BuildContext context) {
    return BoxConstraints(
      minHeight: getResponsiveHeight(context, 120),
      minWidth: getResponsiveWidth(context, 200),
    );
  }

  // Get aspect ratio that adapts to screen orientation
  static double getCardAspectRatio(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    final width = mediaQuery.size.width;
    
    if (isMobile(context)) {
      return isLandscape ? 2.0 : 1.2; // Wider in landscape
    } else if (isTablet(context)) {
      return 1.5;
    } else {
      return width > ultraWideBreakpoint ? 2.0 : 1.6; // Wider on ultra-wide screens
    }
  }

  // ACCESSIBILITY HELPERS

  // Check if user has accessibility large text enabled
  static bool isLargeTextEnabled(BuildContext context) {
    final textScaler = MediaQuery.of(context).textScaler;
    return textScaler.scale(1.0) > 1.3;
  }

  // Get accessible spacing that accounts for large text
  static double getAccessibleSpacing(BuildContext context, double baseSpacing) {
    final textScaler = MediaQuery.of(context).textScaler;
    final textScale = textScaler.scale(1.0);
    return baseSpacing * math.max(1.0, textScale * 0.8);
  }
}