import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/glass_container.dart';
import '../constants/app_theme.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final scale = userProvider.user?.uiScale ?? 1.0;
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    final horizontalPadding = (isSmallScreen ? 14.0 : 18.0) * scale;
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 6 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Reminders',
            style: TextStyle(
              fontSize: (isSmallScreen ? 28 : 32) * scale,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            'Stay on track with prayer notifications',
            style: TextStyle(
              fontSize: (isSmallScreen ? 13 : 14) * scale,
              color: Colors.white.withAlpha(120),
            ),
          ),
          SizedBox(height: 20 * scale),

          // Quick toggle for all
          GlassContainer(
            padding: EdgeInsets.all(20 * scale),
            child: Row(
              children: [
                Container(
                  width: 48 * scale,
                  height: 48 * scale,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF00D9FF), Color(0xFF0066FF)],
                    ),
                    borderRadius: BorderRadius.circular(16 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D9FF).withAlpha(80),
                        blurRadius: 12 * scale,
                        offset: Offset(0, 4 * scale),
                      ),
                    ],
                  ),
                  child: Icon(Icons.notifications_active_rounded,
                      size: 22 * scale, color: Colors.white),
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'All Reminders',
                        style: TextStyle(
                          fontSize: 16 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        'Enable notifications for all prayers',
                        style: TextStyle(
                          fontSize: 12 * scale,
                          color: Colors.white.withAlpha(140),
                        ),
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.9,
                  child: _buildSwitch(
                    userProvider.areAllRemindersEnabled,
                    (val) => userProvider.toggleAllReminders(val),
                    scale,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16 * scale),

          // Individual prayer reminders
          ...prayers.map((prayer) => _buildPrayerReminderCard(
            context, prayer, userProvider, scale, isSmallScreen,
          )),

          SizedBox(height: 16 * scale),

          // Minutes before Adhan
          _buildSectionLabel('REMINDER TIMING', scale),
          SizedBox(height: 10 * scale),
          GlassContainer(
            padding: EdgeInsets.all(18 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notify me before Adhan',
                  style: TextStyle(
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
                SizedBox(height: 14 * scale),
                Row(
                  children: [5, 10, 15, 30].map((minutes) {
                    final isSelected = userProvider.reminderMinutesBefore == minutes;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => userProvider.setReminderMinutesBefore(minutes),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: EdgeInsets.symmetric(horizontal: 3 * scale),
                          padding: EdgeInsets.symmetric(vertical: 12 * scale),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF00D9FF).withAlpha(20)
                                : Colors.white.withAlpha(5),
                            borderRadius: BorderRadius.circular(12 * scale),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF00D9FF).withAlpha(60)
                                  : Colors.white.withAlpha(12),
                              width: isSelected ? 1.5 : 0.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${minutes}m',
                              style: TextStyle(
                                fontSize: 14 * scale,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                color: isSelected
                                    ? const Color(0xFF00D9FF)
                                    : Colors.white.withAlpha(120),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          SizedBox(height: 24 * scale),
        ],
      ),
    );
  }

  Widget _buildPrayerReminderCard(
    BuildContext context,
    String prayer,
    UserProvider userProvider,
    double scale,
    bool isSmallScreen,
  ) {
    final prayerColor = AppTheme.getPrayerColor(prayer);
    final prayerIcon = AppTheme.getPrayerIcon(prayer);
    final isEnabled = userProvider.isReminderEnabled(prayer);

    return Padding(
      padding: EdgeInsets.only(bottom: 10 * scale),
      child: GlassContainer(
        padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
        variant: isEnabled ? GlassVariant.elevated : GlassVariant.standard,
        accentColor: isEnabled ? prayerColor : null, // Uses glass container accent logic
        child: Row(
          children: [
            // Icon with Glow
            Container(
              width: 42 * scale,
              height: 42 * scale,
              decoration: BoxDecoration(
                color: isEnabled ? prayerColor.withAlpha(25) : Colors.white.withAlpha(5),
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: isEnabled ? prayerColor.withAlpha(80) : Colors.white.withAlpha(10),
                ),
                boxShadow: isEnabled
                    ? [
                        BoxShadow(
                          color: prayerColor.withAlpha(40),
                          blurRadius: 10 * scale,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                prayerIcon, 
                size: 20 * scale, 
                color: isEnabled ? prayerColor : Colors.white.withAlpha(100)
              ),
            ),
            SizedBox(width: 16 * scale),
            
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayer,
                    style: TextStyle(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withAlpha(isEnabled ? 255 : 150),
                    ),
                  ),
                  if (isEnabled)
                    Padding(
                      padding: EdgeInsets.only(top: 2 * scale),
                      child: Text(
                        'Reminder on',
                        style: TextStyle(
                          fontSize: 10 * scale,
                          color: prayerColor.withAlpha(200),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Toggle
            _buildSwitch(isEnabled, (val) => userProvider.toggleReminder(prayer, val), scale),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitch(bool value, ValueChanged<bool> onChanged, double scale) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        width: 52 * scale,
        height: 30 * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15 * scale),
          color: value ? const Color(0xFF00D9FF) : Colors.white.withAlpha(20),
          border: Border.all(
             color: value ? const Color(0xFF00D9FF) : Colors.white.withAlpha(30),
             width: 1.5,
          ),
          boxShadow: value ? [
            BoxShadow(
              color: const Color(0xFF00D9FF).withAlpha(100),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ] : [],
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              left: value ? 24 * scale : 2 * scale,
              top: 2 * scale,
              child: Container(
                width: 23 * scale,
                height: 23 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                       color: Colors.black.withAlpha(40),
                       blurRadius: 4,
                       offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: value ? Icon(Icons.check, size: 14 * scale, color: const Color(0xFF00D9FF)) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, double scale) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 11 * scale,
        fontWeight: FontWeight.w700,
        color: Colors.white.withAlpha(60),
        letterSpacing: 2,
      ),
    );
  }
}
