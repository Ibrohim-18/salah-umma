import 'package:flutter/material.dart';

/// Centralized Design Tokens for Salah Umma Premium UI
class AppTheme {
  AppTheme._();

  // ─── Primary Brand Colors ───
  static const Color primaryTeal = Color(0xFF00E5FF); // Brighter teal
  static const Color primaryPurple = Color(0xFF9D4EDD); // Deeper purple
  static const Color primaryBlue = Color(0xFF2962FF); // Vivid blue
  static const Color successGreen = Color(0xFF00C853);
  static const Color accentGold = Color(0xFFFFD700);
  static const Color primaryGold = Color(0xFFFFD700);
  static const Color secondaryGold = Color(0xFFFFB020);
  static const Color deepGold = Color(0xFFB8860B);
  static const Color glassWhite = Color(0x1FFFFFFF);
  static const Color successEmerald = Color(0xFF10B981);
  static const Color successMint = Color(0xFF34D399);

  // ─── Prayer-Specific Colors (Vibrant) ───
  static const Color fajrColor = Color(0xFF64B5F6);       // Morning Sky
  static const Color fajrAccent = Color(0xFFBBDEFB);
  static const Color dhuhrColor = Color(0xFFFFA000);      // Noon Sun
  static const Color dhuhrAccent = Color(0xFFFFE082);
  static const Color asrColor = Color(0xFFFF6D00);        // Late Afternoon
  static const Color asrAccent = Color(0xFFFFCC80);
  static const Color maghribColor = Color(0xFFC2185B);    // Sunset
  static const Color maghribAccent = Color(0xFFF48FB1);
  static const Color ishaColor = Color(0xFF304FFE);       // Night
  static const Color ishaAccent = Color(0xFF8C9EFF);

  // ─── Background Gradients (Deep & Rich) ───
  static const List<Color> fajrGradient = [
    Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2),
  ];
  static const List<Color> dhuhrGradient = [
    Color(0xFFE65100), Color(0xFFEF6C00), Color(0xFFF57C00),
  ];
  static const List<Color> asrGradient = [
    Color(0xFFBF360C), Color(0xFFD84315), Color(0xFFE64A19),
  ];
  static const List<Color> maghribGradient = [
    Color(0xFF4A148C), Color(0xFF6A1B9A), Color(0xFF7B1FA2),
  ];
  static const List<Color> ishaGradient = [
    Color(0xFF000000), Color(0xFF1A237E), Color(0xFF283593),
  ];
  
  static const List<Color> goldGradient = [
    primaryGold, secondaryGold,
  ];

  static const List<Color> successGradient = [
    successMint, successEmerald,
  ];

  // ─── Spacing ───
  static const double spacingXs = 6;
  static const double spacingSm = 10;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;
  static const double spacingXxl = 48;

  // ─── Border Radius ───
  static const double radiusSm = 10;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 32;
  static const double radiusFull = 999;

  // ─── Prayer Icons (Filled vs Outlined) ───
  static IconData getPrayerIcon(String prayer) {
    switch (prayer.toLowerCase()) {
      case 'fajr':    return Icons.wb_twilight_rounded;
      case 'dhuhr':   return Icons.wb_sunny_rounded;
      case 'asr':     return Icons.wb_sunny_outlined;
      case 'maghrib': return Icons.nights_stay_rounded;
      case 'isha':    return Icons.bedtime_rounded;
      default:        return Icons.access_time_rounded;
    }
  }

  /// Get the accent color for a specific prayer
  static Color getPrayerColor(String prayer) {
    switch (prayer.toLowerCase()) {
      case 'fajr':    return fajrColor;
      case 'dhuhr':   return dhuhrColor;
      case 'asr':     return asrColor;
      case 'maghrib': return maghribColor;
      case 'isha':    return ishaColor;
      default:        return primaryTeal;
    }
  }

  /// Get the lighter accent for a specific prayer
  static Color getPrayerAccent(String prayer) {
    switch (prayer.toLowerCase()) {
      case 'fajr':    return fajrAccent;
      case 'dhuhr':   return dhuhrAccent;
      case 'asr':     return asrAccent;
      case 'maghrib': return maghribAccent;
      case 'isha':    return ishaAccent;
      default:        return primaryTeal;
    }
  }

  /// Get background gradient based on current prayer time
  static List<Color> getTimeBasedGradient(String? currentPrayer) {
    switch (currentPrayer?.toLowerCase()) {
      case 'fajr':    return fajrGradient;
      case 'dhuhr':   return dhuhrGradient;
      case 'asr':     return asrGradient;
      case 'maghrib': return maghribGradient;
      case 'isha':    return ishaGradient;
      default:        return ishaGradient;
    }
  }

  /// Get time-of-day greeting
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Assalamu Alaikum';
    if (hour < 12) return 'Sabah al-Khair';
    if (hour < 17) return 'Masa al-Khair';
    return 'Masa al-Nur';
  }

  /// Get greeting subtitle in English
  static String getGreetingSubtitle() {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Peace be upon you';
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
