import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/weather_snapshot.dart';
import '../../providers/plot_provider.dart';
import '../../providers/weather_provider.dart';
import '../../theme/app_theme.dart';

class WeatherForecastScreen extends StatefulWidget {
  final String plotId;
  const WeatherForecastScreen({super.key, required this.plotId});

  @override
  State<WeatherForecastScreen> createState() => _WeatherForecastScreenState();
}

class _WeatherForecastScreenState extends State<WeatherForecastScreen> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final plot = context.read<PlotProvider>().byId(widget.plotId);
    if (plot != null) {
      final wp = context.read<WeatherProvider>();
      await wp.loadCachedSnapshots(widget.plotId);
      // Only refresh from API if no cached data for today.
      final snaps = wp.snapshotsForPlot(widget.plotId);
      final today = DateTime.now();
      final hasTodayCache = snaps.any((s) =>
          s.date.year == today.year &&
          s.date.month == today.month &&
          s.date.day == today.day);
      if (!hasTodayCache) {
        await wp.fetchAndCacheForecast(widget.plotId, plot.latitude, plot.longitude);
      }
    }
    setState(() => _loading = false);
  }

  IconData _icon(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny_rounded;
      case 'clouds':
        return Icons.cloud_rounded;
      case 'rain':
      case 'drizzle':
        return Icons.water_drop_rounded;
      case 'snow':
        return Icons.ac_unit_rounded;
      case 'thunderstorm':
        return Icons.flash_on_rounded;
      default:
        return Icons.wb_cloudy_rounded;
    }
  }

  Color _iconColor(String? condition) {
    switch (condition?.toLowerCase()) {
      case 'clear':
        return AppColors.ripeGold;
      case 'rain':
      case 'drizzle':
      case 'thunderstorm':
        return Colors.blueAccent;
      case 'snow':
        return Colors.lightBlue;
      default:
        return AppColors.soilBrown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final plotName = context.watch<PlotProvider>().byId(widget.plotId)?.name ?? 'Plot';
    final snaps = context.watch<WeatherProvider>().snapshotsForPlot(widget.plotId);
    final fiveDays = snaps.take(5).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Forecast — $plotName')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : fiveDays.isEmpty
              ? const Center(child: Text('No forecast data. Pull to refresh.'))
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: fiveDays.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final snap = fiveDays[i];
                      return _ForecastCard(snap: snap, icon: _icon(snap.conditionCode), iconColor: _iconColor(snap.conditionCode));
                    },
                  ),
                ),
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final WeatherSnapshot snap;
  final IconData icon;
  final Color iconColor;
  const _ForecastCard({required this.snap, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    final isToday = () {
      final t = DateTime.now();
      return snap.date.year == t.year && snap.date.month == t.month && snap.date.day == t.day;
    }();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: isToday ? AppColors.deepGreen : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightSoil),
      ),
      child: Row(
        children: [
          Icon(icon, color: isToday ? AppColors.ripeGold : iconColor, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isToday ? 'Today' : DateFormat.EEEE().format(snap.date),
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: isToday ? Colors.white : AppColors.ink,
                  ),
                ),
                Text(
                  DateFormat.MMMd().format(snap.date),
                  style: TextStyle(fontSize: 12, color: isToday ? Colors.white70 : Colors.black54),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${snap.tempHighC.toStringAsFixed(0)}° / ${snap.tempLowC.toStringAsFixed(0)}°C',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isToday ? Colors.white : AppColors.ink,
                ),
              ),
              if (snap.precipitationMm > 0)
                Text(
                  '${snap.precipitationMm.toStringAsFixed(1)} mm',
                  style: TextStyle(fontSize: 12, color: isToday ? Colors.white70 : Colors.blueAccent),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
