import 'package:flutter/material.dart';

class PrayerPoint {
  const PrayerPoint({
    required this.label,
    required this.time,
    required this.progress,
    required this.color,
  });

  final String label;
  final String time;
  final double progress;
  final Color color;

  static PrayerPoint copyWithTime(PrayerPoint source, String time) {
    return PrayerPoint(
      label: source.label,
      time: time,
      progress: source.progress,
      color: source.color,
    );
  }
}

class PrayerPointPosition {
  const PrayerPointPosition(this.data, this.position);

  final PrayerPoint data;
  final Offset position;
}
