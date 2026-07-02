import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../models/crop.dart';
import '../../providers/crop_provider.dart';

class AddEditCropScreen extends StatefulWidget {
  final String plotId;
  const AddEditCropScreen({super.key, required this.plotId});

  @override
  State<AddEditCropScreen> createState() => _AddEditCropScreenState();
}

class _AddEditCropScreenState extends State<AddEditCropScreen> {
  final _formKey = GlobalKey<FormState>();
  final _variety = TextEditingController();
  String _cropType = kCropDefaults.keys.first;
  DateTime _plantingDate = DateTime.now();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _plantingDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => _plantingDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final crop = await context.read<CropProvider>().addCrop(
          plotId: widget.plotId,
          cropType: _cropType,
          variety: _variety.text.trim().isEmpty ? null : _variety.text.trim(),
          plantingDate: _plantingDate,
        );
    if (mounted) context.pushReplacement('/crops/${crop.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add crop')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _cropType,
                  decoration: const InputDecoration(labelText: 'Crop type'),
                  items: kCropDefaults.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                  onChanged: (v) => setState(() => _cropType = v!),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _variety,
                  decoration: const InputDecoration(labelText: 'Variety — optional'),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Planting date'),
                  subtitle: Text('${_plantingDate.year}-${_plantingDate.month.toString().padLeft(2, '0')}-${_plantingDate.day.toString().padLeft(2, '0')}'),
                  trailing: const Icon(Icons.calendar_today_rounded),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 22),
                ElevatedButton(onPressed: _save, child: const Text('Save crop')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
