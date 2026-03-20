import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/pomodoro_provider.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../models/task.dart';


class PomodoroScreen extends StatelessWidget {
  const PomodoroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pom = context.watch<PomodoroProvider>();

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        title: const Text('Pomodoro Timer',
            style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(children: [
          const SizedBox(height: 16),
          // Session type label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            decoration: BoxDecoration(
              color: pom.sessionColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: pom.sessionColor.withOpacity(0.4)),
            ),
            child: Text(pom.sessionLabel,
                style: TextStyle(fontFamily: 'Outfit', fontSize: 15,
                    fontWeight: FontWeight.w600, color: pom.sessionColor)),
          ),
          const SizedBox(height: 12),
          // Current task
          if (pom.currentTaskTitle.isNotEmpty)
            Text('Working on: ${pom.currentTaskTitle}',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 13,
                    color: AppColors.textSecondaryDark)),
          const SizedBox(height: 32),

          // Timer ring
          SizedBox(
            width: 250, height: 250,
            child: Stack(alignment: Alignment.center, children: [
              SizedBox(width: 250, height: 250,
                child: CircularProgressIndicator(
                  value: pom.progress,
                  strokeWidth: 12,
                  backgroundColor: AppColors.darkBorder,
                  valueColor: AlwaysStoppedAnimation(pom.sessionColor),
                  strokeCap: StrokeCap.round,
                )),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text(pom.formattedTime,
                    style: TextStyle(fontFamily: 'Outfit', fontSize: 58,
                        fontWeight: FontWeight.w700, color: pom.sessionColor,
                        letterSpacing: -2)),
                Text('minutes', style: TextStyle(fontFamily: 'Outfit',
                    fontSize: 13, color: AppColors.textSecondaryDark)),
              ]),
            ]),
          ),
          const SizedBox(height: 28),

          // Session dots
          Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pom.sessionsPerLong, (i) => Container(
              width: 12, height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < (pom.sessionsCompleted % pom.sessionsPerLong)
                    ? AppColors.primary
                    : AppColors.darkBorder,
              ),
            )),
          ),
          const SizedBox(height: 8),
          Text('${pom.sessionsCompleted} session${pom.sessionsCompleted != 1 ? "s" : ""} completed',
              style: TextStyle(fontFamily: 'Outfit', fontSize: 14,
                  color: AppColors.textSecondaryDark)),
          const SizedBox(height: 32),

          // Control buttons
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            // Reset
            _ControlBtn(
              icon: Icons.replay_rounded,
              onTap: pom.reset,
              size: 52,
            ),
            const SizedBox(width: 16),
            // Start/Pause
            GestureDetector(
              onTap: pom.isRunning ? pom.pause : pom.start,
              child: Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  color: pom.sessionColor,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(
                      color: pom.sessionColor.withOpacity(0.4),
                      blurRadius: 20, spreadRadius: 2)],
                ),
                child: Icon(pom.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(width: 16),
            // Skip
            _ControlBtn(
              icon: Icons.skip_next_rounded,
              onTap: pom.skip,
              size: 52,
            ),
          ]),
          const SizedBox(height: 24),

          // Set task button
          OutlinedButton.icon(
            onPressed: () => _showTaskPicker(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            icon: const Text('🎯', style: TextStyle(fontSize: 16)),
            label: Text(pom.currentTaskTitle.isEmpty ? 'Select Task to Focus' : 'Change Task',
                style: const TextStyle(fontFamily: 'Outfit', color: AppColors.primary,
                    fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 32),

          // Tips card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💡 Pomodoro Tips', style: TextStyle(fontFamily: 'Outfit',
                  fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 10),
              ...[
                'Work for 25 mins, then take a 5 min break',
                'After 4 sessions, take a longer 15-20 min break',
                'Turn off notifications during focus sessions',
                'Stay hydrated and stretch during breaks',
              ].map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('• ', style: TextStyle(color: AppColors.primary, fontSize: 14)),
                  Expanded(child: Text(tip, style: TextStyle(fontFamily: 'Outfit',
                      fontSize: 13, color: AppColors.textSecondaryDark, height: 1.4))),
                ]),
              )),
            ]),
          ),
          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  void _showTaskPicker(BuildContext context) {
    final tasks = context.read<TaskProvider>().allTasks
        .where((t) => !t.isCompleted).toList();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Select Task', style: TextStyle(fontFamily: 'Outfit',
              fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 16),
          ...tasks.map((t) => ListTile(
            leading: Text(t.category.emoji, style: const TextStyle(fontSize: 20)),
            title: Text(t.title, style: const TextStyle(
                fontFamily: 'Outfit', color: Colors.white, fontWeight: FontWeight.w500)),
            subtitle: Text(t.priority.label, style: TextStyle(
                fontFamily: 'Outfit', color: Color(t.priority.colorValue), fontSize: 12)),
            onTap: () {
              context.read<PomodoroProvider>().setTask(t.title);
              Navigator.pop(context);
            },
          )),
          if (tasks.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text('No pending tasks', style: TextStyle(
                  fontFamily: 'Outfit', color: AppColors.textSecondaryDark)),
            )),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  const _ControlBtn({required this.icon, required this.onTap, required this.size});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: AppColors.darkElevated,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Icon(icon, color: AppColors.textSecondaryDark, size: 24),
    ),
  );
}
