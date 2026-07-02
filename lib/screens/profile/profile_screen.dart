import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _metric = true;
  bool _notificationsEnabled = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _metric = prefs.getBool('units_metric') ?? true;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _loaded = true;
    });
  }

  Future<void> _setMetric(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('units_metric', v);
    setState(() => _metric = v);
  }

  Future<void> _setNotifications(bool v) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', v);
    setState(() => _notificationsEnabled = v);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: AppColors.deepGreen,
            child: Text(
              (auth.user?.email ?? '?').substring(0, 1).toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 8),
          Text(auth.user?.email ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Use metric units'),
                  subtitle: const Text('°C, mm, kg'),
                  value: _metric,
                  onChanged: _setMetric,
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Task reminders'),
                  subtitle: const Text('Notify me about due tasks'),
                  value: _notificationsEnabled,
                  onChanged: _setNotifications,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () => context.read<AuthProvider>().signOut(),
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            label: const Text('Log out', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}
