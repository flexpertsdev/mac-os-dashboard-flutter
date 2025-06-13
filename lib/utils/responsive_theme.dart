import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'responsive_helper.dart';

/// Responsive theme builder that creates context-aware themes
class ResponsiveTheme {
  
  /// Creates a responsive light theme based on current context
  static ThemeData lightTheme(BuildContext context) => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: const Color(0xFF007AFF),
      secondary: const Color(0xFF34C759),
      tertiary: const Color(0xFFFF9500),
      surface: const Color(0xFFFFFFFF),
      surfaceContainerHighest: const Color(0xFFF2F2F7),
      error: const Color(0xFFFF3B30),
      onPrimary: const Color(0xFFFFFFFF),
      onSecondary: const Color(0xFFFFFFFF),
      onTertiary: const Color(0xFFFFFFFF),
      onSurface: const Color(0xFF1C1C1E),
      onError: const Color(0xFFFFFFFF),
      outline: const Color(0xFFC7C7CC),
      shadow: const Color(0xFF000000).withOpacity(0.1),
    ),
    brightness: Brightness.light,
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
      ),
      shadowColor: const Color(0xFF000000).withOpacity(0.08),
      margin: ResponsiveHelper.getContentPadding(context),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsiveWidth(context, 20),
          vertical: ResponsiveHelper.getResponsiveHeight(context, 12),
        ),
        minimumSize: Size(
          ResponsiveHelper.ensureMinTouchTarget(ResponsiveHelper.getResponsiveWidth(context, 64)),
          ResponsiveHelper.ensureMinTouchTarget(ResponsiveHelper.getResponsiveHeight(context, 36)),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: Size(
          ResponsiveHelper.minTouchTarget,
          ResponsiveHelper.minTouchTarget,
        ),
        iconSize: ResponsiveHelper.getIconSize(context),
      ),
    ),
    textTheme: _buildResponsiveTextTheme(context, Brightness.light),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveWidth(context, 16),
        vertical: ResponsiveHelper.getResponsiveHeight(context, 12),
      ),
    ),
    chipTheme: ChipThemeData(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveWidth(context, 12),
        vertical: ResponsiveHelper.getResponsiveHeight(context, 8),
      ),
    ),
  );

  /// Creates a responsive dark theme based on current context
  static ThemeData darkTheme(BuildContext context) => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: const Color(0xFF007AFF),
      secondary: const Color(0xFF34C759),
      tertiary: const Color(0xFFFF9500),
      surface: const Color(0xFF1C1C1E),
      surfaceContainerHighest: const Color(0xFF2C2C2E),
      error: const Color(0xFFFF453A),
      onPrimary: const Color(0xFFFFFFFF),
      onSecondary: const Color(0xFFFFFFFF),
      onTertiary: const Color(0xFF000000),
      onSurface: const Color(0xFFFFFFFF),
      onError: const Color(0xFFFFFFFF),
      outline: const Color(0xFF38383A),
      shadow: const Color(0xFF000000).withOpacity(0.3),
    ),
    brightness: Brightness.dark,
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
      ),
      shadowColor: const Color(0xFF000000).withOpacity(0.3),
      margin: ResponsiveHelper.getContentPadding(context),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveHelper.getResponsiveWidth(context, 20),
          vertical: ResponsiveHelper.getResponsiveHeight(context, 12),
        ),
        minimumSize: Size(
          ResponsiveHelper.ensureMinTouchTarget(ResponsiveHelper.getResponsiveWidth(context, 64)),
          ResponsiveHelper.ensureMinTouchTarget(ResponsiveHelper.getResponsiveHeight(context, 36)),
        ),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: Size(
          ResponsiveHelper.minTouchTarget,
          ResponsiveHelper.minTouchTarget,
        ),
        iconSize: ResponsiveHelper.getIconSize(context),
      ),
    ),
    textTheme: _buildResponsiveTextTheme(context, Brightness.dark),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 8)),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveWidth(context, 16),
        vertical: ResponsiveHelper.getResponsiveHeight(context, 12),
      ),
    ),
    chipTheme: ChipThemeData(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getResponsiveWidth(context, 12),
        vertical: ResponsiveHelper.getResponsiveHeight(context, 8),
      ),
    ),
  );

  /// Builds responsive text theme that scales with screen size and accessibility settings
  static TextTheme _buildResponsiveTextTheme(BuildContext context, Brightness brightness) {
    final Color textColor = brightness == Brightness.light 
        ? const Color(0xFF1C1C1E) 
        : const Color(0xFFFFFFFF);
    final Color secondaryTextColor = const Color(0xFF8E8E93);
    final Color accentColor = const Color(0xFF007AFF);

    return TextTheme(
      displayLarge: GoogleFonts.inter(
        fontSize: ResponsiveHelper.getDisplayLarge(context),
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.2,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: ResponsiveHelper.getDisplayMedium(context),
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.2,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: ResponsiveHelper.getDisplaySmall(context),
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.25,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: ResponsiveHelper.getHeadlineLarge(context),
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: ResponsiveHelper.getHeadlineMedium(context),
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.3,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: ResponsiveHelper.getHeadlineSmall(context),
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.3,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: ResponsiveHelper.getTitleLarge(context),
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: ResponsiveHelper.getTitleMedium(context),
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: ResponsiveHelper.getTitleSmall(context),
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: ResponsiveHelper.getLabelLarge(context),
        fontWeight: FontWeight.w500,
        color: accentColor,
        height: 1.4,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: ResponsiveHelper.getLabelMedium(context),
        fontWeight: FontWeight.w500,
        color: accentColor,
        height: 1.4,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: ResponsiveHelper.getLabelSmall(context),
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
        height: 1.4,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: ResponsiveHelper.getBodyLarge(context),
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: ResponsiveHelper.getBodyMedium(context),
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.5,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: ResponsiveHelper.getBodySmall(context),
        fontWeight: FontWeight.normal,
        color: secondaryTextColor,
        height: 1.5,
      ),
    );
  }

  /// Creates responsive text style with overflow protection
  static TextStyle responsiveTextStyle(
    BuildContext context, {
    required double baseFontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    bool enableOverflowProtection = true,
  }) {
    return GoogleFonts.inter(
      fontSize: ResponsiveHelper.getResponsiveFontSize(context, baseFontSize),
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color,
      height: height ?? 1.4,
      overflow: enableOverflowProtection ? TextOverflow.ellipsis : null,
    );
  }

  /// Creates a responsive container with proper constraints
  static Widget responsiveContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Color? color,
    BoxConstraints? constraints,
  }) {
    return Container(
      padding: padding ?? ResponsiveHelper.getContentPadding(context),
      margin: margin,
      color: color,
      constraints: constraints ?? ResponsiveHelper.getContainerConstraints(context),
      child: child,
    );
  }

  /// Creates a responsive card with proper sizing
  static Widget responsiveCard({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    double? elevation,
  }) {
    return Card(
      elevation: elevation ?? 0,
      margin: margin ?? EdgeInsets.all(ResponsiveHelper.getCardSpacing(context)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveWidth(context, 12)),
      ),
      child: Container(
        padding: padding ?? ResponsiveHelper.getContentPadding(context),
        constraints: ResponsiveHelper.getCardConstraints(context),
        child: child,
      ),
    );
  }

  /// Creates a responsive icon button with proper touch targets
  static Widget responsiveIconButton({
    required BuildContext context,
    required VoidCallback onPressed,
    required IconData icon,
    Color? color,
    double? size,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: size ?? ResponsiveHelper.getIconSize(context),
          color: color,
        ),
        iconSize: ResponsiveHelper.getIconSize(context),
        constraints: BoxConstraints(
          minWidth: ResponsiveHelper.minTouchTarget,
          minHeight: ResponsiveHelper.minTouchTarget,
        ),
      ),
    );
  }
}