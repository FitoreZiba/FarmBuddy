import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/crop_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/camera_capture_overlay.dart';

class AddGrowthLogScreen extends StatefulWidget {
  final String cropId;
  const AddGrowthLogScreen({super.key, required this.cropId});

  @override
  State<AddGrowthLogScreen> createState() => _AddGrowthLogScreenState();
}

class _AddGrowthLogScreenState extends State<AddGrowthLogScreen> {
  final _note = TextEditingController();
  String? _photoPath;
  DateTime _logDate = DateTime.now();

  Future<void> _captureWithCamera() async {
    final path = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const CameraCaptureOverlay()),
    );
    if (path != null) setState(() => _photoPath = path);
  }

  Future<void> _pickFromGallery() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _photoPath = file.path);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _logDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _logDate = picked);
  }

  Future<void> _save() async {
    await context.read<CropProvider>().addGrowthLog(
          cropId: widget.cropId,
          date: _logDate,
          photoPath: _photoPath,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        );
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isToday = DateFormat.yMMMd().format(_logDate) ==
        DateFormat.yMMMd().format(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Add growth log')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            GestureDetector(
              onTap: _captureWithCamera,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.lightSoil,
                  borderRadius: BorderRadius.circular(16),
                  image: _photoPath != null
                      ? DecorationImage(
                          image: FileImage(File(_photoPath!)),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _photoPath == null
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt_rounded,
                                size: 36, color: AppColors.soilBrown),
                            SizedBox(height: 8),
                            Text('Tap to take a photo'),
                          ],
                        ),
                      )
                    : Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: GestureDetector(
                            onTap: () => setState(() => _photoPath = null),
                            child: const CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            // Upload from gallery (past photos)
            OutlinedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library_outlined),
              label: const Text('Upload from gallery'),
            ),

            const SizedBox(height: 18),

            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.lightSoil),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_rounded,
                        size: 18, color: AppColors.soilBrown),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Log date',
                              style: TextStyle(fontSize: 12, color: Colors.black54)),
                          const SizedBox(height: 2),
                          Text(
                            isToday
                                ? 'Today, ${DateFormat.yMMMd().format(_logDate)}'
                                : DateFormat.yMMMd().format(_logDate),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.black38),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 14),

            TextField(
              controller: _note,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g. Leaves look healthy, first flowers appearing...',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton(onPressed: _save, child: const Text('Save log')),
          ],
        ),
      ),
    );
  }
}
