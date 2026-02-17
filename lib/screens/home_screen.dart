import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hijri_calendar/hijri_calendar.dart';
import '../providers/user_provider.dart';
import '../widgets/glass_container.dart';
import '../constants/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return '${days[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
  }

  String _formatHijriDate(DateTime date) {
    final hijri = HijriCalendarConfig.fromGregorian(date);
    return '${hijri.hDay} ${hijri.getLongMonthName()} ${hijri.hYear} AH';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final scale = userProvider.user?.uiScale ?? 1.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final horizontalPadding = (isSmallScreen ? 14.0 : 18.0) * scale;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(horizontalPadding, 64 * scale, horizontalPadding, 110 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGreeting(context, scale),
          SizedBox(height: 20 * scale),
          _buildHeroCountdown(context, scale),
          SizedBox(height: 20 * scale),
          _buildDateNavigation(context, scale),
          SizedBox(height: 14 * scale),
          _buildPrayerTimesList(context, scale),
          SizedBox(height: 18 * scale),
          _buildQadaCard(context, scale),
          SizedBox(height: 16 * scale),
        ],
      ),
    );
  }

  // ─── Greeting Section ───
  Widget _buildGreeting(BuildContext context, double scale) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final city = user?.city;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final now = DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTheme.getGreeting(),
          style: TextStyle(
            fontSize: (isSmallScreen ? 28 : 34) * scale,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1,
            height: 1.2,
          ),
        ),
        SizedBox(height: 4 * scale),
        Row(
          children: [
            Text(
              AppTheme.getGreetingSubtitle(),
              style: TextStyle(
                fontSize: (isSmallScreen ? 13 : 15) * scale,
                fontWeight: FontWeight.w400,
                color: Colors.white.withAlpha(120),
              ),
            ),
            if (city != null && city.isNotEmpty) ...[
              SizedBox(width: 8 * scale),
              Container(
                width: 3,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(60),
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8 * scale),
              Icon(Icons.location_on_outlined,
                  color: Colors.white.withAlpha(100), size: 14 * scale),
              SizedBox(width: 2 * scale),
              Text(
                city,
                style: TextStyle(
                  fontSize: (isSmallScreen ? 12 : 13) * scale,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withAlpha(100),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 4 * scale),
        Row(
          children: [
            Text(
              _formatDate(now),
              style: TextStyle(
                fontSize: (isSmallScreen ? 11 : 12) * scale,
                fontWeight: FontWeight.w500,
                color: Colors.white.withAlpha(80),
              ),
            ),
            SizedBox(width: 8 * scale),
            Text(
              '•',
              style: TextStyle(
                fontSize: 10 * scale,
                color: Colors.white.withAlpha(40),
              ),
            ),
            SizedBox(width: 8 * scale),
            Text(
              _formatHijriDate(now),
              style: TextStyle(
                fontSize: (isSmallScreen ? 11 : 12) * scale,
                fontWeight: FontWeight.w500,
                color: AppTheme.accentGold.withAlpha(120),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Circular Countdown Hero ───
  Widget _buildHeroCountdown(BuildContext context, double scale) {
    final userProvider = context.watch<UserProvider>();
    final nextPrayer = userProvider.nextPrayer;
    final user = userProvider.user;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    if (user?.latitude == null || user?.longitude == null) {
      return GlassContainer(
        variant: GlassVariant.elevated,
        padding: EdgeInsets.all(28 * scale),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.location_off_rounded, size: 40 * scale,
                  color: Colors.white.withAlpha(100)),
              SizedBox(height: 14 * scale),
              Text(
                'Set location in Settings',
                style: TextStyle(color: Colors.white.withAlpha(150),
                    fontSize: 14 * scale, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    if (nextPrayer == null) {
      return GlassContainer(
        variant: GlassVariant.elevated,
        padding: EdgeInsets.all(40 * scale),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                width: 40 * scale,
                height: 40 * scale,
                child: CircularProgressIndicator(
                  strokeWidth: 2 * scale,
                  color: AppTheme.primaryTeal.withAlpha(100),
                ),
              ),
              SizedBox(height: 16 * scale),
              Text(
                'CALCULATING...',
                style: TextStyle(
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryTeal.withAlpha(150),
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final timeUntil = nextPrayer.timeUntilAdhan;
    final totalSeconds = timeUntil.inSeconds;
    
    int maxSeconds = 6 * 3600; 
    if (nextPrayer.previousAdhanTime != null) {
      maxSeconds = nextPrayer.adhanTime.difference(nextPrayer.previousAdhanTime!).inSeconds;
    }
    if (maxSeconds <= 0) maxSeconds = 6 * 3600;
    
    final progress = 1.0 - (totalSeconds.clamp(0, maxSeconds) / maxSeconds).clamp(0.0, 1.0);
    final hours = timeUntil.inHours;
    final minutes = timeUntil.inMinutes % 60;
    final seconds = timeUntil.inSeconds % 60;
    final prayerColor = AppTheme.getPrayerColor(nextPrayer.name);
    final prayerAccent = AppTheme.getPrayerAccent(nextPrayer.name);
    final ringSize = (isSmallScreen ? 220.0 : 260.0) * scale;

    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: ringSize * 0.84,
            height: ringSize * 0.84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  prayerColor.withAlpha(40),
                  prayerColor.withAlpha(20),
                  Colors.transparent,
                ],
                stops: const [0.12, 0.5, 1.0],
              ),
            ),
          ),
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: AnimatedBuilder(
              animation: _ringController,
              builder: (context, child) {
                return RepaintBoundary(
                  child: CustomPaint(
                    painter: _CountdownRingPainter(
                      progress: progress,
                      prayerColor: prayerColor,
                      prayerAccent: prayerAccent,
                      pulseValue: _ringController.value,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'UPCOMING',
                            style: TextStyle(
                              fontSize: 10 * scale,
                              fontWeight: FontWeight.w800,
                              color: prayerAccent.withAlpha(200),
                              letterSpacing: 3,
                            ),
                          ),
                          SizedBox(height: 12 * scale),
                          Text(
                            nextPrayer.name,
                            style: TextStyle(
                              fontSize: (isSmallScreen ? 36 : 42) * scale,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -1,
                              height: 1.0,
                              shadows: [
                                BoxShadow(
                                  color: prayerColor.withAlpha(100),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 8 * scale),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              _buildTimerUnit(hours, 'H', scale),
                              _buildTimerSeparator(scale),
                              _buildTimerUnit(minutes, 'M', scale),
                              _buildTimerSeparator(scale),
                              _buildTimerUnit(seconds, 'S', scale, isSeconds: true),
                            ],
                          ),
                          SizedBox(height: 16 * scale),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildTimePill('ADHAN', _formatTime(nextPrayer.adhanTime), scale, false, prayerColor),
                              SizedBox(width: 8 * scale),
                              _buildTimePill('IQAMA', _formatTime(nextPrayer.iqamaTime), scale, true, prayerColor),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerUnit(int value, String label, double scale, {bool isSeconds = false}) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: TextStyle(
            fontSize: (isSeconds ? 20 : 28) * scale,
            fontWeight: FontWeight.w300,
            color: Colors.white,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildTimerSeparator(double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4 * scale),
      child: Text(
        ':',
        style: TextStyle(
          fontSize: 20 * scale,
          color: Colors.white.withAlpha(100),
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }

  Widget _buildTimePill(String label, String time, double scale, bool isAccented, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 10 * scale),
      decoration: BoxDecoration(
        color: isAccented ? color.withAlpha(15) : Colors.transparent,
        borderRadius: BorderRadius.circular(16 * scale),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9 * scale,
              color: isAccented ? color : Colors.white.withAlpha(80),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(width: 8 * scale),
          Text(
            time,
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: isAccented ? Colors.white : Colors.white.withAlpha(180),
              fontFeatures: const [FontFeature.tabularFigures()],
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

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(5),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Row(
        children: [
          _buildNavButton(context, Icons.chevron_left_rounded,
              () => userProvider.goToPreviousDay(), scale),
          Expanded(
            child: GestureDetector(
              onTap: isToday ? null : () => userProvider.goToToday(),
              child: Container(
                color: Colors.transparent,
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      isToday ? 'Today' : _formatDateShort(selectedDate),
                      style: TextStyle(
                        fontSize: (isSmallScreen ? 14 : 15) * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withAlpha(230),
                      ),
                    ),
                    if (!isToday)
                      Padding(
                        padding: EdgeInsets.only(top: 2 * scale),
                        child: Text(
                          'TAP FOR TODAY',
                          style: TextStyle(
                            fontSize: 8 * scale,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentGold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          _buildNavButton(context, Icons.chevron_right_rounded,
              () => userProvider.goToNextDay(), scale),
          if (completed == 5) ...[
            SizedBox(width: 8 * scale),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 5 * scale),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981).withAlpha(30),
                    const Color(0xFF14B8A6).withAlpha(20),
                  ],
                ),
                borderRadius: BorderRadius.circular(10 * scale),
                border: Border.all(color: const Color(0xFF10B981).withAlpha(50)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: 14 * scale,
                      color: const Color(0xFF10B981)),
                  SizedBox(width: 4 * scale),
                  Text(
                    '5/5',
                    style: TextStyle(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavButton(BuildContext context, IconData icon, VoidCallback onTap, double scale) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final isMedium = screenWidth < 400;
    final buttonSize = (isCompact ? 30 : isMedium ? 32 : 36) * scale;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular((isCompact ? 10 : 12) * scale),
          border: Border.all(
            color: Colors.white.withAlpha(15),
            width: isCompact ? 0.8 : 1.0,
          ),
        ),
        child: Icon(
          icon,
          size: (isCompact ? 18 : isMedium ? 20 : 22) * scale,
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

  Widget _buildPrayerTimesList(BuildContext context, double scale) {
    final userProvider = context.watch<UserProvider>();
    final prayerTimes = userProvider.todayPrayerTimes;
    final nextPrayer = userProvider.nextPrayer;
    final user = userProvider.user;
    final isToday = userProvider.isSelectedDateToday;

    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    if (user?.latitude == null || user?.longitude == null) {
      return GlassContainer(
        padding: EdgeInsets.all(24 * scale),
        child: Column(
          children: [
            Icon(Icons.location_off_rounded, size: 48 * scale,
                color: Colors.white.withAlpha(100)),
            SizedBox(height: 16 * scale),
            Text('Set your location in Settings',
              style: TextStyle(fontSize: 16 * scale, color: Colors.white.withAlpha(180))),
            SizedBox(height: 8 * scale),
            Text('to see prayer times',
              style: TextStyle(fontSize: 14 * scale, color: Colors.white.withAlpha(120))),
          ],
        ),
      );
    }

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

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildQadaCard(BuildContext context, double scale) {
    final userProvider = context.watch<UserProvider>();
    final qada = userProvider.qada;
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    if (qada == null || qada.totalMissedPrayers == 0) {
      return const SizedBox.shrink();
    }

    final progress = qada.completedPrayers / qada.totalMissedPrayers;

    return GlassContainer(
      padding: EdgeInsets.all((isSmallScreen ? 12 : 16) * scale),
      child: Row(
        children: [
          SizedBox(
            width: 44 * scale,
            height: 44 * scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3 * scale,
                  backgroundColor: Colors.white.withAlpha(20),
                  color: AppTheme.successGreen,
                ),
                Icon(Icons.replay_rounded,
                    size: 20 * scale, color: AppTheme.successGreen),
              ],
            ),
          ),
          SizedBox(width: 16 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Missed Prayers',
                  style: TextStyle(
                    fontSize: (isSmallScreen ? 13 : 14) * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withAlpha(230),
                  ),
                ),
                SizedBox(height: 4 * scale),
                Row(
                  children: [
                    Text(
                      '${qada.completedPrayers} done',
                      style: TextStyle(
                        fontSize: (isSmallScreen ? 11 : 12) * scale,
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      ' / ${qada.remainingPrayers} left',
                      style: TextStyle(
                        fontSize: (isSmallScreen ? 11 : 12) * scale,
                        color: Colors.white.withAlpha(120),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Icon(Icons.chevron_right_rounded,
                color: Colors.white.withAlpha(150), size: 18 * scale),
          ),
        ],
      ),
    );
  }
}

class _CountdownRingPainter extends CustomPainter {
  final double progress;
  final Color prayerColor;
  final Color prayerAccent;
  final double pulseValue;

  _CountdownRingPainter({
    required this.progress,
    required this.prayerColor,
    required this.prayerAccent,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = 6.0;
    final pulseStroke = strokeWidth + (pulseValue * 2);
    const glowBlurSigma = 8.0;
    final safeInset = (pulseStroke / 2) + glowBlurSigma + 2;
    final rawRadius = (math.min(size.width, size.height) / 2) - safeInset;
    final radius = rawRadius > 0 ? rawRadius : 0.0;

    final bgPaint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 3 * math.pi / 2,
      tileMode: TileMode.clamp,
      colors: [prayerColor, prayerAccent, prayerColor],
      stops: const [0.0, 0.6, 1.0],
    );

    final progressPaint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final pulsePaint = Paint()
       ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius))
       ..style = PaintingStyle.stroke
       ..strokeWidth = pulseStroke
       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, glowBlurSigma);
    
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, sweepAngle, false, pulsePaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, sweepAngle, false, progressPaint);

    if (progress > 0.01) {
      final tipAngle = -math.pi / 2 + sweepAngle;
      final tipCenter = Offset(
        center.dx + radius * math.cos(tipAngle),
        center.dy + radius * math.sin(tipAngle),
      );
      canvas.drawCircle(tipCenter, 4 + pulseValue * 2, Paint()..color = Colors.white);
      canvas.drawCircle(tipCenter, 8 + pulseValue * 4, Paint()..color = prayerAccent.withAlpha(100));
    }
  }

  @override
  bool shouldRepaint(_CountdownRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.prayerColor != prayerColor ||
      oldDelegate.prayerAccent != prayerAccent ||
      oldDelegate.pulseValue != pulseValue;
}

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

  @override
  Widget build(BuildContext context) {
    final prayerColor = AppTheme.getPrayerColor(name);
    final prayerAccent = AppTheme.getPrayerAccent(name);
    final prayerIcon = AppTheme.getPrayerIcon(name);

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        margin: EdgeInsets.only(bottom: (isNext ? 12 : 8) * scale),
        transform: isNext ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
        child: GlassContainer(
          padding: EdgeInsets.zero,
          variant: isNext ? GlassVariant.elevated : GlassVariant.standard,
          accentColor: isNext ? prayerColor : null,
          child: Container(
            height: (isNext ? 80 : 64) * scale,
            decoration: BoxDecoration(
               color: isNext ? prayerColor.withAlpha(15) : Colors.transparent,
               borderRadius: BorderRadius.circular(24 * scale),
            ),
            child: Row(
              children: [
                Container(
                  width: (isNext ? 70 : 60) * scale,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: isNext ? prayerColor.withAlpha(30) : Colors.white.withAlpha(5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24 * scale),
                      bottomLeft: Radius.circular(24 * scale),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      prayerIcon,
                      color: isNext ? prayerAccent : Colors.white.withAlpha(150),
                      size: (isNext ? 28 : 22) * scale,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: (isNext ? 18 : 16) * scale,
                                fontWeight: isNext ? FontWeight.w700 : FontWeight.w600,
                                color: isCompleted ? Colors.white.withAlpha(120) : Colors.white,
                                decoration: isCompleted ? TextDecoration.lineThrough : null,
                                decorationColor: Colors.white.withAlpha(50),
                              ),
                            ),
                            if (isNext)
                            Padding(
                              padding: EdgeInsets.only(top: 4 * scale),
                              child: Text(
                                'Iqama $iqamaTime',
                                style: TextStyle(
                                  fontSize: 11 * scale,
                                  color: Colors.white.withAlpha(100),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                                adhanTime,
                                style: TextStyle(
                                  fontSize: (isNext ? 22 : 18) * scale,
                                  fontWeight: FontWeight.w600,
                                  color: isCompleted ? Colors.white.withAlpha(100) : Colors.white,
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                  decorationColor: Colors.white.withAlpha(50),
                                ),
                              ),
                              SizedBox(width: 12 * scale),
                              _buildCheckbox(isCompleted),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool isChecked) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 24 * scale,
      height: 24 * scale,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isChecked ? AppTheme.successGreen : Colors.transparent,
        border: Border.all(
          color: isChecked ? AppTheme.successGreen : Colors.white.withAlpha(40),
          width: 2,
        ),
        boxShadow: isChecked ? [
          BoxShadow(color: AppTheme.successGreen.withAlpha(100), blurRadius: 10),
        ] : [],
      ),
      child: isChecked
          ? Icon(Icons.check, color: Colors.white, size: 16 * scale)
          : null,
    );
  }
}
