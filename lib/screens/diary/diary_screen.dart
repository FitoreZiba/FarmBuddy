import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/crop_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  String? _filterCropId;

  @override
  Widget build(BuildContext context) {
    final cropProvider = context.watch<CropProvider>();
    final crops = cropProvider.crops;

    // Combine all logs across crops into one feed.
    final entries = <MapEntry<String, dynamic>>[]; // cropId -> log
    for (final crop in crops) {
      if (_filterCropId != null && _filterCropId != crop.id) continue;
      for (final log in cropProvider.logsForCrop(crop.id)) {
        entries.add(MapEntry(crop.id, log));
      }
    }
    entries.sort((a, b) => b.value.date.compareTo(a.value.date));

    return Scaffold(
      appBar: AppBar(title: const Text('Diary')),
      body: Column(
        children: [
          if (crops.isNotEmpty)
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _FilterChip(label: 'All', selected: _filterCropId == null, onTap: () => setState(() => _filterCropId = null)),
                  ...crops.map((c) => _FilterChip(
                        label: c.cropType,
                        selected: _filterCropId == c.id,
                        onTap: () => setState(() => _filterCropId = c.id),
                      )),
                ],
              ),
            ),
          Expanded(
            child: entries.isEmpty
                ? const EmptyState(
                    icon: Icons.photo_library_outlined,
                    title: 'No growth photos yet',
                    subtitle: 'Photos logged from any crop will show up here.',
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: entries.length,
                    itemBuilder: (context, i) {
                      final cropId = entries[i].key;
                      final log = entries[i].value;
                      return GestureDetector(
                        onTap: () => context.push('/crops/$cropId'),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: log.photoPath != null
                              ? Image.file(File(log.photoPath as String), fit: BoxFit.cover)
                              : Container(
                                  color: AppColors.lightSoil,
                                  child: const Icon(Icons.eco_rounded, color: AppColors.soilBrown),
                                ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.deepGreen,
        labelStyle: TextStyle(color: selected ? Colors.white : AppColors.ink),
      ),
    );
  }
}
