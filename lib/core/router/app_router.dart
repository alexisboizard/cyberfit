import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/onboarding/welcome_screen.dart';
import '../../screens/onboarding/questionnaire_screen.dart';
import '../../screens/onboarding/results_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/progress/progress_screen.dart';
import '../../screens/guides/guides_screen.dart';
import '../../screens/guides/guide_detail_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/challenge/challenge_detail_screen.dart';
import '../../screens/leaderboard/leaderboard_screen.dart';
import '../../screens/quiz/quiz_list_screen.dart';
import '../../screens/quiz/quiz_play_screen.dart';
import '../../screens/news/news_screen.dart';
import '../../screens/premium/paywall_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/tools/tools_hub_screen.dart';
import '../../screens/tools/password_checker_screen.dart';
import '../../screens/tools/email_exposure_screen.dart';
import '../../screens/tools/url_analyzer_screen.dart';
import '../../screens/tools/security_checklist_screen.dart';
import '../../screens/tools/phishing_simulator_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userAsync = ref.watch(userStreamProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) {
        // Check onboarding
        final user = userAsync.valueOrNull;
        if (user != null && !user.onboardingCompleted) {
          return '/onboarding';
        }
        return '/home';
      }

      // Redirect to onboarding if needed
      if (isLoggedIn && state.matchedLocation == '/home') {
        final user = userAsync.valueOrNull;
        if (user != null && !user.onboardingCompleted) {
          return '/onboarding';
        }
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Onboarding routes
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/questionnaire',
        builder: (context, state) => const QuestionnaireScreen(),
      ),
      GoRoute(
        path: '/onboarding/results',
        builder: (context, state) {
          final scores = state.extra as Map<String, int>? ?? {};
          return ResultsScreen(scores: scores);
        },
      ),

      // Main app with bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/tools',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ToolsHubScreen()),
          ),
          GoRoute(
            path: '/progress',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProgressScreen()),
          ),
          GoRoute(
            path: '/guides',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: GuidesScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),

      // Leaderboard (full screen)
      GoRoute(
        path: '/leaderboard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LeaderboardScreen(),
      ),

      // Tools detail routes
      GoRoute(
        path: '/tools/password',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PasswordCheckerScreen(),
      ),
      GoRoute(
        path: '/tools/email',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EmailExposureScreen(),
      ),
      GoRoute(
        path: '/tools/url',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const UrlAnalyzerScreen(),
      ),
      GoRoute(
        path: '/tools/checklist',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SecurityChecklistScreen(),
      ),
      GoRoute(
        path: '/tools/phishing',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PhishingSimulatorScreen(),
      ),

      // Premium
      GoRoute(
        path: '/premium',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PaywallScreen(),
      ),

      // News
      GoRoute(
        path: '/news',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NewsScreen(),
      ),

      // Settings
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Quiz routes
      GoRoute(
        path: '/quizzes',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const QuizListScreen(),
      ),
      GoRoute(
        path: '/quiz/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return QuizPlayScreen(quizId: id);
        },
      ),

      // Detail routes (outside shell for full screen)
      GoRoute(
        path: '/challenge/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ChallengeDetailScreen(challengeId: id);
        },
      ),
      GoRoute(
        path: '/guide/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return GuideDetailScreen(guideId: id);
        },
      ),
    ],
  );
});

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) => _onItemTapped(index, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          NavigationDestination(
            icon: Icon(Icons.build_outlined),
            selectedIcon: Icon(Icons.build_rounded),
            label: 'Outils',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Stats',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Guides',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/tools')) return 1;
    if (location.startsWith('/progress')) return 2;
    if (location.startsWith('/guides')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
      case 1:
        context.go('/tools');
      case 2:
        context.go('/progress');
      case 3:
        context.go('/guides');
      case 4:
        context.go('/profile');
    }
  }
}
