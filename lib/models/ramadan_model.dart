import 'package:hive/hive.dart';

part 'ramadan_model.g.dart';

@HiveType(typeId: 4)
class RamadanModel extends HiveObject {
  @HiveField(0)
  Map<String, List<bool>> fastingHistory; // Year-Month -> [day1, day2, ..., day30]

  @HiveField(1)
  int totalMissedFasts;

  @HiveField(2)
  int completedFasts;

  RamadanModel({
    Map<String, List<bool>>? fastingHistory,
    this.totalMissedFasts = 0,
    this.completedFasts = 0,
  }) : fastingHistory = fastingHistory ?? {};

  /// Mark a specific day as fasted
  void markDayFasted(int year, int month, int day) {
    final key = _getKey(year, month);
    if (!fastingHistory.containsKey(key)) {
      fastingHistory[key] = List.filled(30, false);
    }
    if (day >= 1 && day <= 30) {
      fastingHistory[key]![day - 1] = true;
    }
  }

  /// Unmark a specific day
  void unmarkDayFasted(int year, int month, int day) {
    final key = _getKey(year, month);
    if (fastingHistory.containsKey(key) && day >= 1 && day <= 30) {
      fastingHistory[key]![day - 1] = false;
    }
  }

  /// Check if a day is marked as fasted
  bool isDayFasted(int year, int month, int day) {
    final key = _getKey(year, month);
    if (!fastingHistory.containsKey(key) || day < 1 || day > 30) {
      return false;
    }
    return fastingHistory[key]![day - 1];
  }

  /// Get fasted days count for a specific Ramadan
  int getFastedDaysCount(int year, int month) {
    final key = _getKey(year, month);
    if (!fastingHistory.containsKey(key)) return 0;
    return fastingHistory[key]!.where((fasted) => fasted).length;
  }

  /// Calculate total missed fasts across all Ramadans
  int calculateTotalMissed(List<RamadanPeriod> allRamadans) {
    int total = 0;
    for (final ramadan in allRamadans) {
      final fasted = getFastedDaysCount(ramadan.year, ramadan.month);
      total += (30 - fasted); // Assuming 30 days per Ramadan
    }
    return total;
  }

  String _getKey(int year, int month) {
    return '$year-${month.toString().padLeft(2, '0')}';
  }

  /// Get remaining fasts
  int get remainingFasts => totalMissedFasts - completedFasts;

  /// Mark a makeup fast as completed
  void markMakeupFastCompleted() {
    completedFasts++;
  }
}

/// Represents a Ramadan period
class RamadanPeriod {
  final int year;
  final int month;
  final int startDay;

  RamadanPeriod({
    required this.year,
    required this.month,
    required this.startDay,
  });

  DateTime get startDate => DateTime(year, month, startDay);
}

