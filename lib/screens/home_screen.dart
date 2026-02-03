import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/glass_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final scale = userProvider.user?.uiScale ?? 1.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final horizontalPadding = (isSmallScreen ? 12.0 : 16.0) * scale;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 6 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, scale),
          SizedBox(height: 12 * scale),
          _buildNextPrayerCard(context, scale),
          SizedBox(height: 14 * scale),
          _buildDateNavigation(context, scale),
          SizedBox(height: 10 * scale),
          _buildPrayerTimesList(context, scale),
          SizedBox(height: 14 * scale),
          _buildQadaCard(context, scale),
          SizedBox(height: 12 * scale),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double scale) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final now = DateTime.now();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatDate(now),
            style: TextStyle(
              fontSize: (isSmallScreen ? 14 : 16) * scale,
              fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(220),
              letterSpacing: 0.3,
            ),
          ),
          if (user?.city != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: (isSmallScreen ? 10 : 12) * scale,
                vertical: (isSmallScreen ? 5 : 6) * scale,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(16 * scale),
                border: Border.all(color: Colors.white.withAlpha(25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on_outlined,
                       color: Colors.white.withAlpha(180), size: (isSmallScreen ? 12 : 14) * scale),
                  SizedBox(width: 4 * scale),
                  Text(
                    user!.city!,
                    style: TextStyle(
                      fontSize: (isSmallScreen ? 10 : 11) * scale,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateNavigation(BuildContext context, double scale) {
    final userProvider = context.watch<UserProvider>();
    final selectedDate = userProvider.selectedDate;
    final completed = userProvider.selectedDateCompletedCount;
    final isToday = userProvider.isSelectedDateToday;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2 * scale),
      child: Row(
        children: [
          // Left arrow
          _buildNavButton(
            context,
            Icons.chevron_left,
            () => userProvider.goToPreviousDay(),
            scale,
          ),
          SizedBox(width: 4 * scale),
          // Date display
          Expanded(
            child: GestureDetector(
              onTap: isToday ? null : () => userProvider.goToToday(),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: (isSmallScreen ? 10 : 12) * scale,
                  vertical: (isSmallScreen ? 6 : 8) * scale,
                ),
                decoration: BoxDecoration(
                  color: isToday
                      ? const Color(0xFF3B82F6).withAlpha(30)
                      : Colors.white.withAlpha(10),
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: Border.all(
                    color: isToday
                        ? const Color(0xFF3B82F6).withAlpha(60)
                        : Colors.white.withAlpha(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isToday ? 'Today' : _formatDateShort(selectedDate),
                      style: TextStyle(
                        fontSize: (isSmallScreen ? 13 : 14) * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withAlpha(230),
                      ),
                    ),
                    if (!isToday) ...[
                      SizedBox(width: 6 * scale),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4 * scale,
                          vertical: 1 * scale,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(15),
                          borderRadius: BorderRadius.circular(4 * scale),
                        ),
                        child: Text(
                          'TAP FOR TODAY',
                          style: TextStyle(
                            fontSize: 7 * scale,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withAlpha(120),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 4 * scale),
          // Right arrow
          _buildNavButton(
            context,
            Icons.chevron_right,
            () => userProvider.goToNextDay(),
            scale,
          ),
          SizedBox(width: 8 * scale),
          // Progress badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: (isSmallScreen ? 8 : 10) * scale,
              vertical: (isSmallScreen ? 4 : 5) * scale,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withAlpha(completed == 5 ? 80 : 40),
                  const Color(0xFF14B8A6).withAlpha(completed == 5 ? 60 : 25),
                ],
              ),
              borderRadius: BorderRadius.circular(10 * scale),
              border: Border.all(
                color: const Color(0xFF10B981).withAlpha(completed == 5 ? 100 : 50),
              ),
            ),
            child: Row(
              children: [
                if (completed == 5)
                  Padding(
                    padding: EdgeInsets.only(right: 4 * scale),
                    child: Icon(Icons.check_circle,
                                size: (isSmallScreen ? 12 : 14) * scale, color: const Color(0xFF10B981)),
                  ),
                Text(
                  '$completed/5',
                  style: TextStyle(
                    fontSize: (isSmallScreen ? 11 : 12) * scale,
                    fontWeight: FontWeight.w600,
                    color: completed == 5
                        ? const Color(0xFF10B981)
                        : Colors.white.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, IconData icon, VoidCallback onTap, double scale) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (isSmallScreen ? 28 : 32) * scale,
        height: (isSmallScreen ? 28 : 32) * scale,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(8 * scale),
          border: Border.all(color: Colors.white.withAlpha(20)),
        ),
        child: Icon(
          icon,
          size: (isSmallScreen ? 18 : 20) * scale,
          color: Colors.white.withAlpha(180),
        ),
      ),
    );
  }

  String _formatDateShort(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }

  Widget _buildNextPrayerCard(BuildContext context, double scale) {
    final userProvider = context.watch<UserProvider>();
    final nextPrayer = userProvider.nextPrayer;
    final user = userProvider.user;

    // Check if location is set
    if (user?.latitude == null || user?.longitude == null) {
      return GlassContainer(
        padding: EdgeInsets.all(20 * scale),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.location_off, size: 28 * scale, color: Colors.white.withAlpha(100)),
              SizedBox(height: 10 * scale),
              Text(
                'Set location in Settings',
                style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 13 * scale),
              ),
            ],
          ),
        ),
      );
    }

    // Loading state
    if (nextPrayer == null) {
      return GlassContainer(
        padding: EdgeInsets.all(20 * scale),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 4 * scale),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Text(
                'NEXT PRAYER',
                style: TextStyle(
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withAlpha(120),
                  letterSpacing: 1,
                ),
              ),
            ),
            SizedBox(height: 12 * scale),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16 * scale,
                  height: 16 * scale,
                  child: CircularProgressIndicator(
                    strokeWidth: 2 * scale,
                    color: Colors.white.withAlpha(150),
                  ),
                ),
                SizedBox(width: 10 * scale),
                Text(
                  'Loading...',
                  style: TextStyle(fontSize: 14 * scale, color: Colors.white.withAlpha(150)),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final timeUntil = nextPrayer.timeUntilAdhan;
    final hours = timeUntil.inHours;
    final minutes = timeUntil.inMinutes % 60;
    final seconds = timeUntil.inSeconds % 60;

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return GlassContainer(
      padding: EdgeInsets.all((isSmallScreen ? 14 : 18) * scale),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: (isSmallScreen ? 10 : 12) * scale,
              vertical: (isSmallScreen ? 3 : 4) * scale,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3B82F6).withAlpha(50),
                  const Color(0xFF8B5CF6).withAlpha(35),
                ],
              ),
              borderRadius: BorderRadius.circular(14 * scale),
              border: Border.all(color: const Color(0xFF3B82F6).withAlpha(60)),
            ),
            child: Text(
              'NEXT PRAYER',
              style: TextStyle(
                fontSize: (isSmallScreen ? 8 : 9) * scale,
                fontWeight: FontWeight.w700,
                color: Colors.white.withAlpha(200),
                letterSpacing: 1,
              ),
            ),
          ),
          SizedBox(height: (isSmallScreen ? 8 : 10) * scale),
          Text(
            nextPrayer.name,
            style: TextStyle(
              fontSize: (isSmallScreen ? 26 : 30) * scale,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: (isSmallScreen ? 10 : 14) * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeUnit(context, hours, 'h', scale),
              _buildTimeSeparator(context, scale),
              _buildTimeUnit(context, minutes, 'm', scale),
              _buildTimeSeparator(context, scale),
              _buildTimeUnit(context, seconds, 's', scale),
            ],
          ),
          SizedBox(height: (isSmallScreen ? 10 : 14) * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeChip(context, 'Adhan', _formatTime(nextPrayer.adhanTime), scale),
              SizedBox(width: (isSmallScreen ? 8 : 12) * scale),
              _buildTimeChip(context, 'Iqama', _formatTime(nextPrayer.iqamaTime), scale),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeUnit(BuildContext context, int value, String label, double scale) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (isSmallScreen ? 6 : 8) * scale,
        vertical: (isSmallScreen ? 4 : 6) * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(8 * scale),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            value.toString().padLeft(2, '0'),
            style: TextStyle(
              fontSize: (isSmallScreen ? 22 : 26) * scale,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: (isSmallScreen ? 3 : 4) * scale, left: 1 * scale),
            child: Text(
              label,
              style: TextStyle(
                fontSize: (isSmallScreen ? 10 : 11) * scale,
                fontWeight: FontWeight.w500,
                color: Colors.white.withAlpha(120),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSeparator(BuildContext context, double scale) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: (isSmallScreen ? 2 : 3) * scale),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: (isSmallScreen ? 18 : 22) * scale,
          fontWeight: FontWeight.w300,
          color: Colors.white.withAlpha(80),
        ),
      ),
    );
  }

  Widget _buildTimeChip(BuildContext context, String label, String time, double scale) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (isSmallScreen ? 8 : 10) * scale,
        vertical: (isSmallScreen ? 5 : 6) * scale,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(12),
        borderRadius: BorderRadius.circular(8 * scale),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: (isSmallScreen ? 9 : 10) * scale,
              color: Colors.white.withAlpha(120),
            ),
          ),
          SizedBox(width: (isSmallScreen ? 4 : 6) * scale),
          Text(
            time,
            style: TextStyle(
              fontSize: (isSmallScreen ? 11 : 12) * scale,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildPrayerTimesList(BuildContext context, double scale) {
    final userProvider = context.watch<UserProvider>();
    final prayerTimes = userProvider.todayPrayerTimes;
    final nextPrayer = userProvider.nextPrayer;
    final user = userProvider.user;
    final isToday = userProvider.isSelectedDateToday;

    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    // If no location set, show message
    if (user?.latitude == null || user?.longitude == null) {
      return GlassContainer(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          children: [
            Icon(Icons.location_off, size: 48 * scale, color: Colors.white.withAlpha(100)),
            SizedBox(height: 16 * scale),
            Text(
              'Set your location in Settings',
              style: TextStyle(
                fontSize: 16 * scale,
                color: Colors.white.withAlpha(180),
              ),
            ),
            SizedBox(height: 8 * scale),
            Text(
              'to see prayer times',
              style: TextStyle(
                fontSize: 14 * scale,
                color: Colors.white.withAlpha(120),
              ),
            ),
          ],
        ),
      );
    }

    // If prayer times not loaded yet, show loading cards
    if (prayerTimes == null) {
      return Column(
        children: prayers.map((prayerName) {
          final isCompleted = userProvider.isPrayerCompletedForSelectedDate(prayerName);
          return PrayerCard(
            name: prayerName,
            adhanTime: '--:--',
            iqamaTime: '--:--',
            isCompleted: isCompleted,
            isNext: false,
            onToggle: () => userProvider.togglePrayerForSelectedDate(prayerName),
            scale: scale,
          );
        }).toList(),
      );
    }

    return Column(
      children: prayers.map((prayerName) {
        final timeStr = prayerTimes.timesMap[prayerName];
        if (timeStr == null) return const SizedBox.shrink();

        final iqamaOffset = userProvider.user?.iqamaOffsets[prayerName] ?? 0;
        final adhanTime = prayerTimes.parseTime(timeStr);
        final iqamaTime = adhanTime.add(Duration(minutes: iqamaOffset));
        final isCompleted = userProvider.isPrayerCompletedForSelectedDate(prayerName);
        // Only show "NEXT" badge if viewing today
        final isNext = isToday && nextPrayer?.name == prayerName;

        return PrayerCard(
          name: prayerName,
          adhanTime: timeStr,
          iqamaTime: _formatTime(iqamaTime),
          isCompleted: isCompleted,
          isNext: isNext,
          onToggle: () => userProvider.togglePrayerForSelectedDate(prayerName),
          scale: scale,
        );
      }).toList(),
    );
  }

  Widget _buildQadaCard(BuildContext context, double scale) {
    final userProvider = context.watch<UserProvider>();
    final qada = userProvider.qada;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    if (qada == null || qada.totalMissedPrayers == 0) {
      return const SizedBox.shrink();
    }

    final progress = qada.totalMissedPrayers > 0
        ? qada.completedPrayers / qada.totalMissedPrayers
        : 0.0;

    return GlassContainer(
      padding: EdgeInsets.all((isSmallScreen ? 12 : 14) * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qada Progress',
                style: TextStyle(
                  fontSize: (isSmallScreen ? 13 : 14) * scale,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withAlpha(230),
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: (isSmallScreen ? 11 : 12) * scale,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF10B981).withAlpha(230),
                ),
              ),
            ],
          ),
          SizedBox(height: (isSmallScreen ? 8 : 10) * scale),
          // Custom progress bar
          Container(
            height: (isSmallScreen ? 5 : 6) * scale,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(3 * scale),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                  ),
                  borderRadius: BorderRadius.circular(3 * scale),
                ),
              ),
            ),
          ),
          SizedBox(height: (isSmallScreen ? 8 : 10) * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQadaStat(context, 'Remaining', qada.remainingPrayers, Colors.white, scale),
              _buildQadaStat(context, 'Completed', qada.completedPrayers, const Color(0xFF10B981), scale),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQadaStat(BuildContext context, String label, int value, Color color, double scale) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: (isSmallScreen ? 9 : 10) * scale,
            color: Colors.white.withAlpha(120),
          ),
        ),
        SizedBox(height: 1 * scale),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: (isSmallScreen ? 14 : 16) * scale,
            fontWeight: FontWeight.w600,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

/// Modern Prayer Card with checkbox functionality
class PrayerCard extends StatelessWidget {
  final String name;
  final String adhanTime;
  final String iqamaTime;
  final bool isCompleted;
  final bool isNext;
  final VoidCallback onToggle;
  final double scale;

  const PrayerCard({
    super.key,
    required this.name,
    required this.adhanTime,
    required this.iqamaTime,
    required this.isCompleted,
    required this.isNext,
    required this.onToggle,
    required this.scale,
  });

  IconData _getPrayerIcon() {
    switch (name) {
      case 'Fajr':
        return Icons.wb_twilight;
      case 'Dhuhr':
        return Icons.wb_sunny;
      case 'Asr':
        return Icons.sunny_snowing;
      case 'Maghrib':
        return Icons.nights_stay_outlined;
      case 'Isha':
        return Icons.nightlight_round;
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    return Container(
      margin: EdgeInsets.only(bottom: (isSmallScreen ? 8 : 10) * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isNext
              ? [
                  const Color(0xFF3B82F6).withAlpha(40),
                  const Color(0xFF8B5CF6).withAlpha(25),
                ]
              : [
                  Colors.white.withAlpha(12),
                  Colors.white.withAlpha(6),
                ],
        ),
        borderRadius: BorderRadius.circular((isSmallScreen ? 12 : 14) * scale),
        border: Border.all(
          color: isNext
              ? const Color(0xFF3B82F6).withAlpha(60)
              : Colors.white.withAlpha(15),
          width: (isNext ? 1.5 : 1) * scale,
        ),
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: const Color(0xFF3B82F6).withAlpha(30),
                  blurRadius: 16 * scale,
                  offset: Offset(0, 3 * scale),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular((isSmallScreen ? 12 : 14) * scale),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular((isSmallScreen ? 12 : 14) * scale),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: (isSmallScreen ? 10 : 12) * scale,
                  vertical: (isSmallScreen ? 10 : 12) * scale,
                ),
                child: Row(
                  children: [
                    // Checkbox
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: (isSmallScreen ? 20 : 22) * scale,
                      height: (isSmallScreen ? 20 : 22) * scale,
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? const LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF14B8A6)],
                              )
                            : null,
                        color: isCompleted ? null : Colors.transparent,
                        borderRadius: BorderRadius.circular((isSmallScreen ? 5 : 6) * scale),
                        border: Border.all(
                          color: isCompleted
                              ? Colors.transparent
                              : Colors.white.withAlpha(60),
                          width: (isSmallScreen ? 1.5 : 2) * scale,
                        ),
                      ),
                      child: isCompleted
                          ? Icon(Icons.check, size: (isSmallScreen ? 12 : 14) * scale, color: Colors.white)
                          : null,
                    ),
                    SizedBox(width: (isSmallScreen ? 8 : 10) * scale),
                    // Prayer icon
                    Container(
                      width: (isSmallScreen ? 32 : 36) * scale,
                      height: (isSmallScreen ? 32 : 36) * scale,
                      decoration: BoxDecoration(
                        color: isNext
                            ? const Color(0xFF3B82F6).withAlpha(30)
                            : Colors.white.withAlpha(10),
                        borderRadius: BorderRadius.circular((isSmallScreen ? 8 : 9) * scale),
                      ),
                      child: Icon(
                        _getPrayerIcon(),
                        size: (isSmallScreen ? 16 : 18) * scale,
                        color: isNext
                            ? const Color(0xFF60A5FA)
                            : Colors.white.withAlpha(180),
                      ),
                    ),
                    SizedBox(width: (isSmallScreen ? 8 : 10) * scale),
                    // Prayer name and times
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontSize: (isSmallScreen ? 13 : 14) * scale,
                                  fontWeight: isNext ? FontWeight.w600 : FontWeight.w500,
                                  color: isCompleted
                                      ? Colors.white.withAlpha(120)
                                      : Colors.white,
                                  decoration: isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: Colors.white.withAlpha(60),
                                ),
                              ),
                              if (isNext) ...[
                                SizedBox(width: (isSmallScreen ? 5 : 6) * scale),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: (isSmallScreen ? 5 : 6) * scale, vertical: 1 * scale),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                                    ),
                                    borderRadius: BorderRadius.circular(4 * scale),
                                  ),
                                  child: Text(
                                    'NEXT',
                                    style: TextStyle(
                                      fontSize: (isSmallScreen ? 7 : 8) * scale,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: (isSmallScreen ? 2 : 3) * scale),
                          Text(
                            'Iqama: $iqamaTime',
                            style: TextStyle(
                              fontSize: (isSmallScreen ? 10 : 11) * scale,
                              color: Colors.white.withAlpha(100),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Adhan time
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          adhanTime,
                          style: TextStyle(
                            fontSize: (isSmallScreen ? 14 : 16) * scale,
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? Colors.white.withAlpha(120)
                                : Colors.white,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        Text(
                          'Adhan',
                          style: TextStyle(
                            fontSize: (isSmallScreen ? 9 : 10) * scale,
                            color: Colors.white.withAlpha(80),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

