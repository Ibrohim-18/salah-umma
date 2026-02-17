import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../constants/app_theme.dart';
import '../painters/islamic_pattern_painter.dart';
import '../screens/qibla_screen.dart';
import '../screens/ramadan_screen.dart';
import 'prayer_cycle_panel.dart';

class SideMenuDrawer extends StatelessWidget {
  const SideMenuDrawer({
    super.key,
    required this.onTabSelected,
  });

  final Function(int) onTabSelected;

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final scale = user?.uiScale ?? 1.0;
    final todayDone = userProvider.todayCompletedCount.clamp(0, 5);
    final prayerTimes = userProvider.todayPrayerTimes;
    final hasName = user?.name?.trim().isNotEmpty ?? false;
    final displayName = hasName ? user!.name!.trim() : 'Set your name';
    final displayInitial = hasName ? user!.name!.trim()[0].toUpperCase() : '?';
    final city = user?.city?.trim();
    final hasCity = city != null && city.isNotEmpty;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.86,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          right: Radius.circular(30 * scale),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.horizontal(
              right: Radius.circular(30 * scale),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0C1324).withAlpha(180),
                      const Color(0xFF0F1B35).withAlpha(160),
                      const Color(0xFF0C1324).withAlpha(180),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: -120 * scale,
            left: -50 * scale,
            child: Container(
              width: 280 * scale,
              height: 280 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentGold.withAlpha(22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -170 * scale,
            right: -80 * scale,
            child: Container(
              width: 320 * scale,
              height: 320 * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFB020).withAlpha(20),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          ...List.generate(14, (index) {
            final seed = index * 97 + 41;
            return Positioned(
              left: (seed % 300).toDouble() * scale,
              top: ((seed * 3) % 700).toDouble() * scale,
              child: Container(
                width: (((index % 3) + 1) * 1.0) * scale,
                height: (((index % 3) + 1) * 1.0) * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index % 2 == 0
                      ? AppTheme.accentGold.withAlpha(20)
                      : const Color(0xFFFFFFFF).withAlpha(14),
                ),
              ),
            );
          }),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.accentGold.withAlpha(64),
                    const Color(0xFFFFB020).withAlpha(44),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.2, 0.8, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(14 * scale, 14 * scale, 14 * scale, 8 * scale),
                  padding: EdgeInsets.fromLTRB(14 * scale, 14 * scale, 14 * scale, 12 * scale),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withAlpha(12),
                        Colors.white.withAlpha(4),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20 * scale),
                    border: Border.all(color: Colors.white.withAlpha(16)),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGold.withAlpha(14),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 26 * scale,
                        width: double.infinity,
                        child: CustomPaint(
                          painter: IslamicPatternPainter(),
                        ),
                      ),
                      SizedBox(height: 10 * scale),
                      Row(
                        children: [
                          Container(
                            width: 54 * scale,
                            height: 54 * scale,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16 * scale),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppTheme.accentGold,
                                  Color(0xFFFFB020),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentGold.withAlpha(62),
                                  blurRadius: 22,
                                  offset: const Offset(0, 6),
                                ),
                                BoxShadow(
                                  color: const Color(0xFFFFB020).withAlpha(30),
                                  blurRadius: 14,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Icon(
                                  Icons.mosque_rounded,
                                  color: Colors.white.withAlpha(230),
                                  size: 28 * scale,
                                ),
                                Positioned(
                                  bottom: 8,
                                  right: 8,
                                  child: Container(
                                    width: 8 * scale,
                                    height: 8 * scale,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGold,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.accentGold.withAlpha(110),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 14 * scale),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SALAH UMMA',
                                  style: TextStyle(
                                    fontSize: 18 * scale,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 2.0,
                                    height: 1.05,
                                  ),
                                ),
                                SizedBox(height: 5 * scale),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFFFD700).withAlpha(30),
                                        const Color(0xFFFFD700).withAlpha(15),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8 * scale),
                                    border: Border.all(color: const Color(0xFFFFD700).withAlpha(50)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star_rounded,
                                        size: 10 * scale,
                                        color: const Color(0xFFFFD700),
                                      ),
                                      SizedBox(width: 4 * scale),
                                      Text(
                                        'PREMIUM',
                                        style: TextStyle(
                                          fontSize: 9 * scale,
                                          fontWeight: FontWeight.w800,
                                          color: const Color(0xFFFFD700),
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(11 * scale),
                            child: Ink(
                              width: 38 * scale,
                              height: 38 * scale,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withAlpha(10),
                                    Colors.white.withAlpha(4),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(11 * scale),
                                border: Border.all(color: Colors.white.withAlpha(15)),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: Colors.white.withAlpha(160),
                                size: 18 * scale,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (user != null)
                  Container(
                    margin: EdgeInsets.fromLTRB(16 * scale, 6 * scale, 16 * scale, 0),
                    padding: EdgeInsets.all(14 * scale),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withAlpha(8),
                          Colors.white.withAlpha(3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18 * scale),
                      border: Border.all(color: Colors.white.withAlpha(12)),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentGold.withAlpha(8),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48 * scale,
                          height: 48 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFFFFD700).withAlpha(25),
                                const Color(0xFFFFB020).withAlpha(20),
                              ],
                            ),
                            border: Border.all(
                              color: AppTheme.accentGold.withAlpha(50),
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              displayInitial,
                              style: TextStyle(
                                fontSize: 20 * scale,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.accentGold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayName,
                                style: TextStyle(
                                  fontSize: 15 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withAlpha(230),
                                ),
                              ),
                              SizedBox(height: 4 * scale),
                              if (hasCity)
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 12 * scale,
                                      color: Colors.white.withAlpha(70),
                                    ),
                                    SizedBox(width: 4 * scale),
                                    Expanded(
                                      child: Text(
                                        city,
                                        style: TextStyle(
                                          fontSize: 12 * scale,
                                          color: Colors.white.withAlpha(70),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                            onTabSelected(3); // Settings tab
                          },
                          child: Container(
                            width: 32 * scale,
                            height: 32 * scale,
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(6),
                              borderRadius: BorderRadius.circular(8 * scale),
                            ),
                            child: Icon(
                              Icons.edit_outlined,
                              color: Colors.white.withAlpha(70),
                              size: 16 * scale,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    margin: EdgeInsets.fromLTRB(16 * scale, 6 * scale, 16 * scale, 0),
                    padding: EdgeInsets.all(16 * scale),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(5),
                      borderRadius: BorderRadius.circular(18 * scale),
                      border: Border.all(color: Colors.white.withAlpha(10)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48 * scale,
                          height: 48 * scale,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(8),
                            border: Border.all(color: Colors.white.withAlpha(15)),
                          ),
                          child: Icon(
                            Icons.person_add_outlined,
                            color: Colors.white.withAlpha(60),
                            size: 22 * scale,
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        Text(
                          'Set up your profile',
                          style: TextStyle(
                            fontSize: 14 * scale,
                            color: Colors.white.withAlpha(120),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 20 * scale),
                PrayerCyclePanel(
                  scale: scale,
                  todayDone: todayDone,
                  prayerTimes: prayerTimes,
                ),
                SizedBox(height: 20 * scale),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 12 * scale),
                    children: [
                      _buildSectionLabel('FEATURES', scale),
                      SizedBox(height: 8 * scale),
                      _buildExternalNavItem(
                        context,
                        Icons.analytics_outlined,
                        'Statistics',
                        AppTheme.accentGold,
                        AppTheme.accentGold,
                        () {
                          Navigator.pop(context);
                          onTabSelected(1); // Stats tab
                        },
                        scale,
                        subtitle: 'Track streaks and completion',
                      ),
                      _buildExternalNavItem(
                        context,
                        Icons.explore_rounded,
                        'Qibla Finder',
                        const Color(0xFFFFB020),
                        const Color(0xFFFFB020),
                        () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const QiblaScreen()));
                        },
                        scale,
                        subtitle: 'Find accurate qibla direction',
                      ),
                      _buildExternalNavItem(
                        context,
                        Icons.calendar_month_rounded,
                        'Ramadan Tracker',
                        const Color(0xFFFFB020),
                        const Color(0xFFFFB020),
                        () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const RamadanScreen()));
                        },
                        scale,
                        subtitle: 'Daily fasting and goals',
                      ),
                      SizedBox(height: 16 * scale),
                      _buildSectionLabel('SUPPORT', scale),
                      SizedBox(height: 8 * scale),
                      _buildExternalNavItem(
                        context,
                        Icons.help_outline_rounded,
                        'Help & FAQ',
                        Colors.white.withAlpha(150),
                        Colors.white.withAlpha(30),
                        () {
                          Navigator.pop(context);
                        },
                        scale,
                        subtitle: 'Guides and common questions',
                      ),
                      _buildExternalNavItem(
                        context,
                        Icons.star_outline_rounded,
                        'Rate App',
                        const Color(0xFFFFD700),
                        const Color(0xFFFFD700).withAlpha(30),
                        () {
                          Navigator.pop(context);
                        },
                        scale,
                        subtitle: 'Share your feedback',
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(24 * scale, 16 * scale, 24 * scale, 16 * scale),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Colors.white.withAlpha(12))),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome_rounded,
                        size: 12 * scale,
                        color: AppTheme.accentGold.withAlpha(170),
                      ),
                      SizedBox(width: 10 * scale),
                      Text(
                        'v2.1.0',
                        style: TextStyle(
                          fontSize: 11 * scale,
                          color: Colors.white.withAlpha(40),
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Built with ihsan',
                        style: TextStyle(
                          fontSize: 11 * scale,
                          color: Colors.white.withAlpha(52),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
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
    );
  }

  Widget _buildSectionLabel(String label, double scale) {
    return Padding(
      padding: EdgeInsets.only(left: 14 * scale, bottom: 5 * scale, top: 2 * scale),
      child: Row(
        children: [
          Container(
            width: 14 * scale,
            height: 1,
            color: Colors.white.withAlpha(30),
          ),
          SizedBox(width: 8 * scale),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5 * scale,
              fontWeight: FontWeight.w800,
              color: Colors.white.withAlpha(70),
              letterSpacing: 2.1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExternalNavItem(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    Color borderColor,
    VoidCallback onTap,
    double scale, {
    String? subtitle,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * scale),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16 * scale),
          splashColor: color.withAlpha(24),
          highlightColor: color.withAlpha(8),
          child: Ink(
            padding: EdgeInsets.symmetric(
              horizontal: 14 * scale,
              vertical: subtitle == null ? 12 * scale : 10 * scale,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withAlpha(7),
                  Colors.white.withAlpha(2),
                ],
              ),
              borderRadius: BorderRadius.circular(16 * scale),
              border: Border.all(color: borderColor.withAlpha(26)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40 * scale,
                  height: 40 * scale,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withAlpha(26),
                        color.withAlpha(10),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(11 * scale),
                    border: Border.all(color: borderColor.withAlpha(45)),
                  ),
                  child: Icon(icon, color: color.withAlpha(225), size: 20 * scale),
                ),
                SizedBox(width: 14 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 15 * scale,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withAlpha(205),
                        ),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 2 * scale),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 11 * scale,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withAlpha(102),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  width: 24 * scale,
                  height: 24 * scale,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(7),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withAlpha(14)),
                  ),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 15 * scale,
                    color: Colors.white.withAlpha(110),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
