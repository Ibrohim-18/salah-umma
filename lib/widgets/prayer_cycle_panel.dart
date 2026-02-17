import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_theme.dart';
import '../models/prayer_times_model.dart';
import '../models/prayer_point_model.dart';
import '../painters/day_cycle_painter.dart';

class PrayerCyclePanel extends StatelessWidget {
  const PrayerCyclePanel({
    super.key,
    required this.scale,
    required this.todayDone,
    required this.prayerTimes,
  });

  final double scale;
  final int todayDone;
  final PrayerTimesModel? prayerTimes;

  @override
  Widget build(BuildContext context) {
    final points = _buildPrayerPoints(prayerTimes);
    final pointMap = {for (final point in points) point.label: point};

    final fajr = pointMap['Fajr']!;
    final sunrise = pointMap['Sunrise']!;
    final dhuhr = pointMap['Dhuhr']!;
    final asr = pointMap['Asr']!;
    final maghrib = pointMap['Maghrib']!;
    final isha = pointMap['Isha']!;
    final completionPercent = ((todayDone / 5) * 100).round().clamp(0, 100);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16 * scale),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18 * scale),
        color: Colors.white.withAlpha(8),
        border: Border.all(color: AppTheme.accentGold.withAlpha(26)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withAlpha(10),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: EdgeInsets.fromLTRB(14 * scale, 14 * scale, 14 * scale, 12 * scale),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withAlpha(8),
                Colors.white.withAlpha(2),
              ],
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prayer Cycle',
                        style: TextStyle(
                          color: Colors.white.withAlpha(220),
                          fontWeight: FontWeight.w700,
                          fontSize: 14 * scale,
                        ),
                      ),
                      SizedBox(height: 2 * scale),
                      Text(
                        'Dawn to night timeline',
                        style: TextStyle(
                          color: Colors.white.withAlpha(115),
                          fontWeight: FontWeight.w500,
                          fontSize: 10.5 * scale,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 6 * scale),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGold.withAlpha(24),
                      borderRadius: BorderRadius.circular(10 * scale),
                      border: Border.all(color: AppTheme.accentGold.withAlpha(50)),
                    ),
                    child: Text(
                      '$completionPercent%',
                      style: TextStyle(
                        color: AppTheme.accentGold,
                        fontWeight: FontWeight.w800,
                        fontSize: 12 * scale,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10 * scale),
              SizedBox(
                height: 140 * scale,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final size = Size(constraints.maxWidth, constraints.maxHeight);
                    final baselineY = size.height * 0.72;
                    final leftInset = 8 * scale;
                    final rightInset = 8 * scale;
                    final width = (size.width - leftInset - rightInset).clamp(1.0, double.infinity);

                    double progressX(double progress) => leftInset + (progress.clamp(0.0, 1.0) * width);

                    final sunriseX = progressX(sunrise.progress);
                    final maghribX = progressX(maghrib.progress);
                    final arcStart = Offset(sunriseX, baselineY);
                    final arcEnd = Offset(maghribX, baselineY);
                    final control = Offset((sunriseX + maghribX) * 0.5, size.height * 0.10);

                    Offset arcPoint(double progress) {
                      final range = (maghrib.progress - sunrise.progress).abs() < 0.001
                          ? 1.0
                          : (maghrib.progress - sunrise.progress);
                      final t = ((progress - sunrise.progress) / range).clamp(0.0, 1.0).toDouble();
                      return _pointOnQuadratic(arcStart, control, arcEnd, t);
                    }

                    final fajrPoint = Offset(progressX(fajr.progress), baselineY + (14 * scale));
                    final sunrisePoint = Offset(sunriseX, baselineY);
                    final dhuhrPoint = arcPoint(dhuhr.progress);
                    final asrPoint = arcPoint(asr.progress);
                    final maghribPoint = Offset(maghribX, baselineY);
                    final ishaPoint = Offset(progressX(isha.progress), baselineY + (14 * scale));

                    final nowProgress = _currentDayProgress(prayerTimes);
                    Offset sunPoint;
                    if (nowProgress <= sunrise.progress) {
                      final denom = sunrise.progress <= 0.001 ? 1.0 : sunrise.progress;
                      sunPoint = Offset.lerp(fajrPoint, sunrisePoint, (nowProgress / denom).clamp(0.0, 1.0)) ?? sunrisePoint;
                    } else if (nowProgress < maghrib.progress) {
                      sunPoint = arcPoint(nowProgress);
                    } else {
                      final denom = (1 - maghrib.progress).abs() <= 0.001 ? 1.0 : (1 - maghrib.progress);
                      sunPoint = Offset.lerp(
                            maghribPoint,
                            ishaPoint,
                            ((nowProgress - maghrib.progress) / denom).clamp(0.0, 1.0),
                          ) ??
                          maghribPoint;
                    }

                    final markers = <PrayerPointPosition>[
                      PrayerPointPosition(fajr, fajrPoint),
                      PrayerPointPosition(sunrise, sunrisePoint),
                      PrayerPointPosition(dhuhr, dhuhrPoint),
                      PrayerPointPosition(asr, asrPoint),
                      PrayerPointPosition(maghrib, maghribPoint),
                      PrayerPointPosition(isha, ishaPoint),
                    ];

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: DayCyclePainter(
                              scale: scale,
                              baselineY: baselineY,
                              fajrPoint: fajrPoint,
                              sunrisePoint: sunrisePoint,
                              controlPoint: control,
                              maghribPoint: maghribPoint,
                              ishaPoint: ishaPoint,
                              sunPoint: sunPoint,
                            ),
                          ),
                        ),
                        ...markers.map((marker) {
                          final isEdge = marker.data.label == 'Fajr' ||
                              marker.data.label == 'Sunrise' ||
                              marker.data.label == 'Maghrib' ||
                              marker.data.label == 'Isha';
                          final dotSize = isEdge ? 9.0 * scale : 8.0 * scale;

                          final placeAbove = marker.data.label == 'Sunrise' ||
                              marker.data.label == 'Dhuhr' ||
                              marker.data.label == 'Asr' ||
                              marker.data.label == 'Maghrib';
                          final labelWidth = 60 * scale;
                          final rawLabelLeft = marker.position.dx - (labelWidth / 2);
                          final labelLeft = rawLabelLeft.clamp(0.0, size.width - labelWidth).toDouble();
                          final labelTop = placeAbove
                              ? marker.position.dy - (26 * scale)
                              : marker.position.dy + (10 * scale);

                          final isUpcoming = marker.data.label == 'Dhuhr' || marker.data.label == 'Asr' || marker.data.label == 'Maghrib';

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                left: marker.position.dx - (dotSize / 2),
                                top: marker.position.dy - (dotSize / 2),
                                child: Container(
                                  width: dotSize,
                                  height: dotSize,
                                  decoration: BoxDecoration(
                                    color: marker.data.color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withAlpha(240),
                                      width: 1.2 * scale,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: marker.data.color.withAlpha(180),
                                        blurRadius: isEdge ? 12 * scale : 8 * scale,
                                        spreadRadius: 1 * scale,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                left: labelLeft,
                                top: labelTop,
                                child: SizedBox(
                                  width: labelWidth,
                                  child: Text(
                                    marker.data.label,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.outfit(
                                      color: Colors.white.withAlpha(isUpcoming ? 255 : 160),
                                      fontWeight: isUpcoming ? FontWeight.w700 : FontWeight.w600,
                                      fontSize: 10 * scale,
                                      letterSpacing: 0.5,
                                      shadows: [
                                        if (isUpcoming)
                                          Shadow(
                                            color: AppTheme.accentGold.withAlpha(120),
                                            blurRadius: 8,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    );
                  },
                ),
              ),
              SizedBox(height: 10 * scale),
              Row(
                children: [
                  Expanded(
                    child: _buildCycleMetric(
                      scale: scale,
                      title: 'Dawn',
                      value: '${fajr.time} — ${sunrise.time}',
                      color: const Color(0xFFFFB020),
                      icon: Icons.wb_twilight_rounded,
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Expanded(
                    child: _buildCycleMetric(
                      scale: scale,
                      title: 'Midday',
                      value: '${dhuhr.time} — ${asr.time}',
                      color: AppTheme.accentGold,
                      icon: Icons.light_mode_rounded,
                    ),
                  ),
                  SizedBox(width: 8 * scale),
                  Expanded(
                    child: _buildCycleMetric(
                      scale: scale,
                      title: 'Night',
                      value: '${maghrib.time} — ${isha.time}',
                      color: const Color(0xFFFFB020),
                      icon: Icons.nights_stay_rounded,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCycleMetric({
    required double scale,
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(6),
        borderRadius: BorderRadius.circular(10 * scale),
        border: Border.all(color: color.withAlpha(46)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13 * scale, color: color.withAlpha(220)),
              SizedBox(width: 4 * scale),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white.withAlpha(168),
                  fontSize: 9.5 * scale,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 4 * scale),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withAlpha(220),
              fontSize: 10.5 * scale,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  List<PrayerPoint> _buildPrayerPoints(PrayerTimesModel? prayerTimes) {
    final fallback = <PrayerPoint>[
      PrayerPoint(label: 'Fajr', time: '--:--', progress: 0.06, color: const Color(0xFFFFD700).withAlpha(180)),
      const PrayerPoint(label: 'Sunrise', time: '--:--', progress: 0.16, color: Color(0xFFFFB020)),
      PrayerPoint(label: 'Dhuhr', time: '--:--', progress: 0.50, color: AppTheme.accentGold),
      PrayerPoint(label: 'Asr', time: '--:--', progress: 0.68, color: AppTheme.accentGold.withAlpha(200)),
      const PrayerPoint(label: 'Maghrib', time: '--:--', progress: 0.90, color: Color(0xFFFFD700)),
      PrayerPoint(label: 'Isha', time: '--:--', progress: 0.98, color: const Color(0xFFFFB020).withAlpha(180)),
    ];

    if (prayerTimes == null) {
      return fallback;
    }

    final fajr = _parseTimeToMinutes(prayerTimes.fajr);
    final isha = _parseTimeToMinutes(prayerTimes.isha);
    if (fajr == null || isha == null || isha <= fajr) {
      return [
        PrayerPoint.copyWithTime(fallback[0], prayerTimes.fajr),
        PrayerPoint.copyWithTime(fallback[1], prayerTimes.sunrise),
        PrayerPoint.copyWithTime(fallback[2], prayerTimes.dhuhr),
        PrayerPoint.copyWithTime(fallback[3], prayerTimes.asr),
        PrayerPoint.copyWithTime(fallback[4], prayerTimes.maghrib),
        PrayerPoint.copyWithTime(fallback[5], prayerTimes.isha),
      ];
    }

    double normalize(String time, double fallbackProgress) {
      final minutes = _parseTimeToMinutes(time);
      if (minutes == null) return fallbackProgress;
      return ((minutes - fajr) / (isha - fajr)).clamp(0.0, 1.0).toDouble();
    }

    return [
      PrayerPoint(
        label: 'Fajr',
        time: prayerTimes.fajr,
        progress: normalize(prayerTimes.fajr, fallback[0].progress),
        color: const Color(0xFFFFD700).withAlpha(180),
      ),
      PrayerPoint(
        label: 'Sunrise',
        time: prayerTimes.sunrise,
        progress: normalize(prayerTimes.sunrise, fallback[1].progress),
        color: const Color(0xFFFFB020),
      ),
      PrayerPoint(
        label: 'Dhuhr',
        time: prayerTimes.dhuhr,
        progress: normalize(prayerTimes.dhuhr, fallback[2].progress),
        color: AppTheme.accentGold,
      ),
      PrayerPoint(
        label: 'Asr',
        time: prayerTimes.asr,
        progress: normalize(prayerTimes.asr, fallback[3].progress),
        color: AppTheme.accentGold.withAlpha(200),
      ),
      PrayerPoint(
        label: 'Maghrib',
        time: prayerTimes.maghrib,
        progress: normalize(prayerTimes.maghrib, fallback[4].progress),
        color: const Color(0xFFFFD700),
      ),
      PrayerPoint(
        label: 'Isha',
        time: prayerTimes.isha,
        progress: normalize(prayerTimes.isha, fallback[5].progress),
        color: const Color(0xFFFFB020).withAlpha(180),
      ),
    ];
  }

  double _currentDayProgress(PrayerTimesModel? prayerTimes) {
    if (prayerTimes == null) return 0.5;
    final fajr = _parseTimeToMinutes(prayerTimes.fajr);
    final isha = _parseTimeToMinutes(prayerTimes.isha);
    if (fajr == null || isha == null || isha <= fajr) return 0.5;

    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;
    if (nowMinutes <= fajr) return 0.0;
    if (nowMinutes >= isha) return 1.0;
    return ((nowMinutes - fajr) / (isha - fajr)).clamp(0.0, 1.0).toDouble();
  }

  int? _parseTimeToMinutes(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final normalized = value.trim().toUpperCase();
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(normalized);
    if (match == null) return null;

    var hour = int.tryParse(match.group(1)!);
    final minute = int.tryParse(match.group(2)!);
    if (hour == null || minute == null || minute > 59) return null;

    if (normalized.contains('PM') && hour < 12) {
      hour += 12;
    } else if (normalized.contains('AM') && hour == 12) {
      hour = 0;
    }

    if (hour < 0 || hour > 23) return null;
    return hour * 60 + minute;
  }

  Offset _pointOnQuadratic(
    Offset p0,
    Offset p1,
    Offset p2,
    double t,
  ) {
    final clamped = t.clamp(0.0, 1.0).toDouble();
    final oneMinusT = 1 - clamped;
    final x = (oneMinusT * oneMinusT * p0.dx) +
        (2 * oneMinusT * clamped * p1.dx) +
        (clamped * clamped * p2.dx);
    final y = (oneMinusT * oneMinusT * p0.dy) +
        (2 * oneMinusT * clamped * p1.dy) +
        (clamped * clamped * p2.dy);
    return Offset(x, y);
  }
}
