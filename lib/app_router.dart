import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/plot_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/calendar/calendar_screen.dart';
import 'screens/crops/add_edit_crop_screen.dart';
import 'screens/crops/add_growth_log_screen.dart';
import 'screens/crops/crop_detail_screen.dart';
import 'screens/crops/harvest_log_screen.dart';
import 'screens/crops/photo_gallery_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/diary/diary_screen.dart';
import 'screens/plots/add_edit_plot_screen.dart';
import 'screens/plots/map_overview_screen.dart';
import 'screens/plots/weather_forecast_screen.dart';
import 'screens/plots/plot_detail_screen.dart';
import 'screens/plots/plot_list_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/shell/main_shell.dart';

GoRouter buildRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: authProvider,
    redirect: (context, state) {
  final status = authProvider.status;
  final loc = state.matchedLocation;

  print(
    "ROUTER => status=$status location=$loc",
  );

  if (status == AuthStatus.unknown) {
    return loc == '/splash' ? null : '/splash';
  }

  if (status == AuthStatus.unauthenticated) {
    if (loc == '/login' || loc == '/register') return null; 
    return '/login';
  }

  if (status == AuthStatus.authenticated) {
    if (
      loc == '/login' ||
      loc == '/register' ||
      loc == '/splash'
    ) {
      return '/dashboard';
    }
  }

  return null;
},
    routes: [
      // Auth / splash stack
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

      // Full-screen routes pushed on top of the shell (no bottom nav)
      GoRoute(path: '/plots/new', builder: (_, __) => const AddEditPlotScreen()),
      GoRoute(path: '/plots/map', builder: (_, __) => const MapOverviewScreen()),
      GoRoute(
        path: '/plots/:plotId/forecast',
        builder: (_, state) => WeatherForecastScreen(plotId: state.pathParameters['plotId']!),
      ),
      GoRoute(
        path: '/plots/:plotId',
        builder: (_, state) => PlotDetailScreen(plotId: state.pathParameters['plotId']!),
      ),
      GoRoute(
        path: '/plots/:plotId/edit',
        builder: (context, state) {
          final plotId = state.pathParameters['plotId']!;
          final plot = context.read<PlotProvider>().byId(plotId);
          return AddEditPlotScreen(existing: plot);
        },
      ),
      GoRoute(
        path: '/plots/:plotId/crops/new',
        builder: (_, state) => AddEditCropScreen(plotId: state.pathParameters['plotId']!),
      ),
      GoRoute(
        path: '/crops/:cropId',
        builder: (_, state) => CropDetailScreen(cropId: state.pathParameters['cropId']!),
      ),
      GoRoute(
        path: '/crops/:cropId/log/new',
        builder: (_, state) => AddGrowthLogScreen(cropId: state.pathParameters['cropId']!),
      ),
      GoRoute(
        path: '/crops/:cropId/gallery',
        builder: (_, state) => PhotoGalleryScreen(cropId: state.pathParameters['cropId']!),
      ),
      GoRoute(
        path: '/crops/:cropId/harvest',
        builder: (_, state) => HarvestLogScreen(cropId: state.pathParameters['cropId']!),
      ),

      // Bottom-nav shell (5 tabs, state preserved per tab via indexedStack)
      StatefulShellRoute.indexedStack(
        builder: (_, __, shell) => MainShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/plots', builder: (_, __) => const PlotListScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/calendar', builder: (_, __) => const CalendarScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/diary', builder: (_, __) => const DiaryScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
          ]),
        ],
      ),
    ],
  );
}
