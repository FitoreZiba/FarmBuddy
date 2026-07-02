import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/crop_provider.dart';
import '../../widgets/empty_state.dart';

class HarvestLogScreen extends StatefulWidget {
  final String cropId;
  const HarvestLogScreen({super.key, required this.cropId});

  @override
  State<HarvestLogScreen> createState() => _HarvestLogScreenState();
}

class _HarvestLogScreenState extends State<HarvestLogScreen> {
  final _yield = TextEditingController();
  final _notes = TextEditingController();

  Future<void> _record() async {
    final yieldKg = double.tryParse(_yield.text.trim());
    if (yieldKg == null) return;
    await context.read<CropProvider>().addHarvestRecord(
          cropId: widget.cropId,
          date: DateTime.now(),
          yieldKg: yieldKg,
          qualityNotes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        );
    _yield.clear();
    _notes.clear();
    if (mounted) FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final harvests = context.watch<CropProvider>().harvestsForCrop(widget.cropId);
    return Scaffold(
      appBar: AppBar(title: const Text('Harvest log')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _yield,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Yield (kg)'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(labelText: 'Quality notes — optional'),
          ),
          const SizedBox(height: 14),
          ElevatedButton(onPressed: _record, child: const Text('Record harvest')),
          const SizedBox(height: 24),
          const Text('History', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          if (harvests.isEmpty)
            const EmptyState(icon: Icons.agriculture_rounded, title: 'No harvests recorded', subtitle: 'Log your first harvest above.')
          else
            ...harvests.map((h) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.agriculture_rounded),
                  title: Text('${h.yieldKg} kg — ${DateFormat.yMMMd().format(h.date)}'),
                  subtitle: h.qualityNotes != null ? Text(h.qualityNotes!) : null,
                )),
        ],
      ),
    );
  }
}
