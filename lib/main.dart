import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/user_model.dart';
import 'models/prayer_times_model.dart';
import 'models/qada_model.dart';
import 'models/ramadan_model.dart';
import 'providers/user_provider.dart';
import 'screens/home_screen.dart';
import 'screens/qibla_screen.dart';
import 'screens/ramadan_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/cosmic_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(GenderAdapter());
  Hive.registerAdapter(PrayerTimesModelAdapter());
  Hive.registerAdapter(QadaModelAdapter());
  Hive.registerAdapter(RamadanModelAdapter());

  runApp(const SalahUmmaApp());
}

class SalahUmmaApp extends StatelessWidget {
  const SalahUmmaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider()..initialize(),
      child: MaterialApp(
        title: 'Salah Umma',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.transparent,
          fontFamily: 'Roboto',
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return CosmicBackground(
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        drawer: _buildDrawer(context, isLeft: true),
        endDrawer: _buildSettingsDrawer(context),
        body: SafeArea(
          child: Column(
            children: [
              // Top bar with menu and settings
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Menu button (left)
                    _buildIconButton(
                      icon: Icons.menu_rounded,
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    ),
                    // Settings button (right)
                    _buildIconButton(
                      icon: Icons.settings_outlined,
                      onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                    ),
                  ],
                ),
              ),
              // Main content
              const Expanded(child: HomeScreen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        color: Colors.white.withAlpha(220),
        size: 26,
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, {required bool isLeft}) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(180),
              border: Border(
                right: isLeft ? BorderSide(color: Colors.white.withAlpha(40)) : BorderSide.none,
                left: !isLeft ? BorderSide(color: Colors.white.withAlpha(40)) : BorderSide.none,
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header - compact
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.mosque, color: Colors.white.withAlpha(220), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Salah Umma',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Prayer Companion',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white.withAlpha(100),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withAlpha(20), height: 1),
                    const SizedBox(height: 12),
                    // Menu items - compact
                    _buildMenuItem(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildMenuItem(
                      icon: Icons.explore_rounded,
                      label: 'Qibla Compass',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QiblaScreen()),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.calendar_month_rounded,
                      label: 'Ramadan Tracker',
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const RamadanScreen()),
                        );
                      },
                    ),
                    const Spacer(),
                    // Footer
                    Text(
                      'v1.0.0',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white.withAlpha(50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withAlpha(180), size: 18),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(180),
              border: Border(
                left: BorderSide(color: Colors.white.withAlpha(40)),
              ),
            ),
            child: const SafeArea(
              child: SettingsDrawerContent(),
            ),
          ),
        ),
      ),
    );
  }
}

/// Settings drawer content as StatefulWidget
class SettingsDrawerContent extends StatefulWidget {
  const SettingsDrawerContent({super.key});

  @override
  State<SettingsDrawerContent> createState() => _SettingsDrawerContentState();
}

class _SettingsDrawerContentState extends State<SettingsDrawerContent> {
  final _nameController = TextEditingController();
  DateTime? _selectedDate;
  Gender? _selectedGender;
  bool _isInitialized = false;

  // Iqama offsets (minutes after Adhan)
  Map<String, int> _iqamaOffsets = {
    'Fajr': 15,
    'Dhuhr': 10,
    'Asr': 10,
    'Maghrib': 5,
    'Isha': 10,
  };

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
      _iqamaOffsets = Map.from(user.iqamaOffsets);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings saved!'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.settings_outlined, color: Colors.white.withAlpha(220), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Profile Section
          _buildSectionLabel('PROFILE'),
          const SizedBox(height: 8),

          // Name field
          SizedBox(
            height: 42,
            child: TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: Colors.white.withAlpha(150), fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withAlpha(40)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withAlpha(120)),
                ),
                filled: true,
                fillColor: Colors.white.withAlpha(10),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Date of Birth & Gender in row
          Row(
            children: [
              // Date of Birth
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withAlpha(40)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.white.withAlpha(150), size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _selectedDate != null
                                ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                : 'Birth date',
                            style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(200)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Gender
              _buildMiniGenderOption('M', Gender.male),
              const SizedBox(width: 4),
              _buildMiniGenderOption('F', Gender.female),
            ],
          ),
          const SizedBox(height: 10),

          // Save button
          GestureDetector(
            onTap: _saveSettings,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withAlpha(40)),
              ),
              child: Center(
                child: Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Location Section
          _buildSectionLabel('LOCATION'),
          const SizedBox(height: 8),

          Row(
            children: [
              // Location display
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.white.withAlpha(150), size: 14),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          user?.city != null
                              ? '${user!.city}${user.country != null ? ', ${user.country}' : ''}'
                              : 'Not set',
                          style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(180)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Update button
              GestureDetector(
                onTap: () async {
                  await userProvider.getCurrentLocation();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Location updated!'),
                        backgroundColor: const Color(0xFF10B981),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withAlpha(40)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.my_location, color: Colors.white.withAlpha(180), size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Update',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Iqama Settings Section
          _buildSectionLabel('IQAMA TIME'),
          const SizedBox(height: 6),

          // Iqama offset controls - compact grid
          ..._buildIqamaOffsetControls(),

          const SizedBox(height: 14),

          // UI Scale Section
          _buildSectionLabel('UI SCALE'),
          const SizedBox(height: 8),
          _buildUiScaleSlider(),
        ],
      ),
    );
  }

  Widget _buildUiScaleSlider() {
    final userProvider = context.watch<UserProvider>();
    final currentScale = userProvider.user?.uiScale ?? 1.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '70%',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withAlpha(120),
                ),
              ),
              Text(
                '${(currentScale * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withAlpha(240),
                ),
              ),
              Text(
                '130%',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withAlpha(120),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF3B82F6),
              inactiveTrackColor: Colors.white.withAlpha(30),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withAlpha(30),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: currentScale,
              min: 0.7,
              max: 1.3,
              divisions: 12,
              onChanged: (value) {
                context.read<UserProvider>().updateUiScale(value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: Colors.white.withAlpha(100),
        letterSpacing: 0.5,
      ),
    );
  }

  List<Widget> _buildIqamaOffsetControls() {
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    return prayers.map((prayer) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(8),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  prayer,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ),
              const Spacer(),
              // Minus button
              GestureDetector(
                onTap: () {
                  if (_iqamaOffsets[prayer]! > 0) {
                    setState(() {
                      _iqamaOffsets[prayer] = _iqamaOffsets[prayer]! - 1;
                    });
                    context.read<UserProvider>().updateIqamaOffset(prayer, _iqamaOffsets[prayer]!);
                  }
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.remove, color: Colors.white.withAlpha(160), size: 14),
                ),
              ),
              // Value display
              Container(
                width: 44,
                alignment: Alignment.center,
                child: Text(
                  '${_iqamaOffsets[prayer]}m',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withAlpha(220),
                  ),
                ),
              ),
              // Plus button
              GestureDetector(
                onTap: () {
                  if (_iqamaOffsets[prayer]! < 60) {
                    setState(() {
                      _iqamaOffsets[prayer] = _iqamaOffsets[prayer]! + 1;
                    });
                    context.read<UserProvider>().updateIqamaOffset(prayer, _iqamaOffsets[prayer]!);
                  }
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.add, color: Colors.white.withAlpha(160), size: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMiniGenderOption(String label, Gender value) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = value),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withAlpha(30) : Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white.withAlpha(100) : Colors.white.withAlpha(40),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: Colors.white.withAlpha(isSelected ? 240 : 160),
            ),
          ),
        ),
      ),
    );
  }
}
