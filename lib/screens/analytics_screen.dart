import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>().allTasks;
    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final pending = tasks.where((t) => !t.isCompleted && !t.isDeleted).length;
    final overdue = tasks.where((t) => t.isOverdue).length;
    final completionRate = total == 0 ? 0.0 : completed / total;
    final score = _productivityScore(tasks);

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text('Analytics',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 26,
                    fontWeight: FontWeight.w700, color: Colors.white)),
            Text('Your productivity insights',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 13,
                    color: AppColors.textSecondaryDark)),
            const SizedBox(height: 20),

            // Productivity score card
            _Card(child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Productivity Score', style: TextStyle(fontFamily: 'Outfit',
                    fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 4),
                Text(_scoreLabel(score), style: TextStyle(fontFamily: 'Outfit',
                    fontSize: 13, color: AppColors.accent)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score / 100,
                    minHeight: 8,
                    backgroundColor: AppColors.darkBorder,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ])),
              const SizedBox(width: 16),
              Text(score.toString(),
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 52,
                      fontWeight: FontWeight.w700, color: AppColors.primary)),
            ])),
            const SizedBox(height: 16),

            // Stats row
            Row(children: [
              _StatCard(value: total.toString(), label: 'Total', color: AppColors.primary),
              const SizedBox(width: 10),
              _StatCard(value: completed.toString(), label: 'Done', color: AppColors.accent),
              const SizedBox(width: 10),
              _StatCard(value: pending.toString(), label: 'Pending', color: AppColors.accentOrange),
              const SizedBox(width: 10),
              _StatCard(value: overdue.toString(), label: 'Overdue', color: AppColors.priorityHigh),
            ]),
            const SizedBox(height: 16),

            // Completion rate
            _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Completion Rate', style: TextStyle(fontFamily: 'Outfit',
                    fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                Text('${(completionRate * 100).toInt()}%',
                    style: const TextStyle(fontFamily: 'Outfit', fontSize: 18,
                        fontWeight: FontWeight.w700, color: AppColors.primary)),
              ]),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: completionRate,
                  minHeight: 10,
                  backgroundColor: AppColors.darkBorder,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            ])),
            const SizedBox(height: 16),

            // Weekly bar chart
            _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Tasks This Week', style: TextStyle(fontFamily: 'Outfit',
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
              const SizedBox(height: 16),
              SizedBox(height: 180, child: _WeeklyBarChart(tasks: tasks)),
            ])),
            const SizedBox(height: 16),

            // Category + Priority row
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(child: _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('By Category', style: TextStyle(fontFamily: 'Outfit',
                    fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 12),
                SizedBox(height: 160, child: _CategoryPieChart(tasks: tasks)),
              ]))),
              const SizedBox(width: 12),
              Expanded(child: _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('By Priority', style: TextStyle(fontFamily: 'Outfit',
                    fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                const SizedBox(height: 12),
                ..._priorityBreakdown(tasks),
              ]))),
            ]),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  int _productivityScore(List<Task> tasks) {
    if (tasks.isEmpty) return 0;
    final total = tasks.length;
    final completed = tasks.where((t) => t.isCompleted).length;
    final overdue = tasks.where((t) => t.isOverdue).length;
    final rate = completed / total;
    final penalty = (overdue * 5).clamp(0, 30);
    return ((rate * 100) - penalty).clamp(0, 100).toInt();
  }

  String _scoreLabel(int score) {
    if (score >= 80) return '🔥 Excellent!';
    if (score >= 60) return '💪 Good Job!';
    if (score >= 40) return '📈 Keep Going!';
    return '🌱 Just Starting';
  }

  List<Widget> _priorityBreakdown(List<Task> tasks) {
    return Priority.values.map((p) {
      final count = tasks.where((t) => t.priority == p).length;
      final pct = tasks.isEmpty ? 0.0 : count / tasks.length;
      final color = Color(p.colorValue);
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('${p.emoji} ${p.label}', style: TextStyle(fontFamily: 'Outfit',
                fontSize: 12, color: AppColors.textSecondaryDark)),
            Text(count.toString(), style: TextStyle(fontFamily: 'Outfit',
                fontSize: 13, fontWeight: FontWeight.w600, color: color)),
          ]),
          const SizedBox(height: 4),
          ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: pct, minHeight: 6,
                backgroundColor: AppColors.darkBorder,
                valueColor: AlwaysStoppedAnimation(color))),
        ]),
      );
    }).toList();
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List<Task> tasks;
  const _WeeklyBarChart({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final bars = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final start = DateTime(day.year, day.month, day.day);
      final end = start.add(const Duration(days: 1));
      final count = tasks.where((t) =>
          t.isCompleted &&
          t.completedAt != null &&
          t.completedAt!.isAfter(start) &&
          t.completedAt!.isBefore(end)).length;
      return BarChartGroupData(x: i, barRods: [
        BarChartRodData(
          toY: count.toDouble(),
          color: AppColors.primary,
          width: 20,
          borderRadius: BorderRadius.circular(6),
          backDrawRodData: BackgroundBarChartRodData(
            show: true, toY: 10,
            color: AppColors.darkBorder,
          ),
        ),
      ]);
    });

    final labels = List.generate(7, (i) =>
        DateFormat('E').format(now.subtract(Duration(days: 6 - i))));

    return BarChart(
      BarChartData(
        barGroups: bars,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.darkBorder, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) => Text(labels[v.toInt()],
                style: TextStyle(fontFamily: 'Outfit', fontSize: 11,
                    color: AppColors.textSecondaryDark)),
          )),
          leftTitles: AxisTitles(sideTitles: SideTitles(
            showTitles: true, reservedSize: 24,
            getTitlesWidget: (v, _) => Text(v.toInt().toString(),
                style: TextStyle(fontFamily: 'Outfit', fontSize: 10,
                    color: AppColors.textSecondaryDark)),
          )),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barTouchData: BarTouchData(enabled: false),
      ),
      swapAnimationDuration: const Duration(milliseconds: 600),
    );
  }
}

class _CategoryPieChart extends StatelessWidget {
  final List<Task> tasks;
  const _CategoryPieChart({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final sections = Category.values
        .map((c) {
          final count = tasks.where((t) => t.category == c).length;
          return MapEntry(c, count);
        })
        .where((e) => e.value > 0)
        .toList();

    if (sections.isEmpty) {
      return Center(child: Text('No data yet',
          style: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondaryDark)));
    }

    return PieChart(
      PieChartData(
        sections: sections.asMap().entries.map((e) => PieChartSectionData(
          value: e.value.value.toDouble(),
          color: AppColors.chartColors[e.key % AppColors.chartColors.length],
          radius: 50,
          title: e.value.key.emoji,
          titleStyle: const TextStyle(fontSize: 14),
        )).toList(),
        centerSpaceRadius: 30,
        sectionsSpace: 2,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.darkBorder),
    ),
    child: child,
  );
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(value, style: TextStyle(fontFamily: 'Outfit', fontSize: 26,
            fontWeight: FontWeight.w700, color: color)),
        Text(label, style: TextStyle(fontFamily: 'Outfit', fontSize: 11,
            color: AppColors.textSecondaryDark)),
      ]),
    ),
  );
}
