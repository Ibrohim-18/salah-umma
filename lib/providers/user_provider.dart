import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';
import '../models/user_model.dart';
import '../models/prayer_times_model.dart';
import '../models/qada_model.dart';
import '../models/ramadan_model.dart';
import '../services/prayer_service.dart';

class UserProvider extends ChangeNotifier {
  static const String _userBoxName = 'user_box';
  static const String _qadaBoxName = 'qada_box';
  static const String _ramadanBoxName = 'ramadan_box';

  UserModel? _user;
  QadaModel? _qada;
  RamadanModel? _ramadan;
  PrayerTimesModel? _todayPrayerTimes;
  NextPrayerInfo? _nextPrayer;
  DateTime _selectedDate = DateTime.now();

  Timer? _heartbeatTimer;
  final PrayerService _prayerService = PrayerService();

  UserModel? get user => _user;
  QadaModel? get qada => _qada;
  RamadanModel? get ramadan => _ramadan;
  PrayerTimesModel? get todayPrayerTimes => _todayPrayerTimes;
  NextPrayerInfo? get nextPrayer => _nextPrayer;
  DateTime get selectedDate => _selectedDate;

  /// Check if selected date is today
  bool get isSelectedDateToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
           _selectedDate.month == now.month &&
           _selectedDate.day == now.day;
  }

  /// Initialize provider and load data
  Future<void> initialize() async {
    await _loadUser();
    await _loadQada();
    await _loadRamadan();

    if (_user != null && _user!.latitude != null && _user!.longitude != null) {
      await loadTodayPrayerTimes();
      _startHeartbeat();
    }
  }

  /// Load user from Hive
  Future<void> _loadUser() async {
    final box = await Hive.openBox<UserModel>(_userBoxName);
    if (box.isEmpty) {
      // Create new user with generated ID
      _user = UserModel();
      await box.put('current_user', _user!);
    } else {
      _user = box.get('current_user');
    }
    notifyListeners();
  }

  /// Save user to Hive
  Future<void> saveUser() async {
    if (_user == null) return;
    final box = await Hive.openBox<UserModel>(_userBoxName);
    await box.put('current_user', _user!);
    notifyListeners();
  }

  /// Update user profile
  Future<void> updateUserProfile({
    String? name,
    DateTime? dateOfBirth,
    Gender? gender,
  }) async {
    if (_user == null) return;

    if (name != null) _user!.name = name;
    if (dateOfBirth != null) _user!.dateOfBirth = dateOfBirth;
    if (gender != null) _user!.gender = gender;

    await saveUser();

    // Recalculate qada if maturity date changed
    if (dateOfBirth != null || gender != null) {
      await _recalculateQada();
    }
  }

  /// Update user location
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    String? city,
    String? country,
  }) async {
    if (_user == null) return;

    _user!.latitude = latitude;
    _user!.longitude = longitude;
    _user!.city = city;
    _user!.country = country;

    await saveUser();
    await loadTodayPrayerTimes();
    _startHeartbeat(); // Start countdown timer
  }

  /// Update Iqama offset for a specific prayer
  Future<void> updateIqamaOffset(String prayerName, int minutes) async {
    if (_user == null) return;

    // Create a new map to ensure Hive detects the change
    final newOffsets = Map<String, int>.from(_user!.iqamaOffsets);
    newOffsets[prayerName] = minutes;
    _user!.iqamaOffsets = newOffsets;

    await saveUser();
    _updateNextPrayer(); // Refresh next prayer with new offset
  }

  /// Update UI scale factor
  Future<void> updateUiScale(double scale) async {
    if (_user == null) return;

    _user!.uiScale = scale.clamp(0.7, 1.3);
    await saveUser();
    notifyListeners();
  }

  /// Get current location using GPS
  Future<void> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition();
      await updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  /// Load today's prayer times
  Future<void> loadTodayPrayerTimes() async {
    if (_user?.latitude == null || _user?.longitude == null) return;

    _todayPrayerTimes = await _prayerService.getTodayPrayerTimes(
      latitude: _user!.latitude!,
      longitude: _user!.longitude!,
      method: _user!.calculationMethod,
    );

    _updateNextPrayer();
    notifyListeners();
  }

  /// Start heartbeat timer (runs every second)
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateNextPrayer();
    });
  }

  /// Update next prayer info
  void _updateNextPrayer() {
    if (_todayPrayerTimes == null) return;

    final newNextPrayer = _todayPrayerTimes!.getNextPrayer(
      iqamaOffsets: _user?.iqamaOffsets,
    );

    // Check if anything changed (name, adhan time, or iqama time)
    final hasChanged = newNextPrayer?.name != _nextPrayer?.name ||
        newNextPrayer?.iqamaTime != _nextPrayer?.iqamaTime ||
        newNextPrayer?.adhanTime != _nextPrayer?.adhanTime;

    if (hasChanged) {
      _nextPrayer = newNextPrayer;
      notifyListeners();
    }
  }

  /// Load Qada data
  Future<void> _loadQada() async {
    final box = await Hive.openBox<QadaModel>(_qadaBoxName);
    if (box.isEmpty) {
      _qada = QadaModel();
      await box.put('qada', _qada!);
    } else {
      _qada = box.get('qada');
    }
    await _recalculateQada();
  }

  /// Recalculate total qada based on user's age
  Future<void> _recalculateQada() async {
    if (_qada == null || _user?.daysSinceMaturity == null) return;

    final totalMissed = QadaModel.calculateTotalQada(_user!.daysSinceMaturity!);
    _qada!.updateTotalMissed(totalMissed);

    final box = await Hive.openBox<QadaModel>(_qadaBoxName);
    await box.put('qada', _qada!);
    notifyListeners();
  }

  /// Mark qada prayer as completed
  Future<void> markQadaCompleted() async {
    if (_qada == null) return;

    _qada!.markPrayerCompleted();

    final box = await Hive.openBox<QadaModel>(_qadaBoxName);
    await box.put('qada', _qada!);
    notifyListeners();
  }

  /// Toggle daily prayer completion (for today's prayers)
  /// Also updates Qada counter: check = -1 qada, uncheck = +1 qada
  Future<void> toggleDailyPrayer(String prayerName) async {
    if (_user == null) return;

    final wasCompleted = _user!.isPrayerCompleted(prayerName);
    _user!.togglePrayerCompletion(prayerName);
    await saveUser();

    // Update Qada counter
    if (_qada != null) {
      if (wasCompleted) {
        // Unchecking - add back to qada (undo completion)
        _qada!.undoPrayerCompleted();
      } else {
        // Checking - mark qada as completed
        _qada!.markPrayerCompleted();
      }
      final box = await Hive.openBox<QadaModel>(_qadaBoxName);
      await box.put('qada', _qada!);
      notifyListeners();
    }
  }

  /// Check if a prayer is completed today
  bool isPrayerCompletedToday(String prayerName) {
    return _user?.isPrayerCompleted(prayerName) ?? false;
  }

  /// Check if a prayer is completed for selected date
  bool isPrayerCompletedForSelectedDate(String prayerName) {
    return _user?.isPrayerCompletedForDate(prayerName, _selectedDate) ?? false;
  }

  /// Get count of completed prayers today
  int get todayCompletedCount => _user?.todayCompletedCount ?? 0;

  /// Get count of completed prayers for selected date
  int get selectedDateCompletedCount =>
      _user?.getCompletedCountForDate(_selectedDate) ?? 0;

  /// Navigate to previous day
  void goToPreviousDay() {
    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
    notifyListeners();
  }

  /// Navigate to next day
  void goToNextDay() {
    _selectedDate = _selectedDate.add(const Duration(days: 1));
    notifyListeners();
  }

  /// Go to today
  void goToToday() {
    _selectedDate = DateTime.now();
    notifyListeners();
  }

  /// Set specific date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  /// Toggle prayer for selected date
  Future<void> togglePrayerForSelectedDate(String prayerName) async {
    if (_user == null) return;

    final wasCompleted = _user!.isPrayerCompletedForDate(prayerName, _selectedDate);
    _user!.togglePrayerCompletionForDate(prayerName, _selectedDate);
    await saveUser();

    // Update Qada counter
    if (_qada != null) {
      if (wasCompleted) {
        _qada!.undoPrayerCompleted();
      } else {
        _qada!.markPrayerCompleted();
      }
      final box = await Hive.openBox<QadaModel>(_qadaBoxName);
      await box.put('qada', _qada!);
      notifyListeners();
    }
  }

  /// Load Ramadan data
  Future<void> _loadRamadan() async {
    final box = await Hive.openBox<RamadanModel>(_ramadanBoxName);
    if (box.isEmpty) {
      _ramadan = RamadanModel();
      await box.put('ramadan', _ramadan!);
    } else {
      _ramadan = box.get('ramadan');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    super.dispose();
  }
}

