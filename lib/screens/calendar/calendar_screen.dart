import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/add_task_sheet.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/task_tile.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TaskProvider>();
    final grouped = provider.groupedByDueDate;
    final days = grouped.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAddTaskSheet(context),
        child: const Icon(Icons.add),
      ),
      body: days.isEmpty
          ? const EmptyState(
              icon: Icons.calendar_month_rounded,
              title: 'No tasks scheduled',
              subtitle: 'Tap + to create tasks for watering, fertilizing, and inspecting.',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: days.length,
              itemBuilder: (context, i) {
                final day = days[i];
                final tasks = grouped[day]!;
                final isToday = () {
                  final n = DateTime.now();
                  return day.year == n.year && day.month == n.month && day.day == n.day;
                }();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isToday)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.ripeGold,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Today',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          Text(
                            DateFormat.yMMMEd().format(day),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, color: AppColors.soilBrown),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...tasks.map((t) => TaskTile(
                            task: t,
                            onComplete: () => provider.toggleComplete(t),
                            onReschedule: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: t.dueDate,
                                firstDate:
                                    DateTime.now().subtract(const Duration(days: 1)),
                                lastDate:
                                    DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) provider.reschedule(t, picked);
                            },
                          )),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
