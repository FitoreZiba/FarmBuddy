import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_router.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/crop_provider.dart';
import 'providers/plot_provider.dart';
import 'providers/task_provider.dart';
import 'providers/weather_provider.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(const FarmBuddyApp());
}



class FarmBuddyApp extends StatefulWidget {
  const FarmBuddyApp({super.key});

  @override
  State<FarmBuddyApp> createState() => _FarmBuddyAppState();
}


class _FarmBuddyAppState extends State<FarmBuddyApp> {
  late final AuthProvider _authProvider;
  late final dynamic _router;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _router = buildRouter(_authProvider);
  }

  @override
  void dispose() {
    _authProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider(create: (_) => PlotProvider()),
        ChangeNotifierProvider(create: (_) => CropProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
      ],
      child: MaterialApp.router(
        title: 'FarmBuddy',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
