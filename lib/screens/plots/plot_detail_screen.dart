import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/plot_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/crop_card.dart';
import '../../widgets/empty_state.dart';

class PlotDetailScreen extends StatefulWidget {
  final String plotId;
  const PlotDetailScreen({super.key, required this.plotId});

  @override
  State<PlotDetailScreen> createState() => _PlotDetailScreenState();
}

class _PlotDetailScreenState extends State<PlotDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CropProvider>().loadAllForUserPlots([widget.plotId]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final plot = context.watch<PlotProvider>().byId(widget.plotId);
    final crops = context.watch<CropProvider>().cropsForPlot(widget.plotId);

    if (plot == null) {
      return const Scaffold(body: Center(child: Text('Plot not found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(plot.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.wb_sunny_outlined),
            tooltip: '5-day forecast',
            onPressed: () => context.push('/plots/${plot.id}/forecast'),
          ),
          IconButton(
            icon: const Icon(Icons.edit_rounded),
            onPressed: () => context.push('/plots/${plot.id}/edit'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/plots/${plot.id}/crops/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add crop'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              height: 160,
              child: FlutterMap(
                options: MapOptions(initialCenter: LatLng(plot.latitude, plot.longitude), initialZoom: 15),
                children: [
                  TileLayer(
                          urlTemplate:
                            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                          userAgentPackageName: 'com.example.farmbuddy',
                        ),
                  MarkerLayer(markers: [
                    Marker(
                      point: LatLng(plot.latitude, plot.longitude),
                      width: 36,
                      height: 36,
                      child: const Icon(Icons.location_on_rounded, color: AppColors.ripeGold, size: 36),
                    ),
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            children: [
              Text('Soil: ${plot.soilType ?? 'unset'}', style: const TextStyle(color: Colors.black54)),
              if (plot.areaSqMeters != null)
                Text('${plot.areaSqMeters!.toStringAsFixed(0)} m²', style: const TextStyle(color: Colors.black54)),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Crops', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          if (crops.isEmpty)
            const EmptyState(
              icon: Icons.eco_rounded,
              title: 'No crops planted here yet',
              subtitle: 'Tap "Add crop" to start tracking one.',
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: crops
                  .map((c) => CropCard(crop: c, onTap: () => context.push('/crops/${c.id}')))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
