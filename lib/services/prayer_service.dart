import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import '../models/prayer_times_model.dart';

class PrayerService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';
  static const String _cacheBoxName = 'prayer_times_cache';

  /// Fetch prayer times for a specific date and location
  Future<PrayerTimesModel?> getPrayerTimes({
    required double latitude,
    required double longitude,
    required DateTime date,
    int method = 2, // Muslim World League
    bool useCache = true,
  }) async {
    // Check cache first
    if (useCache) {
      final cached = await _getCachedPrayerTimes(latitude, longitude, date);
      if (cached != null) return cached;
    }

    try {
      final timestamp = date.millisecondsSinceEpoch ~/ 1000;
      final url = Uri.parse(
        '$_baseUrl/timings/$timestamp?latitude=$latitude&longitude=$longitude&method=$method',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prayerTimes =
            PrayerTimesModel.fromJson(data, date, latitude, longitude);

        // Cache the result
        await _cachePrayerTimes(prayerTimes);

        return prayerTimes;
      }
    } catch (e) {
      debugPrint('Error fetching prayer times: $e');
    }

    return null;
  }

  /// Get prayer times for today
  Future<PrayerTimesModel?> getTodayPrayerTimes({
    required double latitude,
    required double longitude,
    int method = 2,
  }) async {
    final result = await getPrayerTimes(
      latitude: latitude,
      longitude: longitude,
      date: DateTime.now(),
      method: method,
    );
    
    // If API fails, return default prayer times (for Mecca)
    if (result == null) {
      debugPrint('API request failed, using default prayer times');
      return _getDefaultPrayerTimes(latitude, longitude);
    }
    
    return result;
  }

  /// Get default prayer times (fallback for Mecca)
  PrayerTimesModel _getDefaultPrayerTimes(double latitude, double longitude) {
    final now = DateTime.now();
    return PrayerTimesModel(
      date: now,
      fajr: '05:30',
      sunrise: '07:00',
      dhuhr: '12:30',
      asr: '15:45',
      maghrib: '18:15',
      isha: '19:45',
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Get prayer times for the entire month
  Future<List<PrayerTimesModel>> getMonthPrayerTimes({
    required double latitude,
    required double longitude,
    required int year,
    required int month,
    int method = 2,
  }) async {
    final List<PrayerTimesModel> monthTimes = [];

    try {
      final url = Uri.parse(
        '$_baseUrl/calendar/$year/$month?latitude=$latitude&longitude=$longitude&method=$method',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final daysData = data['data'] as List;

        for (var dayData in daysData) {
          final dateStr = dayData['date']['gregorian']['date'];
          final dateParts = dateStr.split('-');
          final date = DateTime(
            int.parse(dateParts[2]),
            int.parse(dateParts[1]),
            int.parse(dateParts[0]),
          );

          final prayerTimes = PrayerTimesModel.fromJson(
            {'data': dayData},
            date,
            latitude,
            longitude,
          );

          monthTimes.add(prayerTimes);
          await _cachePrayerTimes(prayerTimes);
        }
      }
    } catch (e) {
      debugPrint('Error fetching month prayer times: $e');
    }

    return monthTimes;
  }

  /// Cache prayer times
  Future<void> _cachePrayerTimes(PrayerTimesModel prayerTimes) async {
    try {
      final box = await Hive.openBox<PrayerTimesModel>(_cacheBoxName);
      final key = _getCacheKey(
        prayerTimes.latitude,
        prayerTimes.longitude,
        prayerTimes.date,
      );
      await box.put(key, prayerTimes);
    } catch (e) {
      debugPrint('Error caching prayer times: $e');
    }
  }

  /// Get cached prayer times
  Future<PrayerTimesModel?> _getCachedPrayerTimes(
    double latitude,
    double longitude,
    DateTime date,
  ) async {
    try {
      final box = await Hive.openBox<PrayerTimesModel>(_cacheBoxName);
      final key = _getCacheKey(latitude, longitude, date);
      return box.get(key);
    } catch (e) {
      debugPrint('Error getting cached prayer times: $e');
      return null;
    }
  }

  String _getCacheKey(double latitude, double longitude, DateTime date) {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return '${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}_$dateStr';
  }

  /// Clear old cache (older than 30 days)
  Future<void> clearOldCache() async {
    try {
      final box = await Hive.openBox<PrayerTimesModel>(_cacheBoxName);
      final now = DateTime.now();
      final keysToDelete = <String>[];

      for (var key in box.keys) {
        final prayerTimes = box.get(key);
        if (prayerTimes != null) {
          final daysDiff = now.difference(prayerTimes.date).inDays;
          if (daysDiff > 30) {
            keysToDelete.add(key as String);
          }
        }
      }

      for (var key in keysToDelete) {
        await box.delete(key);
      }
    } catch (e) {
      debugPrint('Error clearing old cache: $e');
    }
  }
}
