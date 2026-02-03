import 'package:hive/hive.dart';

part 'qada_model.g.dart';

@HiveType(typeId: 3)
class QadaModel extends HiveObject {
  @HiveField(0)
  int totalMissedPrayers;

  @HiveField(1)
  int completedPrayers;

  @HiveField(2)
  Map<String, int> completedToday; // Date string -> count

  @HiveField(3)
  DateTime? lastUpdated;

  QadaModel({
    this.totalMissedPrayers = 0,
    this.completedPrayers = 0,
    Map<String, int>? completedToday,
    this.lastUpdated,
  }) : completedToday = completedToday ?? {};

  /// Calculate total qada based on days since maturity
  /// Formula: daysSinceMaturity * 5 prayers per day
  static int calculateTotalQada(int daysSinceMaturity) {
    return daysSinceMaturity * 5;
  }

  /// Get remaining prayers to complete
  int get remainingPrayers => totalMissedPrayers - completedPrayers;

  /// Get completed count for today
  int get todayCount {
    final today = _getTodayKey();
    return completedToday[today] ?? 0;
  }

  /// Mark one prayer as completed
  void markPrayerCompleted() {
    final today = _getTodayKey();
    completedToday[today] = (completedToday[today] ?? 0) + 1;
    completedPrayers++;
    lastUpdated = DateTime.now();
  }

  /// Undo one prayer completion (when user unchecks)
  void undoPrayerCompleted() {
    if (completedPrayers > 0) {
      final today = _getTodayKey();
      final todayCompleted = completedToday[today] ?? 0;
      if (todayCompleted > 0) {
        completedToday[today] = todayCompleted - 1;
      }
      completedPrayers--;
      lastUpdated = DateTime.now();
    }
  }

  /// Reset daily counter (call this at midnight)
  void resetDailyCounter() {
    final today = _getTodayKey();
    completedToday.removeWhere((key, value) => key != today);
  }

  /// Update total missed prayers based on new calculation
  void updateTotalMissed(int newTotal) {
    totalMissedPrayers = newTotal;
    lastUpdated = DateTime.now();
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Get progress percentage
  double get progressPercentage {
    if (totalMissedPrayers == 0) return 0;
    return (completedPrayers / totalMissedPrayers) * 100;
  }
}

