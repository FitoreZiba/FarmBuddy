import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/crop_provider.dart';
import '../../providers/plot_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/plot_card.dart';

class PlotListScreen extends StatefulWidget {
  const PlotListScreen({super.key});

  @override
  State<PlotListScreen> createState() => _PlotListScreenState();
}

class _PlotListScreenState extends State<PlotListScreen> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid != null) context.read<PlotProvider>().loadPlots(uid);
  }

  @override
  Widget build(BuildContext context) {
    final plotProvider = context.watch<PlotProvider>();
    final cropProvider = context.watch<CropProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your plots'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_rounded),
            tooltip: 'View all on map',
            onPressed: () => context.push('/plots/map'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/plots/new'),
        child: const Icon(Icons.add),
      ),
      body: plotProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : plotProvider.plots.isEmpty
              ? EmptyState(
                  icon: Icons.grass_rounded,
                  title: 'No plots yet',
                  subtitle: 'Add your first plot to start tracking crops.',
                  action: ElevatedButton(
                    onPressed: () => context.push('/plots/new'),
                    child: const Text('Add a plot'),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: plotProvider.plots.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final plot = plotProvider.plots[i];
                    final cropCount = cropProvider.cropsForPlot(plot.id).length;
                    return PlotCard(
                      plot: plot,
                      cropCount: cropCount,
                      onTap: () => context.push('/plots/${plot.id}'),
                    );
                  },
                ),
    );
  }
}
