import '../models/ramadan_model.dart';

class RamadanService {
  /// Calculate all Ramadan periods from maturity date to now
  /// Ramadan shifts approximately 11 days earlier each year in Gregorian calendar
  static List<RamadanPeriod> calculateRamadanHistory(DateTime maturityDate) {
    final List<RamadanPeriod> ramadans = [];
    final now = DateTime.now();

    // Base Ramadan date (2024 as reference)
    // Ramadan 2024 started around March 11
    final baseYear = 2024;
    final baseMonth = 3;
    final baseDay = 11;

    // Calculate for each year from maturity to now
    int currentYear = maturityDate.year;

    while (currentYear <= now.year) {
      // Calculate approximate Ramadan start for this year
      final yearDiff = currentYear - baseYear;
      final dayShift = yearDiff * 11; // Ramadan shifts ~11 days per year

      var ramadanDate = DateTime(baseYear, baseMonth, baseDay)
          .subtract(Duration(days: dayShift));

      // Adjust to current year
      ramadanDate = DateTime(
        currentYear,
        ramadanDate.month,
        ramadanDate.day,
      );

      // Only include if after maturity date and before now
      if (ramadanDate.isAfter(maturityDate) &&
          ramadanDate.isBefore(now.add(const Duration(days: 365)))) {
        ramadans.add(RamadanPeriod(
          year: ramadanDate.year,
          month: ramadanDate.month,
          startDay: ramadanDate.day,
        ));
      }

      currentYear++;
    }

    return ramadans;
  }

  /// Get current Ramadan period if we're in Ramadan
  static RamadanPeriod? getCurrentRamadan() {
    final now = DateTime.now();
    final currentYearRamadan = _estimateRamadanForYear(now.year);

    final ramadanStart = currentYearRamadan.startDate;
    final ramadanEnd = ramadanStart.add(const Duration(days: 30));

    if (now.isAfter(ramadanStart) && now.isBefore(ramadanEnd)) {
      return currentYearRamadan;
    }

    return null;
  }

  /// Get next Ramadan period
  static RamadanPeriod getNextRamadan() {
    final now = DateTime.now();
    final currentYearRamadan = _estimateRamadanForYear(now.year);

    if (now.isBefore(currentYearRamadan.startDate)) {
      return currentYearRamadan;
    } else {
      return _estimateRamadanForYear(now.year + 1);
    }
  }

  /// Estimate Ramadan start for a specific year
  static RamadanPeriod _estimateRamadanForYear(int year) {
    // Base reference: Ramadan 2024 started March 11
    const baseYear = 2024;
    const baseMonth = 3;
    const baseDay = 11;

    final yearDiff = year - baseYear;
    final dayShift = yearDiff * 11;

    var ramadanDate = DateTime(baseYear, baseMonth, baseDay)
        .subtract(Duration(days: dayShift));

    // Adjust to target year
    ramadanDate = DateTime(year, ramadanDate.month, ramadanDate.day);

    return RamadanPeriod(
      year: ramadanDate.year,
      month: ramadanDate.month,
      startDay: ramadanDate.day,
    );
  }

  /// Get day number in current Ramadan (1-30)
  static int? getCurrentRamadanDay() {
    final currentRamadan = getCurrentRamadan();
    if (currentRamadan == null) return null;

    final now = DateTime.now();
    final daysDiff = now.difference(currentRamadan.startDate).inDays;

    return daysDiff + 1;
  }

  /// Check if today is in Ramadan
  static bool isRamadan() {
    return getCurrentRamadan() != null;
  }

  /// Get days until next Ramadan
  static int daysUntilRamadan() {
    final nextRamadan = getNextRamadan();
    final now = DateTime.now();
    return nextRamadan.startDate.difference(now).inDays;
  }

  /// Calculate total Ramadans since maturity
  static int getTotalRamadansSinceMaturity(DateTime maturityDate) {
    final ramadans = calculateRamadanHistory(maturityDate);
    return ramadans.length;
  }
}

