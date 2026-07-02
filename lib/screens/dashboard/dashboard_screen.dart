import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/plot_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/weather_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/task_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _bootstrapped = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_bootstrapped) return;
    _bootstrapped = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final auth = context.read<AuthProvider>();
    final uid = auth.user?.uid;
    if (uid == null) return;
    final plotProvider = context.read<PlotProvider>();
    await plotProvider.loadPlots(uid);
    final plotIds = plotProvider.plots.map((p) => p.id).toList();
    final cropProvider = context.read<CropProvider>();
    await cropProvider.loadAllForUserPlots(plotIds);
    final cropIds = cropProvider.crops.map((c) => c.id).toList();
    await context.read<TaskProvider>().loadTasks(plotIds, cropIds);

    if (plotProvider.plots.isNotEmpty) {
      final firstPlot = plotProvider.plots.first;
      await context.read<WeatherProvider>().fetchCurrent(firstPlot.latitude, firstPlot.longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final weather = context.watch<WeatherProvider>();
    final plots = context.watch<PlotProvider>().plots;
    final pending = taskProvider.pendingToday;

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: RefreshIndicator(
        onRefresh: _bootstrap,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _WeatherSnapshotCard(weather: weather, hasPlots: plots.isNotEmpty),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Today\'s tasks', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                TextButton(onPressed: () => context.go('/calendar'), child: const Text('See all')),
              ],
            ),
            if (pending.isEmpty)
              const EmptyState(
                icon: Icons.check_circle_outline_rounded,
                title: 'Nothing pending today',
                subtitle: 'New tasks you create will show up here.',
              )
            else
              ...pending.map((t) => TaskTile(task: t, onComplete: () => taskProvider.markComplete(t))),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: plots.isEmpty
                  ? null
                  : () => context.push('/plots/${plots.first.id}'),
              icon: const Icon(Icons.add_a_photo_rounded),
              label: const Text('Quick add growth log'),
            ),
            if (plots.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('Add a plot first to start logging growth.',
                    style: TextStyle(color: AppColors.ink.withOpacity(0.6), fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}

class _WeatherSnapshotCard extends StatelessWidget {
  final WeatherProvider weather;
  final bool hasPlots;
  const _WeatherSnapshotCard({required this.weather, required this.hasPlots});

  @override
  Widget build(BuildContext context) {
    final data = weather.currentConditions;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.deepGreen,
        borderRadius: BorderRadius.circular(18),
      ),
      child: !hasPlots
          ? const Text('Add a plot to see local weather here.', style: TextStyle(color: Colors.white70))
          : weather.isLoading
              ? const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(color: AppColors.ripeGold)))
              : data == null
                  ? Text(weather.errorMessage ?? 'Weather unavailable — check your OpenWeatherMap API key.',
                      style: const TextStyle(color: Colors.white70))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${(data['main']['temp'] as num).toStringAsFixed(0)}°C',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                            Text(
                              (data['weather'] as List).isNotEmpty ? data['weather'][0]['description'] : '',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const Icon(Icons.wb_sunny_rounded, color: AppColors.ripeGold, size: 40),
                      ],
                    ),
    );
  }
}
