import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../providers/plot_provider.dart';
import '../../theme/app_theme.dart';

/// Accessible from the Plots tab via the map icon in the AppBar.
/// Shows all the user's plots as gold pins on an OpenStreetMap base.
class MapOverviewScreen extends StatelessWidget {
  const MapOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plots = context.watch<PlotProvider>().plots;

    // Compute a centre that fits all plots, defaulting to 0,0 if empty.
    LatLng centre = const LatLng(41.9981, 21.4254); // Skopje default
    double zoom = 5;
    if (plots.length == 1) {
      centre = LatLng(plots.first.latitude, plots.first.longitude);
      zoom = 14;
    } else if (plots.length > 1) {
      final avgLat = plots.map((p) => p.latitude).reduce((a, b) => a + b) / plots.length;
      final avgLng = plots.map((p) => p.longitude).reduce((a, b) => a + b) / plots.length;
      centre = LatLng(avgLat, avgLng);
      zoom = 8;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('All plots')),
      body: FlutterMap(
        options: MapOptions(initialCenter: centre, initialZoom: zoom),
        children: [
         TileLayer(
            urlTemplate:
              'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
            userAgentPackageName: 'com.example.farmbuddy',
           ),
          MarkerLayer(
            markers: plots
                .map(
                  (p) => Marker(
                    point: LatLng(p.latitude, p.longitude),
                    width: 140,
                    height: 60,
                    child: GestureDetector(
                      onTap: () => context.push('/plots/${p.id}'),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded,
                              color: AppColors.ripeGold, size: 36),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.deepGreen,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p.name,
                              style: const TextStyle(color: Colors.white, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
