import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/crop_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';

class PhotoGalleryScreen extends StatelessWidget {
  final String cropId;
  const PhotoGalleryScreen({super.key, required this.cropId});

  @override
  Widget build(BuildContext context) {
    final logs = context.watch<CropProvider>().logsForCrop(cropId);
    return Scaffold(
      appBar: AppBar(title: const Text('Growth timeline')),
      body: logs.isEmpty
          ? const EmptyState(
              icon: Icons.photo_library_outlined,
              title: 'No photos yet',
              subtitle: 'Growth logs with photos will appear here in order.',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.85,
              ),
              itemCount: logs.length,
              itemBuilder: (context, i) {
                final log = logs[i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    color: AppColors.lightSoil,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: log.photoPath != null
                              ? Image.file(File(log.photoPath!), fit: BoxFit.cover)
                              : const Center(child: Icon(Icons.eco_rounded, color: AppColors.soilBrown)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Text(
                            DateFormat.MMMd().format(log.date),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
