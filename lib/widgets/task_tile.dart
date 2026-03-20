import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../screens/task_detail_screen.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  const TaskTile({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final done = task.isCompleted;
    final priorityColor = Color(task.priority.colorValue);

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.priorityHigh.withOpacity(0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.priorityHigh),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.darkCard,
            title: const Text('Delete Task', style: TextStyle(fontFamily: 'Outfit', color: Colors.white)),
            content: const Text('Are you sure?', style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondaryDark)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryDark))),
              TextButton(onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete', style: TextStyle(color: AppColors.priorityHigh))),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => context.read<TaskProvider>().deleteTask(task.id),
      child: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task))),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            children: [
              // Priority bar
              Container(width: 4, height: 80,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18), bottomLeft: Radius.circular(18)),
                  )),
              // Checkbox
              Checkbox(
                value: done,
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                onChanged: (_) => context.read<TaskProvider>().completeTask(task.id),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 12, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(task.title,
                          style: TextStyle(
                            fontFamily: 'Outfit', fontSize: 15, fontWeight: FontWeight.w600,
                            color: done ? AppColors.textSecondaryDark : Colors.white,
                            decoration: done ? TextDecoration.lineThrough : null,
                          ),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(children: [
                        Text('${task.category.emoji} ${task.category.label}',
                            style: TextStyle(fontFamily: 'Outfit', fontSize: 12,
                                color: AppColors.textSecondaryDark)),
                        const Spacer(),
                        if (task.dueDate != null)
                          Text(DateFormat('h:mm a').format(task.dueDate!),
                              style: TextStyle(fontFamily: 'Outfit', fontSize: 12,
                                  color: task.isOverdue ? AppColors.priorityHigh : AppColors.textSecondaryDark)),
                        if (task.pomodoroCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text('🍅 ${task.pomodoroCount}/${task.estimatedPomodoros}',
                                style: TextStyle(fontFamily: 'Outfit', fontSize: 11,
                                    color: AppColors.textSecondaryDark)),
                          ),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
