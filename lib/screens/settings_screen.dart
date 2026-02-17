import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import '../constants/app_theme.dart';
import '../widgets/glass_container.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  Gender? _selectedGender;
  Map<String, int> _iqamaOffsets = {};
  String _activeSection = 'profile';
  bool _isInitialized = false;
  String? _statusMessage;
  Timer? _statusTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadUserData();
      _isInitialized = true;
    }
  }

  void _loadUserData() {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;

    if (user != null) {
      _nameController.text = user.name ?? '';
      _selectedDate = user.dateOfBirth;
      _selectedGender = user.gender;
      _iqamaOffsets = Map<String, int>.from(user.iqamaOffsets);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  void _showInlineStatus(String message) {
    _statusTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _statusMessage = message;
    });
    _statusTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _statusMessage = null;
      });
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.accentGold,
              onPrimary: Colors.black,
              surface: Color(0xFF121212),
              onSurface: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: const Color(0xFF1E1E1E)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveSettings() async {
    final userProvider = context.read<UserProvider>();

    await userProvider.updateUserProfile(
      name: _nameController.text.isNotEmpty ? _nameController.text : null,
      dateOfBirth: _selectedDate,
      gender: _selectedGender,
    );

    _showInlineStatus('Settings saved');
  }

  Future<void> _changeIqamaOffset(String prayerName, int delta) async {
    final userProvider = context.read<UserProvider>();
    final current = _iqamaOffsets[prayerName] ?? userProvider.user?.iqamaOffsets[prayerName] ?? 0;
    final next = (current + delta).clamp(0, 90).toInt();
    if (next == current) return;

    setState(() {
      _iqamaOffsets[prayerName] = next;
    });

    await userProvider.updateIqamaOffset(prayerName, next);
    _showInlineStatus('$prayerName Iqama: +$next min');
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final scale = userProvider.user?.uiScale ?? 1.0;
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    final horizontalPadding = (isSmallScreen ? 14.0 : 18.0) * scale;
    final themeColor = AppTheme.accentGold;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(horizontalPadding, 64 * scale, horizontalPadding, 110 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Settings',
            style: TextStyle(
              fontSize: (isSmallScreen ? 34 : 40) * scale,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1.5,
              height: 1.1,
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            'Manage your profile & preferences',
            style: TextStyle(
              fontSize: (isSmallScreen ? 13 : 14) * scale,
              color: Colors.white.withAlpha(140),
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 24 * scale),
          _buildSectionTabs(scale, themeColor, isSmallScreen),
          SizedBox(height: 20 * scale),

          // ─── Profile Section ───
          if (_activeSection == 'profile') ...[
          _buildSectionLabel('PROFILE', scale),
          SizedBox(height: 12 * scale),
          GlassContainer(
            padding: EdgeInsets.all(20 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name field
                _buildLabel('Display Name', scale),
                SizedBox(height: 10 * scale),
                _buildGlassTextField(_nameController, 'Enter your name', scale, themeColor),
                SizedBox(height: 24 * scale),

                // Date of Birth
                _buildLabel('Date of Birth', scale),
                SizedBox(height: 10 * scale),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: GlassContainer(
                    padding: EdgeInsets.symmetric(
                      horizontal: (MediaQuery.of(context).size.width < 360 ? 12 : MediaQuery.of(context).size.width < 400 ? 14 : 16) * scale,
                      vertical: (MediaQuery.of(context).size.width < 360 ? 12 : MediaQuery.of(context).size.width < 400 ? 14 : 16) * scale,
                    ),
                    variant: GlassVariant.standard,
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all((MediaQuery.of(context).size.width < 360 ? 6 : 7) * scale),
                          decoration: BoxDecoration(
                            color: themeColor.withAlpha(20),
                            borderRadius: BorderRadius.circular((MediaQuery.of(context).size.width < 360 ? 8 : 10) * scale),
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: (MediaQuery.of(context).size.width < 360 ? 14 : MediaQuery.of(context).size.width < 400 ? 16 : 18) * scale,
                            color: themeColor,
                          ),
                        ),
                        SizedBox(width: (MediaQuery.of(context).size.width < 360 ? 10 : 12) * scale),
                        Text(
                          _selectedDate != null
                              ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                              : 'Select Date',
                          style: TextStyle(
                            fontSize: (MediaQuery.of(context).size.width < 360 ? 12 : MediaQuery.of(context).size.width < 400 ? 13 : 14) * scale,
                            fontWeight: FontWeight.w600,
                            color: _selectedDate != null
                                ? Colors.white.withAlpha(240)
                                : Colors.white.withAlpha(100),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: (MediaQuery.of(context).size.width < 360 ? 18 : MediaQuery.of(context).size.width < 400 ? 20 : 22) * scale,
                          color: Colors.white.withAlpha(60),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24 * scale),

                // Gender — Pill Buttons
                _buildLabel('Gender', scale),
                SizedBox(height: 10 * scale),
                Row(
                  children: [
                    Expanded(
                      child: _buildPillButton(
                        'Male',
                        Icons.male_rounded,
                        _selectedGender == Gender.male,
                        () => setState(() => _selectedGender = Gender.male),
                        scale,
                        themeColor,
                      ),
                    ),
                    SizedBox(width: (MediaQuery.of(context).size.width < 360 ? 8 : 10) * scale),
                    Expanded(
                      child: _buildPillButton(
                        'Female',
                        Icons.female_rounded,
                        _selectedGender == Gender.female,
                        () => setState(() => _selectedGender = Gender.female),
                        scale,
                        themeColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 24 * scale),
          _buildGradientButton('Save Profile', Icons.check_rounded, _saveSettings, scale, themeColor),
          SizedBox(height: 12 * scale),
          _buildStatusMessage(scale),
          ],

          // ─── Location Section ───
          if (_activeSection == 'location') ...[
          _buildSectionLabel('LOCATION', scale),
          SizedBox(height: 12 * scale),
          GlassContainer(
            padding: EdgeInsets.all(20 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (user?.city != null) ...[
                  Row(
                    children: [
                      Container(
                        width: 44 * scale,
                        height: 44 * scale,
                        decoration: BoxDecoration(
                          color: themeColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(12 * scale),
                        ),
                        child: Icon(Icons.location_on_rounded,
                            size: 22 * scale, color: themeColor),
                      ),
                      SizedBox(width: 14 * scale),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${user!.city}${user.country != null ? ', ${user.country}' : ''}',
                              style: TextStyle(
                                color: Colors.white.withAlpha(230),
                                fontSize: 16 * scale,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: 2 * scale),
                            Text(
                              '${user.latitude?.toStringAsFixed(4)}, ${user.longitude?.toStringAsFixed(4)}',
                              style: TextStyle(
                                color: Colors.white.withAlpha(80),
                                fontSize: 11 * scale,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20 * scale),
                ],
                _buildActionButton(
                  'Update Location',
                  Icons.my_location_rounded,
                  themeColor,
                  () async {
                    await userProvider.getCurrentLocation();
                    _showInlineStatus('Location updated');
                  },
                  scale,
                ),
              ],
            ),
          ),
          SizedBox(height: 12 * scale),
          _buildStatusMessage(scale),
          ],

          // ─── Notification Section ───
          if (_activeSection == 'notify') ...[
            _buildSectionLabel('NOTIFICATIONS', scale),
            SizedBox(height: 12 * scale),
            GlassContainer(
              padding: EdgeInsets.all(20 * scale),
              child: Row(
                children: [
                  Container(
                    width: 52 * scale,
                    height: 52 * scale,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [themeColor, Colors.orange.shade700],
                      ),
                      borderRadius: BorderRadius.circular(16 * scale),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withAlpha(80),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.notifications_active_rounded, size: 24 * scale, color: Colors.black),
                  ),
                  SizedBox(width: 16 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Reminders',
                          style: TextStyle(
                            fontSize: 17 * scale,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Text(
                          'Enable notifications for all prayers',
                          style: TextStyle(
                            fontSize: 12 * scale,
                            color: Colors.white.withAlpha(140),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildReminderSwitch(
                    userProvider.areAllRemindersEnabled,
                    (val) => userProvider.toggleAllReminders(val),
                    scale,
                    themeColor,
                  ),
                ],
              ),
            ),
            SizedBox(height: 14 * scale),
            _buildPrayerReminderCard('Fajr', userProvider, scale),
            _buildPrayerReminderCard('Dhuhr', userProvider, scale),
            _buildPrayerReminderCard('Asr', userProvider, scale),
            _buildPrayerReminderCard('Maghrib', userProvider, scale),
            _buildPrayerReminderCard('Isha', userProvider, scale),
            SizedBox(height: 20 * scale),
            _buildSectionLabel('REMINDER TIMING', scale),
            SizedBox(height: 12 * scale),
            GlassContainer(
              padding: EdgeInsets.all(20 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notify me before Adhan',
                    style: TextStyle(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                  SizedBox(height: 16 * scale),
                  Wrap(
                    spacing: 8 * scale,
                    runSpacing: 8 * scale,
                    children: [5, 10, 15, 30].map((minutes) {
                      final isSelected = userProvider.reminderMinutesBefore == minutes;
                      return GestureDetector(
                        onTap: () {
                          userProvider.setReminderMinutesBefore(minutes);
                          _showInlineStatus('Reminder set: ${minutes}m before Adhan');
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: (MediaQuery.of(context).size.width - 2 * horizontalPadding - 40 * scale - 24 * scale) / 4,
                          padding: EdgeInsets.symmetric(vertical: 14 * scale),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? themeColor.withAlpha(30)
                                : Colors.white.withAlpha(5),
                            borderRadius: BorderRadius.circular(12 * scale),
                            border: Border.all(
                              color: isSelected
                                  ? themeColor.withAlpha(150)
                                  : Colors.white.withAlpha(15),
                              width: isSelected ? 1.5 : 0.8,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(color: themeColor.withAlpha(30), blurRadius: 10)
                            ] : null,
                          ),
                          child: Center(
                            child: Text(
                              '${minutes}m',
                              style: TextStyle(
                                fontSize: (isSmallScreen ? 13 : 15) * scale,
                                fontWeight: FontWeight.w800,
                                color: isSelected
                                    ? themeColor
                                    : Colors.white.withAlpha(130),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12 * scale),
            _buildStatusMessage(scale),
          ],

          // ─── Iqama Section ───
          if (_activeSection == 'iqama') ...[
          _buildSectionLabel('IQAMA TIME', scale),
          SizedBox(height: 12 * scale),
          GlassContainer(
            padding: EdgeInsets.all(20 * scale),
            child: Column(
              children: [
                _buildIqamaOffsetRow('Fajr', scale, themeColor),
                _buildIqamaOffsetRow('Dhuhr', scale, themeColor),
                _buildIqamaOffsetRow('Asr', scale, themeColor),
                _buildIqamaOffsetRow('Maghrib', scale, themeColor),
                _buildIqamaOffsetRow('Isha', scale, themeColor),
              ],
            ),
          ),
          SizedBox(height: 12 * scale),
          _buildStatusMessage(scale),
          ],

          // ─── Device Section ───
          if (_activeSection == 'device') ...[
          _buildSectionLabel('DEVICE ID', scale),
          SizedBox(height: 12 * scale),
          GlassContainer(
            padding: EdgeInsets.all(20 * scale),
            child: Row(
              children: [
                Icon(Icons.fingerprint_rounded, size: 22 * scale,
                    color: Colors.white.withAlpha(60)),
                SizedBox(width: 14 * scale),
                Expanded(
                  child: Text(
                    user?.userId ?? 'Not available',
                    style: TextStyle(
                      color: Colors.white.withAlpha(80),
                      fontSize: 12 * scale,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          ],
          SizedBox(height: 48 * scale),
        ],
      ),
    );
  }

  // ─── Helper Widgets ───

  Widget _buildStatusMessage(double scale) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _statusMessage == null
          ? const SizedBox.shrink()
          : Container(
              key: ValueKey<String>(_statusMessage!),
              padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 10 * scale),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(color: const Color(0xFF10B981).withAlpha(80)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_rounded, size: 16 * scale, color: const Color(0xFF10B981)),
                  SizedBox(width: 10 * scale),
                  Text(
                    _statusMessage!,
                    style: TextStyle(
                      color: Colors.white.withAlpha(230),
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTabs(double scale, Color themeColor, bool isSmallScreen) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildSectionTabButton('PROFILE', 'profile', Icons.person_outline_rounded, scale, themeColor, isSmallScreen),
          _buildSectionTabButton('NOTIFY', 'notify', Icons.notifications_active_rounded, scale, themeColor, isSmallScreen),
          _buildSectionTabButton('LOCATION', 'location', Icons.my_location_rounded, scale, themeColor, isSmallScreen),
          _buildSectionTabButton('IQAMA', 'iqama', Icons.schedule_rounded, scale, themeColor, isSmallScreen),
          _buildSectionTabButton('DEVICE', 'device', Icons.fingerprint_rounded, scale, themeColor, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildSectionTabButton(String label, String key, IconData icon, double scale, Color themeColor, bool isSmallScreen) {
    final isActive = _activeSection == key;
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    return GestureDetector(
      onTap: () => setState(() => _activeSection = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: EdgeInsets.only(right: (isCompact ? 3 : 4) * scale),
        padding: EdgeInsets.symmetric(
          horizontal: (isActive ? (isCompact ? 10 : 12) : (isCompact ? 7 : 8)) * scale,
          vertical: (isCompact ? 8 : 10) * scale,
        ),
        decoration: BoxDecoration(
          color: isActive ? themeColor.withAlpha(30) : Colors.white.withAlpha(5),
          borderRadius: BorderRadius.circular((isCompact ? 10 : 12) * scale),
          border: Border.all(
            color: isActive ? themeColor.withAlpha(150) : Colors.white.withAlpha(15),
            width: isActive ? (isCompact ? 1.2 : 1.3) : (isCompact ? 0.6 : 0.7),
          ),
          boxShadow: isActive ? [
            BoxShadow(color: themeColor.withAlpha(20), blurRadius: (isCompact ? 6 : 8))
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: (isActive ? (isCompact ? 12 : 14) : (isCompact ? 11 : 12)) * scale,
              color: isActive ? themeColor : Colors.white.withAlpha(150),
            ),
            SizedBox(width: (isActive ? (isCompact ? 5 : 6) : (isCompact ? 2 : 3)) * scale),
            Text(
              label,
              style: TextStyle(
                fontSize: (isSmallScreen ? (isCompact ? 9 : 10) : (isCompact ? 10 : 11)) * scale,
                fontWeight: FontWeight.w800,
                color: isActive ? Colors.white : Colors.white.withAlpha(130),
                letterSpacing: (isCompact ? 0.2 : 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, double scale) {
    return Padding(
      padding: EdgeInsets.only(left: 4 * scale),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11 * scale,
          fontWeight: FontWeight.w800,
          color: Colors.white.withAlpha(80),
          letterSpacing: 2.5,
        ),
      ),
    );
  }

  Widget _buildLabel(String label, double scale) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final isMedium = screenWidth < 400;
    return Text(
      label,
      style: TextStyle(
        fontSize: (isCompact ? 11 : isMedium ? 12 : 13) * scale,
        fontWeight: FontWeight.w600,
        color: Colors.white.withAlpha(150),
      ),
    );
  }

  Widget _buildGlassTextField(TextEditingController controller, String hint, double scale, Color themeColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final isMedium = screenWidth < 400;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular((isCompact ? 12 : isMedium ? 14 : 16) * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(
          color: Colors.white.withAlpha(240),
          fontSize: (isCompact ? 13 : isMedium ? 14 : 15) * scale,
          fontWeight: FontWeight.w500,
        ),
        cursorColor: themeColor,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withAlpha(70),
            fontSize: (isCompact ? 13 : isMedium ? 14 : 15) * scale,
          ),
          filled: true,
          fillColor: const Color(0xFF121212).withAlpha(180),
          contentPadding: EdgeInsets.symmetric(
            horizontal: (isCompact ? 14 : isMedium ? 16 : 18) * scale,
            vertical: (isCompact ? 14 : isMedium ? 16 : 18) * scale,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular((isCompact ? 12 : isMedium ? 14 : 16) * scale),
            borderSide: BorderSide(color: Colors.white.withAlpha(15)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular((isCompact ? 12 : isMedium ? 14 : 16) * scale),
            borderSide: BorderSide(color: Colors.white.withAlpha(15)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular((isCompact ? 12 : isMedium ? 14 : 16) * scale),
            borderSide: BorderSide(color: themeColor, width: isCompact ? 1.5 : 1.8),
          ),
        ),
      ),
    );
  }

  Widget _buildPillButton(String label, IconData icon, bool isSelected, VoidCallback onTap, double scale, Color themeColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final isMedium = screenWidth < 400;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(vertical: (isCompact ? 8 : isMedium ? 10 : 12) * scale),
        decoration: BoxDecoration(
          color: isSelected
              ? themeColor.withAlpha(30)
              : Colors.white.withAlpha(6),
          borderRadius: BorderRadius.circular((isCompact ? 10 : 12) * scale),
          border: Border.all(
            color: isSelected
                ? themeColor.withAlpha(180)
                : Colors.white.withAlpha(15),
            width: isSelected ? (isCompact ? 1.2 : 1.3) : (isCompact ? 0.6 : 0.7),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: themeColor.withAlpha(40),
                    blurRadius: (isCompact ? 8 : 10) * scale,
                    offset: Offset(0, (isCompact ? 2 : 3) * scale),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: (isCompact ? 14 : isMedium ? 16 : 18) * scale,
              color: isSelected ? themeColor : Colors.white.withAlpha(100),
            ),
            SizedBox(width: (isCompact ? 5 : 6) * scale),
            Text(
              label,
              style: TextStyle(
                fontSize: (isCompact ? 10 : isMedium ? 11 : 12) * scale,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.white.withAlpha(160),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap, double scale) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final isMedium = screenWidth < 400;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: (isCompact ? 10 : isMedium ? 12 : 14) * scale),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular((isCompact ? 10 : 12) * scale),
          border: Border.all(
            color: color.withAlpha(80),
            width: isCompact ? 1.2 : 1.3,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: (isCompact ? 16 : isMedium ? 17 : 18) * scale, color: color),
            SizedBox(width: (isCompact ? 6 : 8) * scale),
            Text(
              label,
              style: TextStyle(
                fontSize: (isCompact ? 11 : isMedium ? 12 : 13) * scale,
                fontWeight: FontWeight.w800,
                color: color,
                letterSpacing: (isCompact ? 0.2 : 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerReminderCard(String prayer, UserProvider userProvider, double scale) {
    final themeColor = AppTheme.accentGold;
    final prayerIcon = AppTheme.getPrayerIcon(prayer);
    final isEnabled = userProvider.isReminderEnabled(prayer);

    return Padding(
      padding: EdgeInsets.only(bottom: 12 * scale),
      child: GlassContainer(
        padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 14 * scale),
        variant: isEnabled ? GlassVariant.elevated : GlassVariant.standard,
        accentColor: isEnabled ? themeColor : null,
        child: Row(
          children: [
            Container(
              width: 48 * scale,
              height: 48 * scale,
              decoration: BoxDecoration(
                color: isEnabled ? themeColor.withAlpha(25) : Colors.white.withAlpha(5),
                borderRadius: BorderRadius.circular(14 * scale),
                border: Border.all(
                  color: isEnabled ? themeColor.withAlpha(120) : Colors.white.withAlpha(15),
                  width: 1.5,
                ),
              ),
              child: Icon(
                prayerIcon,
                size: 22 * scale,
                color: isEnabled ? themeColor : Colors.white.withAlpha(120),
              ),
            ),
            SizedBox(width: 18 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayer,
                    style: TextStyle(
                      fontSize: 17 * scale,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  if (isEnabled)
                    Padding(
                      padding: EdgeInsets.only(top: 2 * scale),
                      child: Text(
                        'Reminder active',
                        style: TextStyle(
                          fontSize: 11 * scale,
                          color: themeColor.withAlpha(200),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            _buildReminderSwitch(
              isEnabled,
              (val) => userProvider.toggleReminder(prayer, val),
              scale,
              themeColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSwitch(bool value, ValueChanged<bool> onChanged, double scale, Color themeColor) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        width: 58 * scale,
        height: 32 * scale,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16 * scale),
          color: value ? themeColor : Colors.white.withAlpha(15),
          border: Border.all(
            color: value ? themeColor : Colors.white.withAlpha(25),
            width: 1.5,
          ),
          boxShadow: value ? [
            BoxShadow(color: themeColor.withAlpha(60), blurRadius: 12, spreadRadius: -2)
          ] : null,
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              left: value ? 28 * scale : 4 * scale,
              top: 3 * scale,
              child: Container(
                width: 24 * scale,
                height: 24 * scale,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
                  ],
                ),
                child: value
                    ? Icon(Icons.check_rounded, size: 15 * scale, color: themeColor)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIqamaOffsetRow(String prayerName, double scale, Color themeColor) {
    final minutes = _iqamaOffsets[prayerName] ?? 0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
      child: Row(
        children: [
          Expanded(
            child: Text(
              prayerName,
              style: TextStyle(
                fontSize: 16 * scale,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          _buildOffsetButton(
            icon: Icons.remove_rounded,
            onTap: () => _changeIqamaOffset(prayerName, -1),
            scale: scale,
            themeColor: themeColor,
          ),
          SizedBox(width: 12 * scale),
          Container(
            constraints: BoxConstraints(minWidth: 70 * scale),
            padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 10 * scale),
            decoration: BoxDecoration(
              color: themeColor.withAlpha(20),
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: themeColor.withAlpha(60), width: 1.5),
            ),
            child: Center(
              child: Text(
                '+$minutes min',
                style: TextStyle(
                  fontSize: 13 * scale,
                  fontWeight: FontWeight.w900,
                  color: themeColor,
                ),
              ),
            ),
          ),
          SizedBox(width: 12 * scale),
          _buildOffsetButton(
            icon: Icons.add_rounded,
            onTap: () => _changeIqamaOffset(prayerName, 1),
            scale: scale,
            themeColor: themeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildOffsetButton({
    required IconData icon,
    required VoidCallback onTap,
    required double scale,
    required Color themeColor,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final isMedium = screenWidth < 400;
    final buttonSize = (isCompact ? 34 : isMedium ? 36 : 38) * scale;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular((isCompact ? 10 : 12) * scale),
          border: Border.all(
            color: Colors.white.withAlpha(20),
            width: isCompact ? 1.0 : 1.2,
          ),
        ),
        child: Icon(
          icon,
          size: (isCompact ? 18 : isMedium ? 19 : 20) * scale,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildGradientButton(String label, IconData icon, VoidCallback onTap, double scale, Color themeColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final isMedium = screenWidth < 400;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: (isCompact ? 10 : isMedium ? 12 : 14) * scale,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [themeColor, Colors.orange.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular((isCompact ? 12 : isMedium ? 14 : 16) * scale),
          boxShadow: [
            BoxShadow(
              color: themeColor.withAlpha(50),
              blurRadius: isCompact ? 12 : 16,
              offset: Offset(0, isCompact ? 4 : 6),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: (isCompact ? 16 : isMedium ? 18 : 20) * scale,
              color: Colors.black,
            ),
            SizedBox(width: (isCompact ? 6 : isMedium ? 8 : 10) * scale),
            Text(
              label,
              style: TextStyle(
                fontSize: (isCompact ? 12 : isMedium ? 13 : 14) * scale,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: (isCompact ? 0.4 : 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
