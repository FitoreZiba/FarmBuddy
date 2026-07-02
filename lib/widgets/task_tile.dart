import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;
  final VoidCallback? onReschedule;

  const TaskTile({super.key, required this.task, required this.onComplete, this.onReschedule});

  IconData get _icon {
    switch (task.type) {
      case TaskType.water:
        return Icons.water_drop_rounded;
      case TaskType.fertilize:
        return Icons.spa_rounded;
      case TaskType.inspect:
        return Icons.search_rounded;
      case TaskType.treat:
        return Icons.healing_rounded;
      case TaskType.other:
        return Icons.task_alt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final overdue = !task.completed && task.dueDate.isBefore(DateTime.now());
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: overdue ? AppColors.danger.withOpacity(0.4) : AppColors.lightSoil),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: task.completed ? null : onComplete,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.completed ? AppColors.leafGreen : Colors.transparent,
                border: Border.all(
                    color: task.completed ? AppColors.leafGreen : AppColors.soilBrown, width: 2),
              ),
              child: task.completed
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Icon(_icon, size: 18, color: AppColors.soilBrown),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.title ?? task.type.name,
              style: TextStyle(
                decoration: task.completed ? TextDecoration.lineThrough : null,
                color: task.completed ? AppColors.ink.withOpacity(0.4) : AppColors.ink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onReschedule != null && !task.completed)
            IconButton(
              icon: const Icon(Icons.event_repeat_rounded, size: 18),
              onPressed: onReschedule,
            ),
        ],
      ),
    );
  }
}
