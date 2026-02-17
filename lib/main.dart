import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'models/user_model.dart';
import 'models/prayer_times_model.dart';
import 'models/qada_model.dart';
import 'models/ramadan_model.dart';
import 'providers/user_provider.dart';
import 'screens/home_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/tasbih_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/cosmic_background.dart';
import 'widgets/bottom_navigation_bar.dart';
import 'widgets/side_menu_drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Immersive status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

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
      child: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          return MaterialApp(
            title: 'Salah Umma',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              primaryColor: const Color(0xFF00D9FF),
              scaffoldBackgroundColor: Colors.black,
              textTheme: GoogleFonts.outfitTextTheme(Theme.of(context).textTheme).apply(
                bodyColor: Colors.white,
                displayColor: Colors.white,
              ),
              colorScheme: const ColorScheme.dark(
                primary: Color(0xFF00D9FF),
                secondary: Color(0xFF8B5CF6),
                surface: Colors.transparent,
              ),
            ),
            builder: (context, child) {
              final scale = userProvider.user?.uiScale ?? 1.0;
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(scale),
                ),
                child: child!,
              );
            },
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  double _topBarScrollProgress = 0.0;

  final List<Widget> _screens = const [
    HomeScreen(),
    StatsScreen(),
    TasbihScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final scale = userProvider.user?.uiScale ?? 1.0;
    final requestedTab = userProvider.consumeRequestedTab();
    if (requestedTab != null && requestedTab != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _currentIndex = requestedTab;
        });
      });
    }

    // Get current prayer name for background
    final currentPrayer = userProvider.nextPrayer?.name;

    return CosmicBackground(
      currentPrayer: currentPrayer,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        drawer: SideMenuDrawer(
          onTabSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
        body: Stack(
          children: [
            // Main content with AnimatedSwitcher for page transitions
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                top: false, // Let content go under top bar
                child: NotificationListener<ScrollNotification>(
                  onNotification: _handleScrollNotification,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(_currentIndex),
                      child: _screens[_currentIndex],
                    ),
                  ),
                ),
              ),
            ),
            
            // Top bar with menu button (Floating Glass Header)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(bottom: 4 * scale),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(180), // Darker at top
                      Colors.black.withAlpha(150), // Slightly lighter
                      Colors.black.withAlpha(0),   // Fades to clear
                    ],
                    stops: const [0.0, 0.3, 1.0],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withAlpha(10),
                      width: 0.5,
                    ),
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20 * scale, vertical: 8 * scale),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildIconButton(
                          icon: Icons.menu_rounded,
                          onTap: () => _scaffoldKey.currentState?.openDrawer(),
                          scale: scale,
                        ),
                        const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom navigation floating pill
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: BottomNavigationBarWidget(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  scale: scale,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    final nextProgress = (notification.metrics.pixels / 120).clamp(0.0, 1.0);
    if ((nextProgress - _topBarScrollProgress).abs() > 0.02 && mounted) {
      setState(() {
        _topBarScrollProgress = nextProgress;
      });
    }
    return false;
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required double scale,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    final isMedium = screenWidth < 400;
    final buttonSize = (isCompact ? 36 : isMedium ? 38 : 40) * scale;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular((isCompact ? 10 : 12) * scale),
          border: Border.all(
            color: Colors.white.withAlpha(12),
            width: isCompact ? 0.8 : 1.0,
          ),
        ),
        child: Icon(
          icon,
          color: Colors.white.withAlpha(200),
          size: (isCompact ? 20 : isMedium ? 21 : 22) * scale,
        ),
      ),
    );
  }
}

