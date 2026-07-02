import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// Displayed while go_router waits for the first Firebase auth event.
/// AuthProvider starts in AuthStatus.unknown — the router returns null
/// (no redirect) until that resolves, so the user sees this briefly.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.deepGreen,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco_rounded, color: AppColors.ripeGold, size: 64),
            SizedBox(height: 16),
            Text(
              'FarmBuddy',
              style: TextStyle(
                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(color: AppColors.ripeGold),
          ],
        ),
      ),
    );
  }
}
