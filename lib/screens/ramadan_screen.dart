import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/ramadan_service.dart';
import '../models/ramadan_model.dart';
import '../widgets/glass_container.dart';

class RamadanScreen extends StatefulWidget {
  const RamadanScreen({super.key});

  @override
  State<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends State<RamadanScreen> {
  List<RamadanPeriod> _ramadanHistory = [];
  int _selectedRamadanIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadRamadanHistory();
  }

  void _loadRamadanHistory() {
    final userProvider = context.read<UserProvider>();
    final user = userProvider.user;

    if (user?.maturityDate != null) {
      setState(() {
        _ramadanHistory = RamadanService.calculateRamadanHistory(user!.maturityDate!);
        if (_ramadanHistory.isNotEmpty) {
          _selectedRamadanIndex = _ramadanHistory.length - 1; // Most recent
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final user = userProvider.user;
    final ramadan = userProvider.ramadan;

    if (user?.maturityDate == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Ramadan Tracker'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: const Text(
              'Please set your date of birth and gender in settings',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (_ramadanHistory.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Ramadan Tracker'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: GlassContainer(
            padding: const EdgeInsets.all(24),
            child: const Text(
              'No Ramadan history available',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    final selectedRamadan = _ramadanHistory[_selectedRamadanIndex];
    final fastedDays = ramadan?.getFastedDaysCount(
          selectedRamadan.year,
          selectedRamadan.month,
        ) ??
        0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Ramadan Tracker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ramadan selector
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Select Ramadan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _selectedRamadanIndex > 0
                            ? () {
                                setState(() {
                                  _selectedRamadanIndex--;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.white,
                      ),
                      Text(
                        'Ramadan ${selectedRamadan.year}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: _selectedRamadanIndex < _ramadanHistory.length - 1
                            ? () {
                                setState(() {
                                  _selectedRamadanIndex++;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Started: ${selectedRamadan.startDate.day}/${selectedRamadan.startDate.month}/${selectedRamadan.startDate.year}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: fastedDays / 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$fastedDays / 30 days fasted',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Calendar grid
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Mark Fasted Days',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: 30,
                    itemBuilder: (context, index) {
                      final day = index + 1;
                      final isFasted = ramadan?.isDayFasted(
                            selectedRamadan.year,
                            selectedRamadan.month,
                            day,
                          ) ??
                          false;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isFasted) {
                              ramadan?.unmarkDayFasted(
                                selectedRamadan.year,
                                selectedRamadan.month,
                                day,
                              );
                            } else {
                              ramadan?.markDayFasted(
                                selectedRamadan.year,
                                selectedRamadan.month,
                                day,
                              );
                            }
                            ramadan?.save();
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isFasted
                                ? Colors.greenAccent
                                : Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$day',
                              style: TextStyle(
                                color: isFasted ? Colors.black : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

