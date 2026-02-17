import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  late String userId;

  @HiveField(1)
  String? name;

  @HiveField(2)
  DateTime? dateOfBirth;

  @HiveField(3)
  Gender? gender;

  @HiveField(4)
  double? latitude;

  @HiveField(5)
  double? longitude;

  @HiveField(6)
  String? city;

  @HiveField(7)
  String? country;

  @HiveField(8)
  Map<String, int> iqamaOffsets; // Prayer name -> minutes offset

  @HiveField(9)
  String locale;

  @HiveField(10)
  int calculationMethod; // Aladhan API calculation method

  @HiveField(11)
  Map<String, List<String>> completedPrayersDaily; // Date -> List of prayer names

  @HiveField(12, defaultValue: 1.0)
  double uiScale; // UI scale factor (0.7 - 1.3)

  @HiveField(13)
  Map<String, bool> reminders; // Prayer name -> enabled

  @HiveField(14, defaultValue: 15)
  int reminderMinutesBefore;

  UserModel({
    String? userId,
    this.name,
    this.dateOfBirth,
    this.gender,
    this.latitude,
    this.longitude,
    this.city,
    this.country,
    Map<String, int>? iqamaOffsets,
    this.locale = 'en',
    this.calculationMethod = 2, // Muslim World League
    Map<String, List<String>>? completedPrayersDaily,
    this.uiScale = 1.0,
    Map<String, bool>? reminders,
    this.reminderMinutesBefore = 15,
  })  : userId = userId ?? const Uuid().v4(),
        iqamaOffsets = iqamaOffsets ??
            {
              'Fajr': 15,
              'Dhuhr': 10,
              'Asr': 10,
              'Maghrib': 5,
              'Isha': 10,
            },
        completedPrayersDaily = completedPrayersDaily ?? {},
        reminders = reminders ??
            {
              'Fajr': true,
              'Dhuhr': true,
              'Asr': true,
              'Maghrib': true,
              'Isha': true,
            };

  /// Get today's date key
  static String get todayKey {
    final now = DateTime.now();
    return dateToKey(now);
  }

  /// Convert DateTime to key string
  static String dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Get completed prayers for today
  List<String> get todayCompletedPrayers {
    return completedPrayersDaily[todayKey] ?? [];
  }

  /// Get completed prayers for a specific date
  List<String> getCompletedPrayersForDate(DateTime date) {
    return completedPrayersDaily[dateToKey(date)] ?? [];
  }

  /// Check if a prayer is completed today
  bool isPrayerCompleted(String prayerName) {
    return todayCompletedPrayers.contains(prayerName);
  }

  /// Check if a prayer is completed for a specific date
  bool isPrayerCompletedForDate(String prayerName, DateTime date) {
    return getCompletedPrayersForDate(date).contains(prayerName);
  }

  /// Toggle prayer completion for today
  void togglePrayerCompletion(String prayerName) {
    togglePrayerCompletionForDate(prayerName, DateTime.now());
  }

  /// Toggle prayer completion for a specific date
  void togglePrayerCompletionForDate(String prayerName, DateTime date) {
    final key = dateToKey(date);
    final prayers = List<String>.from(completedPrayersDaily[key] ?? []);

    if (prayers.contains(prayerName)) {
      prayers.remove(prayerName);
    } else {
      prayers.add(prayerName);
    }

    completedPrayersDaily[key] = prayers;
  }

  /// Get count of completed prayers today
  int get todayCompletedCount => todayCompletedPrayers.length;

  /// Get count of completed prayers for a specific date
  int getCompletedCountForDate(DateTime date) {
    return getCompletedPrayersForDate(date).length;
  }

  /// Calculate the age of maturity based on gender
  /// Girls: 9 years, Boys: 12 years
  DateTime? get maturityDate {
    if (dateOfBirth == null || gender == null) return null;
    final yearsToAdd = gender == Gender.female ? 9 : 12;
    return DateTime(
      dateOfBirth!.year + yearsToAdd,
      dateOfBirth!.month,
      dateOfBirth!.day,
    );
  }

  /// Calculate days since maturity
  int? get daysSinceMaturity {
    final maturity = maturityDate;
    if (maturity == null) return null;
    final now = DateTime.now();
    if (now.isBefore(maturity)) return 0;
    return now.difference(maturity).inDays;
  }
}

@HiveType(typeId: 1)
enum Gender {
  @HiveField(0)
  male,
  @HiveField(1)
  female,
}

