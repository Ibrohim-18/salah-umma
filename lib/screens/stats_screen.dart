import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/falling_prayers_widget.dart';
import '../painters/time_of_day_mountain_painter.dart';
import '../painters/card_border_progress_painter.dart';
import '../painters/sparkline_painter.dart';
import '../constants/app_theme.dart';



class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with TickerProviderStateMixin {
  late AnimationController _fireController;

  @override
  void initState() {
    super.initState();
    
    // Fire/sparkle animation controller
    _fireController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _fireController.dispose();
    super.dispose();
  }

  static const List<String> _prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  List<DateTime> _lastSevenDays() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(const Duration(days: 6));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  int _completedCountForDate(UserProvider provider, DateTime date) {
    return provider.user?.getCompletedCountForDate(date) ?? 0;
  }

  bool _isFullDay(UserProvider provider, DateTime date) {
    return _completedCountForDate(provider, date) >= _prayers.length;
  }

  int _currentStreak(UserProvider provider) {
    var day = DateTime.now();
    day = DateTime(day.year, day.month, day.day);
    var streak = 0;
    while (_isFullDay(provider, day)) {
      streak += 1;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _longestStreak(UserProvider provider) {
    final user = provider.user;
    if (user == null || user.completedPrayersDaily.isEmpty) return 0;

    final fullDays = <DateTime>[];
    user.completedPrayersDaily.forEach((key, prayers) {
      if (prayers.length >= _prayers.length) {
        final parsed = _parseDateKey(key);
        if (parsed != null) fullDays.add(parsed);
      }
    });

    if (fullDays.isEmpty) return 0;
    fullDays.sort((a, b) => a.compareTo(b));

    var longest = 1;
    var current = 1;
    for (var i = 1; i < fullDays.length; i += 1) {
      final diff = fullDays[i].difference(fullDays[i - 1]).inDays;
      if (diff == 1) {
        current += 1;
      } else {
        current = 1;
      }
      if (current > longest) longest = current;
    }

    return longest;
  }

  DateTime? _parseDateKey(String key) {
    final parts = key.split('-');
    if (parts.length != 3) return null;
    try {
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  String _weekdayShort(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _weekdayShortFromDate(DateTime date) {
    return _weekdayShort(date.weekday);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final scale = userProvider.user?.uiScale ?? 1.0;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;
    final horizontalPadding = (isSmallScreen ? 12.0 : 16.0) * scale;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 64 * scale, horizontalPadding, 110 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTodaySummary(context, scale),
          SizedBox(height: 14 * scale),
          _buildStreaks(context, scale),
          SizedBox(height: 14 * scale),
          _buildWeeklySummary(context, scale),
          SizedBox(height: 14 * scale),
          _buildQadaProgress(context, scale),
          SizedBox(height: 20 * scale),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(BuildContext context, double scale) {
    final userProvider = context.watch<UserProvider>();
    final today = DateTime.now();
    final completedCount = _completedCountForDate(userProvider, today);
    final total = _prayers.length;
    final percent = total == 0 ? 0.0 : completedCount / total;
    final completedStates = _prayers
        .map((p) => userProvider.user?.isPrayerCompletedForDate(p, today) ?? false)
        .toList();
    final radius = 24 * scale;
    final borderWidth = 4.2 * scale;
    final borderPadding = 7.0 * scale;
    final borderRadius = radius + borderPadding - (borderWidth / 2);

    return AnimatedBuilder(
      animation: _fireController,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.all(borderPadding),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(
                    color: Colors.white.withAlpha(18),
                    width: 1.0 * scale,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(55),
                      blurRadius: 12 * scale,
                      offset: Offset(0, 4 * scale),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: TimeOfDayMountainPainter(now: DateTime.now()),
                        ),
                      ),
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFF173559).withAlpha(42),
                                const Color(0xFF173559).withAlpha(96),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          20 * scale,
                          18 * scale,
                          20 * scale,
                          2 * scale,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Today's Prayers",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20 * scale,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 3 * scale),
                                    Text(
                                      '$completedCount of $total completed',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(170),
                                        fontSize: 12 * scale,
                                      ),
                                    ),
                                  ],
                                ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 8 * scale),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGold.withAlpha(30),
                                      borderRadius: BorderRadius.circular(12 * scale),
                                      border: Border.all(
                                        color: AppTheme.accentGold.withAlpha(120),
                                      ),
                                    ),
                                    child: Text(
                                      '${(percent * 100).toInt()}%',
                                      style: TextStyle(
                                        color: AppTheme.accentGold,
                                        fontSize: 14.5 * scale,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 12 * scale),
                            SizedBox(
                              height: 138 * scale,
                              child: FallingPrayersWidget(
                                prayers: _prayers,
                                completed: completedStates,
                                scale: scale,
                                showCollision: false,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: CardBorderProgressPainter(
                    progress: percent,
                    animationValue: _fireController.value,
                    radius: borderRadius,
                    strokeWidth: borderWidth,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStreaks(BuildContext context, double scale) {
    final userProvider = context.watch<UserProvider>();
    final current = _currentStreak(userProvider);
    final longest = _longestStreak(userProvider);

    return Row(
      children: [
        Expanded(
          child: _buildStreakCard(
            title: 'Current Streak',
            value: '$current',
            suffix: 'days',
            icon: Icons.local_fire_department_rounded,
            color: const Color(0xFFFFB020),
            scale: scale,
          ),
        ),
        SizedBox(width: 14 * scale),
        Expanded(
          child: _buildStreakCard(
            title: 'Best Streak',
            value: '$longest',
            suffix: 'days',
            icon: Icons.emoji_events_rounded,
            color: AppTheme.accentGold,
            scale: scale,
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard({
    required String title,
    required String value,
    required String suffix,
    required IconData icon,
    required Color color,
    required double scale,
  }) {
    return GlassContainer(
      variant: GlassVariant.elevated,
      accentColor: color,
      padding: EdgeInsets.all(16 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30 * scale,
                height: 30 * scale,
                decoration: BoxDecoration(
                  color: color.withAlpha(22),
                  borderRadius: BorderRadius.circular(9 * scale),
                  border: Border.all(color: color.withAlpha(80)),
                ),
                child: Icon(icon, color: color, size: 16 * scale),
              ),
              SizedBox(width: 8 * scale),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11 * scale,
                  color: Colors.white.withAlpha(165),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12 * scale),
          RichText(
            text: TextSpan(
              text: value,
              style: TextStyle(
                fontSize: 26 * scale,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              children: [
                TextSpan(
                  text: ' $suffix',
                  style: TextStyle(
                    fontSize: 11 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withAlpha(135),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQadaProgress(BuildContext context, double scale) {
    final userProvider = context.watch<UserProvider>();
    final qada = userProvider.qada;

    if (qada == null || qada.totalMissedPrayers == 0) {
      return const SizedBox.shrink();
    }

    final progress = qada.totalMissedPrayers > 0
        ? qada.completedPrayers / qada.totalMissedPrayers
        : 0.0;

    return GlassContainer(
      padding: EdgeInsets.all(18 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qada Progress',
                style: TextStyle(
                  fontSize: 14 * scale,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withAlpha(220),
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentGold.withAlpha(220),
                ),
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          Container(
            height: 6 * scale,
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
                    colors: [AppTheme.accentGold, Color(0xFFFFB020)],
                  ),
                  borderRadius: BorderRadius.circular(3 * scale),
                ),
              ),
            ),
          ),
          SizedBox(height: 10 * scale),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildQadaStat(context, 'Remaining', qada.remainingPrayers, Colors.white, scale),
              _buildQadaStat(context, 'Completed', qada.completedPrayers, AppTheme.accentGold, scale),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySummary(BuildContext context, double scale) {
    final userProvider = context.watch<UserProvider>();
    final days = _lastSevenDays();
    final values = days
        .map((date) => _completedCountForDate(userProvider, date))
        .toList();
    final totalCompleted = values.fold<int>(0, (sum, v) => sum + v);
    final average = values.isEmpty ? 0.0 : totalCompleted / values.length;
    var bestIndex = 0;
    for (var i = 1; i < values.length; i += 1) {
      if (values[i] > values[bestIndex]) bestIndex = i;
    }
    final bestLabel = values.isEmpty ? '-' : _weekdayShortFromDate(days[bestIndex]);
    final bestValue = values.isEmpty ? 0 : values[bestIndex];
    final bestDate = values.isEmpty ? null : days[bestIndex];

    return GlassContainer(
      padding: EdgeInsets.all(18 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Weekly Summary',
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2 * scale),
                  Text(
                    'Last 7 days',
                    style: TextStyle(
                      fontSize: 10 * scale,
                      color: Colors.white.withAlpha(120),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10 * scale),
          Row(
            children: [
              _buildSummaryPill(
                label: 'Total',
                value: '$totalCompleted',
                scale: scale,
                accent: AppTheme.accentGold,
              ),
              SizedBox(width: 8 * scale),
              _buildSummaryPill(
                label: 'Avg/day',
                value: average.toStringAsFixed(1),
                scale: scale,
                accent: const Color(0xFFFFB020),
              ),
              SizedBox(width: 8 * scale),
              if (bestDate != null)
                GestureDetector(
                  onTap: () => _showDayDetails(context, bestDate, bestValue, scale),
                  child: _buildSummaryPill(
                    label: 'Best',
                    value: '$bestLabel $bestValue/5',
                    scale: scale,
                    accent: const Color(0xFFFFB020),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12 * scale),
          _buildWeeklyChart(context, scale),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, double scale) {
    final userProvider = context.watch<UserProvider>();
    final days = _lastSevenDays();
    final values = days
        .map((date) => _completedCountForDate(userProvider, date))
        .toList();
    const maxValue = 5.0;
    var bestIndex = 0;
    for (var i = 1; i < values.length; i += 1) {
      if (values[i] > values[bestIndex]) bestIndex = i;
    }

    return Container(
      height: 160 * scale,
      margin: EdgeInsets.only(top: 10 * scale),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              return Container(
                height: 1,
                color: Colors.white.withAlpha(5),
              );
            }),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: CustomPaint(
              size: Size.infinite,
                painter: SparklinePainter(
                  values: values,
                  maxValue: maxValue,
                  color: AppTheme.accentGold,
                ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(values.length, (index) {
                final isBest = index == bestIndex;
                return GestureDetector(
                   onTap: () => _showDayDetails(context, days[index], values[index], scale),
                   child: Container(
                     width: 30 * scale,
                     padding: EdgeInsets.only(top: 8 * scale),
                     child: Column(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                          if (isBest)
                            Icon(Icons.arrow_drop_up, color: AppTheme.accentGold, size: 16 * scale),
                          Text(
                             _weekdayShort(days[index].weekday),
                             style: TextStyle(
                               fontSize: 10 * scale,
                               color: isBest ? AppTheme.accentGold : Colors.white.withAlpha(100),
                               fontWeight: isBest ? FontWeight.w700 : FontWeight.w500,
                             ),
                          ),
                       ],
                     ),
                   ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPill({
    required String label,
    required String value,
    required double scale,
    required Color accent,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 6 * scale),
      decoration: BoxDecoration(
        color: accent.withAlpha(14),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: accent.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9 * scale,
              fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(140),
            ),
          ),
          SizedBox(height: 2 * scale),
          Text(
            value,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.bold,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }

  void _showDayDetails(BuildContext context, DateTime date, int value, double scale) {
    final label = '${_weekdayShort(date.weekday)} ${date.day.toString().padLeft(2, '0')}';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.all(16 * scale),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E14).withAlpha(245),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20 * scale)),
            border: Border.all(color: Colors.white.withAlpha(10)),
          ),
          child: Row(
            children: [
              Container(
                width: 38 * scale,
                height: 38 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB020).withAlpha(20),
                  borderRadius: BorderRadius.circular(10 * scale),
                  border: Border.all(color: const Color(0xFFFFB020).withAlpha(80)),
                ),
                child: Icon(Icons.star, color: const Color(0xFFFFB020), size: 18 * scale),
              ),
              SizedBox(width: 12 * scale),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected day',
                      style: TextStyle(
                        fontSize: 12 * scale,
                        color: Colors.white.withAlpha(150),
                      ),
                    ),
                    Text(
                      '$label - $value/5',
                      style: TextStyle(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  final provider = context.read<UserProvider>();
                  provider.setSelectedDate(date);
                  provider.requestTab(0);
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 6 * scale),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withAlpha(20),
                    borderRadius: BorderRadius.circular(10 * scale),
                    border: Border.all(color: AppTheme.accentGold.withAlpha(120)),
                  ),
                  child: Text(
                    'OPEN',
                    style: TextStyle(
                      fontSize: 10 * scale,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.accentGold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
          ),
        ),
      ],
    );
  }
}
