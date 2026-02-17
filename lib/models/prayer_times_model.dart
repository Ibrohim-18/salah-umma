import 'package:hive/hive.dart';

part 'prayer_times_model.g.dart';

@HiveType(typeId: 2)
class PrayerTimesModel extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final String fajr;

  @HiveField(2)
  final String sunrise;

  @HiveField(3)
  final String dhuhr;

  @HiveField(4)
  final String asr;

  @HiveField(5)
  final String maghrib;

  @HiveField(6)
  final String isha;

  @HiveField(7)
  final double latitude;

  @HiveField(8)
  final double longitude;

  PrayerTimesModel({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.latitude,
    required this.longitude,
  });

  /// Get all prayer times as a map
  Map<String, String> get timesMap => {
        'Fajr': fajr,
        'Dhuhr': dhuhr,
        'Asr': asr,
        'Maghrib': maghrib,
        'Isha': isha,
      };

  /// Get prayer time by name
  String? getTimeByName(String prayerName) {
    return timesMap[prayerName];
  }

  /// Parse time string (HH:mm) to DateTime for today
  DateTime parseTime(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  /// Get next prayer info
  NextPrayerInfo? getNextPrayer({Map<String, int>? iqamaOffsets}) {
    final now = DateTime.now();
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    DateTime? previousTime;

    for (final prayerName in prayers) {
      final adhanTime = parseTime(getTimeByName(prayerName)!);
      if (adhanTime.isAfter(now)) {
        final offset = iqamaOffsets?[prayerName] ?? 0;
        final iqamaTime = adhanTime.add(Duration(minutes: offset));
        
        // If this is Fajr (first prayer of day), previousTime is null.
        // We could theoretically check yesterday's Isha, but for simplicity
        // let's rely on the caller or just use null to indicate "new day".
        
        return NextPrayerInfo(
          name: prayerName,
          adhanTime: adhanTime,
          iqamaTime: iqamaTime,
          previousAdhanTime: previousTime,
        );
      }
      previousTime = adhanTime;
    }
    return null; // All prayers passed for today
  }

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json, DateTime date,
      double latitude, double longitude) {
    final timings = json['data']['timings'] as Map<String, dynamic>;
    return PrayerTimesModel(
      date: date,
      fajr: _cleanTime(timings['Fajr']),
      sunrise: _cleanTime(timings['Sunrise']),
      dhuhr: _cleanTime(timings['Dhuhr']),
      asr: _cleanTime(timings['Asr']),
      maghrib: _cleanTime(timings['Maghrib']),
      isha: _cleanTime(timings['Isha']),
      latitude: latitude,
      longitude: longitude,
    );
  }

  static String _cleanTime(String time) {
    // Remove timezone info like " (EET)"
    return time.split(' ')[0];
  }
}

class NextPrayerInfo {
  final String name;
  final DateTime adhanTime;
  final DateTime iqamaTime;
  final DateTime? previousAdhanTime;

  NextPrayerInfo({
    required this.name,
    required this.adhanTime,
    required this.iqamaTime,
    this.previousAdhanTime,
  });

  Duration get timeUntilAdhan => adhanTime.difference(DateTime.now());
  Duration get timeUntilIqama => iqamaTime.difference(DateTime.now());
}

