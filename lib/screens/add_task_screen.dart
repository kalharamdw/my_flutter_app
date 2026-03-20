import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../services/notification_service.dart';
import '../utils/app_theme.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? editTask;
  const AddTaskScreen({super.key, this.editTask});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Priority _priority = Priority.medium;
  Category _category = Category.personal;
  DateTime? _dueDate;
  DateTime? _reminderTime;
  int _pomodoros = 1;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final t = widget.editTask;
    if (t != null) {
      _titleCtrl.text = t.title;
      _descCtrl.text = t.description;
      _priority = t.priority;
      _category = t.category;
      _dueDate = t.dueDate;
      _reminderTime = t.reminderTime;
      _pomodoros = t.estimatedPomodoros;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
              primary: AppColors.primary, surface: AppColors.darkCard),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
              primary: AppColors.primary, surface: AppColors.darkCard),
        ),
        child: child!,
      ),
    );
    if (time == null) return;
    setState(() => _dueDate = DateTime(
        date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _pickReminder() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
              primary: AppColors.primary, surface: AppColors.darkCard),
        ),
        child: child!,
      ),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
              primary: AppColors.primary, surface: AppColors.darkCard),
        ),
        child: child!,
      ),
    );
    if (time == null) return;
    setState(() => _reminderTime = DateTime(
        date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final task = Task(
      id: widget.editTask?.id,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      priority: _priority,
      category: _category,
      dueDate: _dueDate,
      reminderTime: _reminderTime,
      estimatedPomodoros: _pomodoros,
    );
    final provider = context.read<TaskProvider>();
    if (widget.editTask != null) {
      await provider.updateTask(task);
    } else {
      await provider.addTask(task);
    }
    if (_reminderTime != null &&
        _reminderTime!.isAfter(DateTime.now())) {
      await NotificationService.scheduleReminder(
        id: task.id.hashCode,
        title: task.title,
        body: task.description,
        scheduledTime: _reminderTime!,
      );
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        title: Text(
          widget.editTask == null ? 'New Task' : 'Edit Task',
          style: const TextStyle(
              fontFamily: 'Outfit', fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.darkBg,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2))
                : const Text(
                    'Save',
                    style: TextStyle(
                      fontFamily: 'Outfit',
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title
            TextFormField(
              controller: _titleCtrl,
              autofocus: true,
              style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Task title *',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintStyle: TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 18,
                    color: AppColors.textSecondaryDark),
              ),
              validator: (v) =>
                  v!.trim().isEmpty ? 'Title is required' : null,
            ),
            Divider(color: AppColors.darkBorder),
            const SizedBox(height: 8),

            // Description
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              style: const TextStyle(
                  fontFamily: 'Outfit', color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Description (optional)',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                hintStyle: TextStyle(
                    fontFamily: 'Outfit',
                    color: AppColors.textSecondaryDark),
              ),
            ),
            Divider(color: AppColors.darkBorder),
            const SizedBox(height: 20),

            // Priority
            _label('Priority'),
            const SizedBox(height: 10),
            Row(
              children: Priority.values.map((p) {
                final sel = _priority == p;
                // Use Color() constructor — no conflict now
                final c = Color(p.colorValue);
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding:
                          const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: sel
                            ? c.withOpacity(0.2)
                            : AppColors.darkElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: sel ? c : AppColors.darkBorder),
                      ),
                      child: Column(children: [
                        Text(p.emoji,
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          p.label,
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: sel
                                ? c
                                : AppColors.textSecondaryDark,
                          ),
                        ),
                      ]),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Category
            _label('Category'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Category.values.map((c) {
                final sel = _category == c;
                return GestureDetector(
                  onTap: () => setState(() => _category = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel
                          ? AppColors.primary.withOpacity(0.2)
                          : AppColors.darkElevated,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: sel
                              ? AppColors.primary
                              : AppColors.darkBorder),
                    ),
                    child: Text(
                      '${c.emoji} ${c.label}',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: sel
                            ? AppColors.primary
                            : AppColors.textSecondaryDark,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Due Date
            _label('Due Date'),
            const SizedBox(height: 10),
            _PickerRow(
              icon: Icons.calendar_today_outlined,
              label: _dueDate != null
                  ? DateFormat('MMM d, h:mm a').format(_dueDate!)
                  : 'Set due date',
              active: _dueDate != null,
              activeColor: AppColors.primary,
              onTap: _pickDueDate,
              onClear: _dueDate != null
                  ? () => setState(() => _dueDate = null)
                  : null,
            ),
            const SizedBox(height: 12),

            // Reminder
            _label('Reminder'),
            const SizedBox(height: 10),
            _PickerRow(
              icon: Icons.notifications_outlined,
              label: _reminderTime != null
                  ? '⏰ ${DateFormat('MMM d, h:mm a').format(_reminderTime!)}'
                  : 'Set reminder',
              active: _reminderTime != null,
              activeColor: AppColors.accentOrange,
              onTap: _pickReminder,
              onClear: _reminderTime != null
                  ? () => setState(() => _reminderTime = null)
                  : null,
            ),
            const SizedBox(height: 20),

            // Pomodoros
            _label('Estimated Pomodoros 🍅'),
            const SizedBox(height: 10),
            Row(children: [
              Text(
                '$_pomodoros session${_pomodoros > 1 ? "s" : ""}',
                style: const TextStyle(
                    fontFamily: 'Outfit',
                    fontSize: 14,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: Slider(
                  value: _pomodoros.toDouble(),
                  min: 1,
                  max: 8,
                  divisions: 7,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.darkBorder,
                  onChanged: (v) =>
                      setState(() => _pomodoros = v.toInt()),
                ),
              ),
            ]),
            const SizedBox(height: 32),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)
                    : Text(
                        widget.editTask == null
                            ? 'Save Task ✓'
                            : 'Update Task ✓',
                        style: const TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white),
      );
}

class _PickerRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _PickerRow({
    required this.icon,
    required this.label,
    required this.active,
    required this.activeColor,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : AppColors.textSecondaryDark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.darkElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                  fontFamily: 'Outfit', fontSize: 14, color: color),
            ),
          ),
          if (onClear != null)
            GestureDetector(
              onTap: onClear,
              child: Icon(Icons.close,
                  color: AppColors.textSecondaryDark, size: 18),
            ),
        ]),
      ),
    );
  }
}
