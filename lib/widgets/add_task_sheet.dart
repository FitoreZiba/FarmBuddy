import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

Future<void> showAddTaskSheet(
  BuildContext context, {
  String? preselectedCropId,
  String? preselectedPlotId,
}) async {
  final titleCtrl = TextEditingController();
  TaskType type = TaskType.water;
  DateTime dueDate = DateTime.now().add(const Duration(days: 1));
  bool recurring = false;
  final recurrenceCtrl = TextEditingController(text: '7');

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 28,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Add task',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Task title',
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<TaskType>(
                initialValue: type,
                decoration: const InputDecoration(
                  labelText: 'Type',
                ),
                items: TaskType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(t.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => type = v!),
              ),

              const SizedBox(height: 10),

              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Due date'),
                subtitle: Text(
                  DateFormat.yMMMd().format(dueDate),
                ),
                trailing: const Icon(Icons.calendar_today_rounded),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: dueDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(
                      const Duration(days: 365),
                    ),
                  );

                  if (picked != null) {
                    setState(() => dueDate = picked);
                  }
                },
              ),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Repeats'),
                value: recurring,
                onChanged: (v) => setState(() => recurring = v),
              ),

              if (recurring)
                TextField(
                  controller: recurrenceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Every N days',
                  ),
                ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () {
                  context.read<TaskProvider>().addTask(
                        title: titleCtrl.text.trim().isEmpty
                            ? null
                            : titleCtrl.text.trim(),
                        type: type,
                        dueDate: dueDate,
                        cropId: preselectedCropId,
                        plotId: preselectedPlotId,
                        isRecurring: recurring,
                        recurrenceDays: recurring
                            ? int.tryParse(
                                recurrenceCtrl.text.trim(),
                              )
                            : null,
                      );

                  Navigator.of(ctx).pop();
                },
                child: const Text('Save task'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}