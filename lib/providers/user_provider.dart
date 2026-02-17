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
  PrayerTimesModel? _tomorrowPrayerTimes;
  NextPrayerInfo? _nextPrayer;
  DateTime _selectedDate = DateTime.now();
  int? _requestedTabIndex;
  DateTime _clock = DateTime.now();

  // Reminder state - now using _user instead of local fields

  Timer? _heartbeatTimer;
  final PrayerService _prayerService = PrayerService();

  UserModel? get user => _user;
  QadaModel? get qada => _qada;
  RamadanModel? get ramadan => _ramadan;
  PrayerTimesModel? get todayPrayerTimes => _todayPrayerTimes;
  NextPrayerInfo? get nextPrayer => _nextPrayer;
  DateTime get selectedDate => _selectedDate;
  int? get requestedTabIndex => _requestedTabIndex;
  DateTime get clock => _clock;

  /// Check if selected date is today
  bool get isSelectedDateToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
           _selectedDate.month == now.month &&
           _selectedDate.day == now.day;
  }

  /// Initialize provider and load data
  Future<void> initialize() async {
    debugPrint('UserProvider.initialize() started');
    await _loadUser();
    debugPrint('User loaded: ${_user?.city}');
    await _loadQada();
    debugPrint('Qada loaded');
    await _loadRamadan();
    debugPrint('Ramadan loaded');

    if (_user != null && _user!.latitude != null && _user!.longitude != null) {
      debugPrint('User has location: ${_user!.latitude}, ${_user!.longitude}');
      try {
        debugPrint('Calling loadTodayPrayerTimes...');
        await loadTodayPrayerTimes();
        debugPrint('Prayer times loaded');
        _startHeartbeat();
      } catch (e) {
        debugPrint('Error loading prayer times: $e');
      }
    } else if (_user != null) {
      debugPrint('User has no location, setting default...');
      // Set default location for testing (Mecca, Saudi Arabia)
      _user!.latitude = 21.4225;
      _user!.longitude = 39.8262;
      _user!.city = 'Mecca';
      _user!.country = 'Saudi Arabia';
      await saveUser();
      try {
        debugPrint('Calling loadTodayPrayerTimes with default location...');
        await loadTodayPrayerTimes();
        debugPrint('Prayer times loaded with default location');
        _startHeartbeat();
      } catch (e) {
        debugPrint('Error loading prayer times with default location: $e');
      }
    }
    debugPrint('UserProvider.initialize() completed');
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
      debugPrint('Error getting location: $e');
    }
  }

  /// Load today's prayer times
  Future<void> loadTodayPrayerTimes() async {
    if (_user?.latitude == null || _user?.longitude == null) return;

    try {
      _todayPrayerTimes = await _prayerService.getTodayPrayerTimes(
        latitude: _user!.latitude!,
        longitude: _user!.longitude!,
        method: _user!.calculationMethod,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('Prayer times request timed out');
          return null;
        },
      );

      _updateNextPrayer();
      notifyListeners();
      _loadNextDayPrayerTimes();
    } catch (e) {
      debugPrint('Error loading today prayer times: $e');
      notifyListeners();
    }
  }

  /// Load tomorrow's prayer times
  Future<void> _loadNextDayPrayerTimes() async {
    if (_user?.latitude == null || _user?.longitude == null) return;

    try {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      _tomorrowPrayerTimes = await _prayerService.getPrayerTimes(
        latitude: _user!.latitude!,
        longitude: _user!.longitude!,
        date: tomorrow,
        method: _user!.calculationMethod,
      );
      _updateNextPrayer();
    } catch (e) {
      debugPrint('Error loading tomorrow prayer times: $e');
    }
  }

  /// Start heartbeat timer - optimized to only notify when needed
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    // Use a longer interval and only update clock without notifying listeners
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      _clock = now;
      
      // Only call notifyListeners when the next prayer changes
      // This is much more efficient than notifying every second
      final newNextPrayer = _calculateNextPrayer(now);
      if (_hasNextPrayerChanged(newNextPrayer)) {
        _nextPrayer = newNextPrayer;
        notifyListeners();
      }
    });
  }

  /// Calculate next prayer without storing
  NextPrayerInfo? _calculateNextPrayer(DateTime now) {
    if (_todayPrayerTimes == null) return null;
    
    final newNext = _todayPrayerTimes!.getNextPrayer(
      iqamaOffsets: _user?.iqamaOffsets,
    );
    
    if (newNext == null && _tomorrowPrayerTimes != null) {
      final tomorrowFajr = _tomorrowPrayerTimes!.parseTime(_tomorrowPrayerTimes!.fajr);
      final offset = _user?.iqamaOffsets['Fajr'] ?? 0;
      final iqamaTime = tomorrowFajr.add(Duration(minutes: offset));
      final todayIsha = _todayPrayerTimes!.parseTime(_todayPrayerTimes!.isha);
      
      return NextPrayerInfo(
        name: 'Fajr',
        adhanTime: tomorrowFajr,
        iqamaTime: iqamaTime,
        previousAdhanTime: todayIsha,
      );
    }
    return newNext;
  }

  /// Check if next prayer has changed
  bool _hasNextPrayerChanged(NextPrayerInfo? newNext) {
    if (newNext?.name != _nextPrayer?.name) return true;
    if (newNext?.iqamaTime != _nextPrayer?.iqamaTime) return true;
    if (newNext?.adhanTime != _nextPrayer?.adhanTime) return true;
    return false;
  }

  /// Update next prayer info
  void _updateNextPrayer() {
    final newNextPrayer = _calculateNextPrayer(_clock);
    _nextPrayer = newNextPrayer;
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

  void requestTab(int index) {
    _requestedTabIndex = index;
    notifyListeners();
  }

  int? consumeRequestedTab() {
    final value = _requestedTabIndex;
    _requestedTabIndex = null;
    return value;
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

  // ─── Reminder Methods ───

  bool get areAllRemindersEnabled => _user?.reminders.values.every((v) => v) ?? true;
  int get reminderMinutesBefore => _user?.reminderMinutesBefore ?? 15;

  bool isReminderEnabled(String prayer) => _user?.reminders[prayer] ?? true;

  Future<void> toggleReminder(String prayer, bool value) async {
    if (_user == null) return;
    _user!.reminders[prayer] = value;
    await saveUser();
  }

  Future<void> toggleAllReminders(bool value) async {
    if (_user == null) return;
    for (final key in _user!.reminders.keys) {
      _user!.reminders[key] = value;
    }
    await saveUser();
  }

  Future<void> setReminderMinutesBefore(int minutes) async {
    if (_user == null) return;
    _user!.reminderMinutesBefore = minutes;
    await saveUser();
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    super.dispose();
  }
}
