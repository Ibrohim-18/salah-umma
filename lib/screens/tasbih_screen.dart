import 'dart:math' as math;
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import '../providers/user_provider.dart';
import '../widgets/glass_container.dart';
import '../constants/app_theme.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> with TickerProviderStateMixin {
  int _count = 0;
  int _target = 33;
  int _cycles = 0;
  String _selectedDhikr = 'SubhanAllah';
  
  // Default dhikr categories - Gold theme
  final List<Map<String, dynamic>> _adhkar = [
    {'name': 'SubhanAllah', 'arabic': 'سُبْحَانَ اللَّهِ', 'color': AppTheme.accentGold},
    {'name': 'Alhambra', 'arabic': 'الْحَمْدُ لِلَّهِ', 'color': AppTheme.accentGold},
    {'name': 'Allahu Akbar', 'arabic': 'اللَّهُ أَكْبَرُ', 'color': AppTheme.accentGold},
    {'name': 'Astaghfirullah', 'arabic': 'أَسْتَغْفِرُ اللَّهَ', 'color': AppTheme.accentGold},
    {'name': 'La ilaha illallah', 'arabic': 'لَا إِلَهَ إِلَّا اللَّهُ', 'color': AppTheme.accentGold},
    {'name': 'Salawat', 'arabic': 'صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ', 'color': AppTheme.accentGold},
  ];

  // Custom dhikr list (stored separately)
  List<Map<String, dynamic>> _customAdhkar = [];
  List<Map<String, dynamic>> _history = [];

  late AnimationController _pulseController;
  late AnimationController _countController;
  late AnimationController _celebrationController;
  late Animation<double> _countAnimation;

  static const String _historyBoxName = 'tasbih_history';
  static const String _customBoxName = 'tasbih_custom';

  @override
  void initState() {
    super.initState();
    _loadData();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _countAnimation = CurvedAnimation(
      parent: _countController,
      curve: Curves.easeOutBack,
    );

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  Future<void> _loadData() async {
    await _loadHistory();
    await _loadCustomDhikr();
  }

  Future<void> _loadHistory() async {
    try {
      final box = await Hive.openBox(_historyBoxName);
      final data = box.get('sessions', defaultValue: '[]');
      final List<dynamic> decoded = json.decode(data);
      setState(() {
        _history = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } catch (e) {
      debugPrint('Error loading history: $e');
    }
  }

  Future<void> _loadCustomDhikr() async {
    try {
      final box = await Hive.openBox(_customBoxName);
      final data = box.get('custom_dhikr', defaultValue: '[]');
      final List<dynamic> decoded = json.decode(data);
      setState(() {
        _customAdhkar = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    } catch (e) {
      debugPrint('Error loading custom dhikr: $e');
    }
  }

  Future<void> _saveHistory() async {
    try {
      final box = await Hive.openBox(_historyBoxName);
      await box.put('sessions', json.encode(_history));
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }

  Future<void> _saveCustomDhikr() async {
    try {
      final box = await Hive.openBox(_customBoxName);
      await box.put('custom_dhikr', json.encode(_customAdhkar));
    } catch (e) {
      debugPrint('Error saving custom dhikr: $e');
    }
  }

  void _addToHistory() {
    if (_count == 0 && _cycles == 0) return;
    
    final session = {
      'dhikr': _selectedDhikr,
      'count': _count + (_cycles * _target),
      'cycles': _cycles,
      'target': _target,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    setState(() {
      _history.insert(0, session);
      // Keep only last 100 sessions
      if (_history.length > 100) {
        _history = _history.sublist(0, 100);
      }
    });
    
    _saveHistory();
  }

  void _addCustomDhikr(String name, String arabic, Color color) {
    final newDhikr = {
      'name': name,
      'arabic': arabic,
      'color': color.toARGB32(),
    };
    setState(() {
      _customAdhkar.add(newDhikr);
    });
    _saveCustomDhikr();
  }

  void _deleteCustomDhikr(int index) {
    setState(() {
      _customAdhkar.removeAt(index);
    });
    _saveCustomDhikr();
  }

  List<Map<String, dynamic>> get _allAdhkar => [..._adhkar, ..._customAdhkar];

  Color _getDhikrColor(String name) {
    for (var dhikr in _adhkar) {
      if (dhikr['name'] == name) return dhikr['color'];
    }
    for (var dhikr in _customAdhkar) {
      if (dhikr['name'] == name) return Color(dhikr['color'] as int);
    }
    return AppTheme.accentGold;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _countController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    HapticFeedback.mediumImpact();
    _countController.forward(from: 0.0);
    
    setState(() {
      if (_count < _target) {
        _count += 1;
        if (_count == _target) {
          _celebrate();
        }
      } else {
        _cycles += 1;
        _count = 1;
      }
    });
  }

  void _celebrate() {
    HapticFeedback.heavyImpact();
    _celebrationController.forward(from: 0.0);
    Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.vibrate());
  }

  void _resetCounter() {
    HapticFeedback.heavyImpact();
    // Save to history before reset
    _addToHistory();
    setState(() {
      _count = 0;
      _cycles = 0;
    });
  }

  void _showAddDhikrDialog() {
    final nameController = TextEditingController();
    final arabicController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Add Custom Dhikr', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Name (e.g., SubhanAllah)',
                hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: arabicController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Arabic (optional)',
                hintStyle: TextStyle(color: Colors.white.withAlpha(100)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                _addCustomDhikr(
                  nameController.text,
                  arabicController.text.isNotEmpty ? arabicController.text : nameController.text,
                  AppTheme.accentGold,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final scale = userProvider.user?.uiScale ?? 1.0;
    final isSmallScreen = MediaQuery.of(context).size.width < 400;
    final horizontalPadding = (isSmallScreen ? 14.0 : 18.0) * scale;
    final progress = (_count / _target).clamp(0.0, 1.0);
    final themeColor = _getDhikrColor(_selectedDhikr);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(horizontalPadding, 64 * scale, horizontalPadding, 110 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(scale, isSmallScreen),
          SizedBox(height: 20 * scale),
          _buildSessionRow(scale, themeColor),
          SizedBox(height: 32 * scale),
          _buildMainCounter(scale, progress, themeColor),
          SizedBox(height: 32 * scale),
          _buildDhikrSwitch(scale, themeColor),
          SizedBox(height: 16 * scale),
          _buildTargetSelection(scale, themeColor),
          SizedBox(height: 24 * scale),
          _buildControlButtons(scale, themeColor),
          SizedBox(height: 24 * scale),
          _buildHistorySection(scale),
          SizedBox(height: 32 * scale),
        ],
      ),
    );
  }

  Widget _buildHeader(double scale, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tasbih',
                  style: TextStyle(
                    fontSize: (isSmallScreen ? 34 : 42) * scale,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -1.8,
                    height: 1.0,
                  ),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  'Custom dhikr counter with history',
                  style: TextStyle(
                    fontSize: (isSmallScreen ? 13 : 14) * scale,
                    color: Colors.white.withAlpha(140),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            IconButton(
              onPressed: _showAddDhikrDialog,
              icon: Container(
                padding: EdgeInsets.all(8 * scale),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withAlpha(20),
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                child: Icon(Icons.add, color: AppTheme.accentGold, size: 20 * scale),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSessionRow(double scale, Color themeColor) {
    final totalCount = _count + (_cycles * _target);
    return Row(
      children: [
        Expanded(
          child: _buildSessionTile('TARGET', '$_target', Icons.flag_rounded, scale, themeColor),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _buildSessionTile('CYCLES', '$_cycles', Icons.loop_rounded, scale, themeColor),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: _buildSessionTile('TOTAL', '$totalCount', Icons.add_circle_outline_rounded, scale, themeColor),
        ),
      ],
    );
  }

  Widget _buildSessionTile(String label, String value, IconData icon, double scale, Color themeColor) {
    return GlassContainer(
      variant: GlassVariant.standard,
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
      child: Row(
        children: [
          Icon(icon, size: 18 * scale, color: themeColor),
          SizedBox(width: 12 * scale),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10 * scale,
                  fontWeight: FontWeight.w900,
                  color: Colors.white.withAlpha(100),
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainCounter(double scale, double progress, Color themeColor) {
    return Center(
      child: GestureDetector(
        onTap: _incrementCounter,
        behavior: HitTestBehavior.opaque,
        child: AnimatedBuilder(
          animation: Listenable.merge([_pulseController, _celebrationController]),
          builder: (context, child) {
            final screenWidth = MediaQuery.of(context).size.width;
            final counterSize = math.min(screenWidth * 0.85, 300 * scale);
            
            return RepaintBoundary(
              child: CustomPaint(
                painter: _TasbihBeadPainter(
                  progress: progress,
                  pulseValue: _pulseController.value,
                  celebrationValue: _celebrationController.value,
                  accentColor: themeColor,
                  target: _target,
                ),
                child: Container(
                  width: counterSize,
                  height: counterSize,
                  alignment: Alignment.center,
                  child: ScaleTransition(
                    scale: Tween(begin: 1.0, end: 1.15).animate(_countAnimation),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Text(
                            _selectedDhikr,
                            key: ValueKey(_selectedDhikr),
                            style: TextStyle(
                              fontSize: 16 * scale,
                              color: themeColor.withAlpha(200),
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Text(
                          '$_count',
                          style: TextStyle(
                            fontSize: (counterSize * 0.3) * scale,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            height: 1.0,
                            shadows: [
                              Shadow(
                                color: themeColor.withAlpha(150),
                                blurRadius: 30 * _pulseController.value + 40 * _celebrationController.value,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'OF $_target',
                          style: TextStyle(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w900,
                            color: Colors.white.withAlpha(120),
                            letterSpacing: 2.5,
                          ),
                        ),
                        SizedBox(height: 16 * scale),
                        _buildCounterTag(scale, themeColor),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCounterTag(double scale, Color themeColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 8 * scale),
      decoration: BoxDecoration(
        color: themeColor.withAlpha(25),
        borderRadius: BorderRadius.circular(20 * scale),
        border: Border.all(color: themeColor.withAlpha(60), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: themeColor.withAlpha(30),
            blurRadius: 10,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Text(
        'TAP TO COUNT',
        style: TextStyle(
          fontSize: 10 * scale,
          color: themeColor,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
        ),
      ),
    );
  }

  Widget _buildDhikrSwitch(double scale, Color themeColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final isMedium = screenWidth < 400;
    final allDhikr = _allAdhkar;
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: allDhikr.map((dhikr) {
          final isSelected = _selectedDhikr == dhikr['name'];
          final color = dhikr['color'] is Color ? dhikr['color'] : Color(dhikr['color']);
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _selectedDhikr = dhikr['name']);
            },
            onLongPress: dhikr.containsKey('arabic') && _customAdhkar.any((e) => e['name'] == dhikr['name'])
                ? () => _showDeleteDialog(dhikr['name'])
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(right: (isCompact ? 5 : isMedium ? 6 : 8) * scale),
              padding: EdgeInsets.symmetric(
                horizontal: (isCompact ? 10 : isMedium ? 12 : 14) * scale,
                vertical: (isCompact ? 6 : isMedium ? 8 : 10) * scale,
              ),
              decoration: BoxDecoration(
                color: isSelected ? color.withAlpha(40) : Colors.white.withAlpha(5),
                borderRadius: BorderRadius.circular((isCompact ? 10 : isMedium ? 12 : 14) * scale),
                border: Border.all(
                  color: isSelected ? color.withAlpha(180) : Colors.white.withAlpha(15),
                  width: isCompact ? 1.3 : isMedium ? 1.5 : 1.8,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(color: color.withAlpha(30), blurRadius: 10, spreadRadius: -3)
                ] : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    dhikr['name'],
                    style: TextStyle(
                      fontSize: (isCompact ? 9 : isMedium ? 10 : 11) * scale,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : Colors.white.withAlpha(160),
                    ),
                  ),
                  if (dhikr['arabic'] != null)
                    Text(
                      dhikr['arabic'],
                      style: TextStyle(
                        fontSize: (isCompact ? 7 : isMedium ? 8 : 9) * scale,
                        color: isSelected ? color.withAlpha(180) : Colors.white.withAlpha(80),
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showDeleteDialog(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Delete Dhikr?', style: TextStyle(color: Colors.white)),
        content: Text('Remove "$name" from your list?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              final index = _customAdhkar.indexWhere((e) => e['name'] == name);
              if (index >= 0) {
                _deleteCustomDhikr(index);
                if (_selectedDhikr == name) {
                  setState(() => _selectedDhikr = 'SubhanAllah');
                }
              }
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSelection(double scale, Color themeColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final isMedium = screenWidth < 400;
    return Row(
      children: [33, 99, 100].map((target) {
        final isSelected = _target == target;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _target = target;
                if (_count > _target) _count = _target;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.symmetric(horizontal: (isCompact ? 2 : 3) * scale),
              padding: EdgeInsets.symmetric(vertical: (isCompact ? 6 : isMedium ? 8 : 10) * scale),
              decoration: BoxDecoration(
                color: isSelected ? themeColor.withAlpha(35) : Colors.white.withAlpha(5),
                borderRadius: BorderRadius.circular((isCompact ? 10 : isMedium ? 12 : 14) * scale),
                border: Border.all(
                  color: isSelected ? themeColor.withAlpha(120) : Colors.white.withAlpha(12),
                  width: isCompact ? 1.1 : isMedium ? 1.2 : 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  '$target',
                  style: TextStyle(
                    fontSize: (isCompact ? 11 : isMedium ? 13 : 14) * scale,
                    fontWeight: FontWeight.w900,
                    color: isSelected ? Colors.white : Colors.white.withAlpha(120),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildControlButtons(double scale, Color themeColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final isMedium = screenWidth < 400;
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            label: 'SAVE & RESET',
            onTap: _resetCounter,
            color: Colors.white,
            scale: scale,
          ),
        ),
        SizedBox(width: (isCompact ? 8 : isMedium ? 10 : 12) * scale),
        Expanded(
          flex: 2,
          child: _buildActionButton(
            label: 'COUNT +1',
            onTap: _incrementCounter,
            color: themeColor,
            scale: scale,
            isPrimary: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
    required double scale,
    bool isPrimary = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final isMedium = screenWidth < 400;
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        variant: isPrimary ? GlassVariant.elevated : GlassVariant.standard,
        padding: EdgeInsets.zero,
        accentColor: isPrimary ? color : null,
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: (isCompact ? 8 : isMedium ? 10 : 12) * scale,
          ),
          decoration: BoxDecoration(
            color: isPrimary ? color.withAlpha(50) : Colors.white.withAlpha(5),
            borderRadius: BorderRadius.circular((isCompact ? 10 : isMedium ? 12 : 14) * scale),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: (isCompact ? 9 : isMedium ? 10 : 11) * scale,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: (isCompact ? 0.5 : 0.7),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection(double scale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HISTORY',
              style: TextStyle(
                fontSize: 12 * scale,
                fontWeight: FontWeight.w800,
                color: Colors.white.withAlpha(180),
                letterSpacing: 2,
              ),
            ),
            if (_history.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() => _history.clear());
                  _saveHistory();
                },
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    fontSize: 11 * scale,
                    color: Colors.red.withAlpha(200),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 12 * scale),
        if (_history.isEmpty)
          GlassContainer(
            padding: EdgeInsets.all(24 * scale),
            child: Center(
              child: Text(
                'No sessions yet. Tap "SAVE & RESET" to save your progress.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12 * scale,
                  color: Colors.white.withAlpha(120),
                ),
              ),
            ),
          )
        else
          ..._history.take(10).map((session) => _buildHistoryItem(session, scale)),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> session, double scale) {
    final color = _getDhikrColor(session['dhikr']);
    final date = DateTime.parse(session['timestamp']);
    final formattedDate = '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    
    return Padding(
      padding: EdgeInsets.only(bottom: 8 * scale),
      child: GlassContainer(
        padding: EdgeInsets.all(12 * scale),
        child: Row(
          children: [
            Container(
              width: 4 * scale,
              height: 40 * scale,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session['dhikr'],
                    style: TextStyle(
                      fontSize: 13 * scale,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 10 * scale,
                      color: Colors.white.withAlpha(100),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${session['count']}',
                  style: TextStyle(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  '${session['cycles']} cycles',
                  style: TextStyle(
                    fontSize: 9 * scale,
                    color: Colors.white.withAlpha(100),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TasbihBeadPainter extends CustomPainter {
  final double progress;
  final double pulseValue;
  final double celebrationValue;
  final Color accentColor;
  final int target;

  _TasbihBeadPainter({
    required this.progress,
    required this.pulseValue,
    required this.celebrationValue,
    required this.accentColor,
    required this.target,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) / 2) - 15;
    
    // Background Glow Base
    final glowPaint = Paint()
      ..color = accentColor.withAlpha((20 * pulseValue + 50 * celebrationValue).toInt())
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 25 + 30 * celebrationValue);
    canvas.drawCircle(center, radius, glowPaint);

    // Track Paint
    final trackPaint = Paint()
      ..color = Colors.white.withAlpha(8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, trackPaint);

    // Beads Calculation
    final int totalBeads = 33;
    final double beadSpacing = (2 * math.pi) / totalBeads;
    
    for (int i = 0; i < totalBeads; i++) {
      final angle = -math.pi / 2 + (i * beadSpacing);
      final beadCenter = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      
      final double beadProgress = i / totalBeads;
      final bool isActive = progress >= beadProgress;
      
      if (isActive) {
        final activePaint = Paint()
          ..color = accentColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(beadCenter, 5, activePaint);
        
        final activeGlow = Paint()
          ..color = accentColor.withAlpha(150)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(beadCenter, 6, activeGlow);
      } else {
        final inactivePaint = Paint()
          ..color = Colors.white.withAlpha(20)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(beadCenter, 3, inactivePaint);
      }
    }

    if (progress > 0) {
      final angle = -math.pi / 2 + (2 * math.pi * progress);
      final indicatorPos = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      
      final indicatorPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(indicatorPos, 7 + (2 * pulseValue), indicatorPaint);
      
      final indicatorPulse = Paint()
        ..color = Colors.white.withAlpha(100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(indicatorPos, 12 + (6 * pulseValue), indicatorPulse);
    }
    
    if (celebrationValue > 0 && celebrationValue < 1.0) {
      final particPaint = Paint()..color = accentColor.withAlpha((255 * (1 - celebrationValue)).toInt());
      for (int i = 0; i < 16; i++) {
        final angle = (i * 2 * math.pi) / 16;
        final distVal = radius + (celebrationValue * 120);
        final pCenter = Offset(
          center.dx + distVal * math.cos(angle),
          center.dy + distVal * math.sin(angle),
        );
        canvas.drawCircle(pCenter, 5 * (1 - celebrationValue), particPaint);
      }
      
      final explosionGlow = Paint()
        ..color = accentColor.withAlpha((40 * (1 - celebrationValue)).toInt())
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 50 * celebrationValue);
      canvas.drawCircle(center, radius + 20, explosionGlow);
    }
    
    final innerLayerPaint = Paint()
      ..color = accentColor.withAlpha(10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawCircle(center, radius - 25, innerLayerPaint);
    canvas.drawCircle(center, radius - 30, innerLayerPaint);
  }

  @override
  bool shouldRepaint(_TasbihBeadPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.pulseValue != pulseValue || 
           oldDelegate.celebrationValue != celebrationValue ||
           oldDelegate.target != target;
  }
}
