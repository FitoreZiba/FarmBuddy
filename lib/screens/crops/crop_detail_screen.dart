import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/crop.dart';
import '../../providers/crop_provider.dart';
import '../../providers/plot_provider.dart';
import '../../providers/weather_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/add_task_sheet.dart';
import '../../widgets/growth_stage_timeline.dart';

class CropDetailScreen extends StatefulWidget {
  final String cropId;
  const CropDetailScreen({super.key, required this.cropId});

  @override
  State<CropDetailScreen> createState() => _CropDetailScreenState();
}

class _CropDetailScreenState extends State<CropDetailScreen> {
  bool _refreshingGdd = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CropProvider>().loadLogsForCrop(widget.cropId);
      context.read<CropProvider>().loadHarvestsForCrop(widget.cropId);
    });
  }

  Future<void> _refreshGdd(String plotId) async {
    setState(() => _refreshingGdd = true);
    final plot = context.read<PlotProvider>().byId(plotId);
    if (plot != null) {
      final weatherProvider = context.read<WeatherProvider>();
      final snapshots = await weatherProvider.fetchAndCacheForecast(plotId, plot.latitude, plot.longitude);
      await context.read<CropProvider>().recalculateGdd(widget.cropId, snapshots);
    }
    setState(() => _refreshingGdd = false);
  }

  Future<void> _advanceStage(Crop crop) async {
    const order = [
      CropStage.seed,
      CropStage.germination,
      CropStage.vegetative,
      CropStage.flowering,
      CropStage.fruiting,
      CropStage.harvested,
    ];
    final idx = order.indexOf(crop.currentStage);
    if (idx >= order.length - 1) return;
    await context.read<CropProvider>().updateCrop(crop.copyWith(currentStage: order[idx + 1]));
  }

  @override
  Widget build(BuildContext context) {
    final crop = context.watch<CropProvider>().byId(widget.cropId);
    if (crop == null) {
      return const Scaffold(body: Center(child: Text('Crop not found')));
    }
    final logs = context.watch<CropProvider>().logsForCrop(crop.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(crop.cropType),
        actions: [
          IconButton(
            icon: _refreshingGdd
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh weather & GDD',
            onPressed: _refreshingGdd ? null : () => _refreshGdd(crop.plotId),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GrowthStageTimeline(
                currentStage: crop.currentStage,
                progressPercent: crop.progressPercent,
                estimateLabel: crop.estimatedHarvestDate != null
                    ? 'Est. ${DateFormat.yMMMd().format(crop.estimatedHarvestDate!)}'
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (crop.currentStage != CropStage.harvested)
            OutlinedButton.icon(
              onPressed: () => _advanceStage(crop),
              icon: const Icon(Icons.arrow_forward_rounded),
              label: const Text('Advance to next stage'),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/crops/${crop.id}/log/new'),
                  icon: const Icon(Icons.add_a_photo_rounded),
                  label: const Text('Add growth log'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/crops/${crop.id}/gallery'),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Gallery'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => context.push('/crops/${crop.id}/harvest'),
            icon: const Icon(Icons.agriculture_rounded),
            label: const Text('Harvest log'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () => showAddTaskSheet(context, preselectedCropId: crop.id),
            icon: const Icon(Icons.add_task_rounded),
            label: const Text('Add task for this crop'),
          ),
          const SizedBox(height: 24),
          Text('Recent activity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (logs.isEmpty)
            Text('No growth logs yet.', style: TextStyle(color: AppColors.ink.withOpacity(0.6)))
          else
            ...logs.take(5).map((l) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.eco_rounded, color: AppColors.leafGreen),
                  title: Text(DateFormat.yMMMd().format(l.date)),
                  subtitle: Text(l.note ?? '${l.stageAtLog.name} stage'),
                )),
        ],
      ),
    );
  }
}
