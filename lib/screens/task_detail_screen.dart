import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import 'add_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final priorityColor = Color(task.priority.colorValue);
    final done = task.isCompleted;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Task Detail',
            style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => AddTaskScreen(editTask: task))),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.priorityHigh),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Title card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 4, height: 40,
                    decoration: BoxDecoration(color: priorityColor,
                        borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(task.title,
                      style: TextStyle(fontFamily: 'Outfit', fontSize: 22,
                          fontWeight: FontWeight.w700, color: Colors.white,
                          decoration: done ? TextDecoration.lineThrough : null)),
                ),
              ]),
              if (task.description.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(task.description,
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 14,
                        color: AppColors.textSecondaryDark, height: 1.6)),
              ],
            ]),
          ),
          const SizedBox(height: 16),

          // Meta card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(children: [
              _metaRow('Category', '${task.category.emoji} ${task.category.label}'),
              _divider(),
              _metaRow('Priority', task.priority.label,
                  valueColor: priorityColor),
              _divider(),
              _metaRow('Status', done ? '✅ Completed' : '⏳ Pending',
                  valueColor: done ? AppColors.accent : AppColors.accentOrange),
              _divider(),
              _metaRow('Due Date', task.dueDate != null
                  ? DateFormat('EEEE, MMM d yyyy \'at\' h:mm a').format(task.dueDate!)
                  : 'No due date'),
              _divider(),
              _metaRow('Reminder', task.reminderTime != null
                  ? '⏰ ${DateFormat('MMM d, h:mm a').format(task.reminderTime!)}'
                  : 'No reminder'),
              _divider(),
              _metaRow('Pomodoros', '🍅 ${task.pomodoroCount} / ${task.estimatedPomodoros} sessions'),
              _divider(),
              _metaRow('Created', DateFormat('MMM d, yyyy').format(task.createdAt)),
              if (task.completedAt != null) ...[
                _divider(),
                _metaRow('Completed',
                    DateFormat('MMM d, yyyy \'at\' h:mm a').format(task.completedAt!),
                    valueColor: AppColors.accent),
              ],
            ]),
          ),
          const SizedBox(height: 24),

          if (!done)
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<TaskProvider>().completeTask(task.id);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text('Mark as Complete',
                    style: TextStyle(fontFamily: 'Outfit',
                        fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _confirmDelete(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.priorityHigh),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              icon: const Icon(Icons.delete_outline, color: AppColors.priorityHigh),
              label: const Text('Delete Task',
                  style: TextStyle(fontFamily: 'Outfit', fontSize: 16,
                      fontWeight: FontWeight.w600, color: AppColors.priorityHigh)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _metaRow(String label, String value, {Color? valueColor}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      SizedBox(width: 100,
          child: Text(label, style: TextStyle(fontFamily: 'Outfit', fontSize: 13,
              color: AppColors.textSecondaryDark))),
      Expanded(child: Text(value, style: TextStyle(fontFamily: 'Outfit', fontSize: 13,
          fontWeight: FontWeight.w500,
          color: valueColor ?? Colors.white))),
    ]),
  );

  Widget _divider() => Divider(color: AppColors.darkBorder, height: 1);

  void _confirmDelete(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.darkCard,
      title: const Text('Delete Task',
          style: TextStyle(fontFamily: 'Outfit', color: Colors.white, fontWeight: FontWeight.w700)),
      content: const Text('This cannot be undone.',
          style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondaryDark)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryDark))),
        TextButton(onPressed: () {
          context.read<TaskProvider>().deleteTask(task.id);
          Navigator.pop(context);
          Navigator.pop(context);
        }, child: const Text('Delete', style: TextStyle(color: AppColors.priorityHigh))),
      ],
    ));
  }
}
