import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/ramadan_service.dart';
import '../services/prayer_service.dart';
import '../models/ramadan_model.dart';
import '../models/prayer_times_model.dart';
import '../widgets/glass_container.dart';
import '../widgets/cosmic_background.dart';
import '../constants/app_theme.dart';

class RamadanScreen extends StatefulWidget {
  const RamadanScreen({super.key});

  @override
  State<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends State<RamadanScreen> {
  List<RamadanPeriod> _ramadanHistory = [];
  int _selectedRamadanIndex = 0;
  PrayerTimesModel? _todayPrayerTimes;
  final PrayerService _prayerService = PrayerService();

  @override
  void initState() {
    super.initState();
    _loadRamadanHistory();
    _loadTodayPrayerTimes();
  }

  void _loadRamadanHistory() {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;

    if (user?.maturityDate != null) {
      setState(() {
        _ramadanHistory = RamadanService.calculateRamadanHistory(user!.maturityDate!);
        if (_ramadanHistory.isNotEmpty) {
          _selectedRamadanIndex = _ramadanHistory.length - 1; // Most recent
        }
      });
    }
  }

  Future<void> _loadTodayPrayerTimes() async {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;
    
    if (user?.latitude != null && user?.longitude != null) {
      final times = await _prayerService.getTodayPrayerTimes(
        latitude: user!.latitude!,
        longitude: user.longitude!,
      );
      if (mounted) {
        setState(() {
          _todayPrayerTimes = times;
        });
      }
    }
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return time;
    }
  }

  Duration? _getTimeUntilIftar() {
    if (_todayPrayerTimes == null) return null;
    try {
      final now = DateTime.now();
      final maghribParts = _todayPrayerTimes!.maghrib.split(':');
      final maghribHour = int.parse(maghribParts[0]);
      final maghribMinute = int.parse(maghribParts[1]);
      
      var maghribTime = DateTime(now.year, now.month, now.day, maghribHour, maghribMinute);
      if (maghribTime.isBefore(now)) {
        maghribTime = maghribTime.add(const Duration(days: 1));
      }
      return maghribTime.difference(now);
    } catch (e) {
      return null;
    }
  }

  Duration? _getTimeUntilSuhoor() {
    if (_todayPrayerTimes == null) return null;
    try {
      final now = DateTime.now();
      final fajrParts = _todayPrayerTimes!.fajr.split(':');
      final fajrHour = int.parse(fajrParts[0]);
      final fajrMinute = int.parse(fajrParts[1]);
      
      var fajrTime = DateTime(now.year, now.month, now.day, fajrHour, fajrMinute);
      if (fajrTime.isBefore(now)) {
        fajrTime = fajrTime.add(const Duration(days: 1));
      }
      return fajrTime.difference(now);
    } catch (e) {
      return null;
    }
  }

  String _formatCountdown(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return '${hours}h ${minutes}m ${seconds}s';
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final ramadan = userProvider.ramadan;
    final double scaleFactor = user?.uiScale ?? 1.0;

    // Back Button
    final backButton = SafeArea(
      child: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.only(left: 16, top: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withAlpha(100),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withAlpha(20)),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
      ),
    );

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(scaleFactor),
      ),
      child: CosmicBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              _buildContent(context, user, ramadan, scaleFactor),
              Positioned(top: 0, left: 0, child: backButton),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic user, dynamic ramadan, double scale) {
    if (user?.maturityDate == null) {
      return Center(
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month_rounded, size: 64, color: Colors.white.withAlpha(150)),
              const SizedBox(height: 24),
              const Text(
                'SETUP REQUIRED',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please set your date of birth in settings to track Ramadan.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    if (_ramadanHistory.isEmpty) {
      return Center(
        child: GlassContainer(
          padding: const EdgeInsets.all(32),
          child: const Text(
            'No Ramadan history available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    final selectedRamadan = _ramadanHistory[_selectedRamadanIndex];
    final fastedDays = ramadan?.getFastedDaysCount(
          selectedRamadan.year,
          selectedRamadan.month,
        ) ?? 0;
    final isCurrentlyRamadan = selectedRamadan.year == DateTime.now().year && 
                                selectedRamadan.month == DateTime.now().month;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 80, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Text(
            'RAMADAN TRACKER',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 32),

          // Iftar & Suhoor Times (for current Ramadan)
          if (isCurrentlyRamadan) ...[
            _buildMealTimesCard(scale),
            const SizedBox(height: 24),
          ],

          // Year Selector & Progress
          GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavButton(
                      icon: Icons.arrow_back_ios_rounded,
                      onTap: _selectedRamadanIndex > 0
                          ? () => setState(() => _selectedRamadanIndex--)
                          : null,
                    ),
                    Column(
                      children: [
                        Text(
                          '${selectedRamadan.year}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          'Ramadan',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.accentGold.withAlpha(200),
                            letterSpacing: 4,
                          ),
                        ),
                      ],
                    ),
                    _buildNavButton(
                      icon: Icons.arrow_forward_ios_rounded,
                      onTap: _selectedRamadanIndex < _ramadanHistory.length - 1
                          ? () => setState(() => _selectedRamadanIndex++)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                
                // Custom Progress Bar
                Stack(
                  children: [
                    Container(
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white.withAlpha(10)),
                      ),
                    ),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          height: 28,
                          width: constraints.maxWidth * (fastedDays / 30),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.accentGold, Color(0xFFFFA000)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentGold.withAlpha(100),
                                blurRadius: 20,
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Text(
                          '$fastedDays / 30 DAYS COMPLETED',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(color: Colors.black, blurRadius: 4),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Stats Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatItem('Fasted', '$fastedDays', AppTheme.accentGold),
                    Container(width: 1, height: 40, color: Colors.white.withAlpha(20)),
                    _buildStatItem('Remaining', '${30 - fastedDays}', Colors.white70),
                    Container(width: 1, height: 40, color: Colors.white.withAlpha(20)),
                    _buildStatItem('Progress', '${((fastedDays / 30) * 100).toInt()}%', const Color(0xFF10B981)),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),

          // Calendar Grid
          GlassContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'FASTING LOG',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withAlpha(20),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.accentGold.withAlpha(50)),
                      ),
                      child: const Text(
                        'TAP TO TOGGLE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentGold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: 30,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isFasted = ramadan?.isDayFasted(
                          selectedRamadan.year,
                          selectedRamadan.month,
                          day,
                        ) ?? false;
                    final isToday = isCurrentlyRamadan && day == DateTime.now().day;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isFasted) {
                            ramadan?.unmarkDayFasted(
                              selectedRamadan.year,
                              selectedRamadan.month, day,
                            );
                          } else {
                            ramadan?.markDayFasted(
                              selectedRamadan.year,
                              selectedRamadan.month, day,
                            );
                          }
                          ramadan?.save();
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isFasted
                              ? AppTheme.accentGold.withAlpha(40)
                              : Colors.white.withAlpha(5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isToday 
                                ? const Color(0xFF10B981)
                                : (isFasted ? AppTheme.accentGold : Colors.white.withAlpha(20)),
                            width: isToday ? 2 : (isFasted ? 1.5 : 1),
                          ),
                          boxShadow: [
                            if (isFasted)
                              BoxShadow(
                                color: AppTheme.accentGold.withAlpha(50),
                                blurRadius: 10,
                                spreadRadius: 0,
                              ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  color: isFasted ? Colors.white : Colors.white.withAlpha(100),
                                  fontWeight: isFasted ? FontWeight.bold : FontWeight.w400,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (isToday)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTimesCard(double scale) {
    final iftarDuration = _getTimeUntilIftar();
    final suhoorDuration = _getTimeUntilSuhoor();
    
    return GlassContainer(
      padding: EdgeInsets.all(20 * scale),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TODAY\'S TIMES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981).withAlpha(50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time, size: 12 * scale, color: const Color(0xFF10B981)),
                    SizedBox(width: 4 * scale),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16 * scale),
          Row(
            children: [
              // Suhoor
              Expanded(
                child: _buildMealTimeItem(
                  icon: Icons.bedtime_outlined,
                  label: 'SUHOOR',
                  time: _todayPrayerTimes != null ? _formatTime(_todayPrayerTimes!.fajr) : '--:--',
                  color: const Color(0xFF6366F1),
                  scale: scale,
                ),
              ),
              SizedBox(width: 12 * scale),
              // Iftar
              Expanded(
                child: _buildMealTimeItem(
                  icon: Icons.restaurant_outlined,
                  label: 'IFTAR',
                  time: _todayPrayerTimes != null ? _formatTime(_todayPrayerTimes!.maghrib) : '--:--',
                  color: AppTheme.accentGold,
                  scale: scale,
                ),
              ),
            ],
          ),
          if (iftarDuration != null || suhoorDuration != null) ...[
            SizedBox(height: 16 * scale),
            const Divider(color: Colors.white24),
            SizedBox(height: 12 * scale),
            // Countdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (iftarDuration != null)
                  _buildCountdownItem(
                    label: 'Until Iftar',
                    duration: _formatCountdown(iftarDuration),
                    icon: Icons.restaurant,
                    color: AppTheme.accentGold,
                  ),
                if (suhoorDuration != null)
                  _buildCountdownItem(
                    label: 'Until Suhoor',
                    duration: _formatCountdown(suhoorDuration),
                    icon: Icons.bedtime,
                    color: const Color(0xFF6366F1),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealTimeItem({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
    required double scale,
  }) {
    return Container(
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28 * scale),
          SizedBox(height: 8 * scale),
          Text(
            label,
            style: TextStyle(
              fontSize: 10 * scale,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            time,
            style: TextStyle(
              fontSize: 14 * scale,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownItem({
    required String label,
    required String duration,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withAlpha(150),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          duration,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withAlpha(150),
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton({required IconData icon, VoidCallback? onTap}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final isMedium = screenWidth < 400;
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final double scaleFactor = user?.uiScale ?? 1.0;
    final padding = (isCompact ? 12 : isMedium ? 13 : 14) * scaleFactor;
    final iconSize = (isCompact ? 18 : isMedium ? 20 : 22) * scaleFactor;
    
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: EdgeInsets.all(padding),
        variant: GlassVariant.standard,
        child: Opacity(
          opacity: onTap != null ? 1.0 : 0.3,
          child: Icon(icon, color: Colors.white, size: iconSize),
        ),
      ),
    );
  }
}
