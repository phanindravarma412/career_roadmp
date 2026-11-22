import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/guides_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/plan_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/reviews_screen.dart';
import 'screens/today_screen.dart';
import 'services/reminders.dart';
import 'services/repo_sync.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final reminders = Reminders();
  await reminders.init();

  // Last copy synced from GitHub, or the copy bundled in the app.
  final snapshot = ContentStore.loadCached(prefs) ?? await ContentStore.loadBundled(rootBundle);

  final state = AppState.fromSnapshot(
    snapshot,
    prefs: prefs,
    reminders: reminders,
    sync: GitHubSync(),
  );
  runApp(RoadmapApp(state: state));
  // Pull the latest plan and check-ins in the background.
  state.syncNow();
}

class RoadmapApp extends StatelessWidget {
  const RoadmapApp({super.key, required this.state});
  final AppState state;

  ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5),
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Roadmap',
        debugShowCheckedModeBanner: false,
        theme: _theme(Brightness.light),
        darkTheme: _theme(Brightness.dark),
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return state.onboarded ? const HomeShell() : const OnboardingScreen();
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> with WidgetsBindingObserver {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => AppScope.of(context).refreshReminders(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState s) {
    // A new calendar day may have started while the app was in the background.
    if (s == AppLifecycleState.resumed) {
      setState(() {});
      final state = AppScope.of(context);
      state.refreshReminders();
      state.syncNow(ifOlderThan: const Duration(minutes: 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    const screens = [TodayScreen(), PlanScreen(), ReviewsScreen(), ProgressScreen(), GuidesScreen()];
    return Scaffold(
      body: IndexedStack(index: _tab, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.today_outlined), selectedIcon: Icon(Icons.today_rounded), label: 'Today'),
          NavigationDestination(icon: Icon(Icons.view_list_outlined), selectedIcon: Icon(Icons.view_list_rounded), label: 'Plan'),
          NavigationDestination(icon: Icon(Icons.fact_check_outlined), selectedIcon: Icon(Icons.fact_check_rounded), label: 'Reviews'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights_rounded), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded), label: 'Guides'),
        ],
      ),
    );
  }
}
