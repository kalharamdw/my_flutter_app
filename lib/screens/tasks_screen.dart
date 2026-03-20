import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/task_tile.dart';
import 'add_task_screen.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = context.watch<TaskProvider>();

    final filters = [
      (TaskFilter.today, 'Today'),
      (TaskFilter.all, 'All'),
      (TaskFilter.upcoming, 'Upcoming'),
      (TaskFilter.overdue, 'Overdue'),
      (TaskFilter.done, 'Done'),
    ];

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('My Tasks',
                            style: TextStyle(fontFamily: 'Outfit', fontSize: 26,
                                fontWeight: FontWeight.w700, color: Colors.white)),
                        Text('${tasks.filteredTasks.length} task${tasks.filteredTasks.length != 1 ? "s" : ""}',
                            style: TextStyle(fontFamily: 'Outfit', fontSize: 13,
                                color: AppColors.textSecondaryDark)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: tasks.setSearch,
                style: const TextStyle(fontFamily: 'Outfit', color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search tasks…',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondaryDark, size: 20),
                  hintStyle: TextStyle(fontFamily: 'Outfit', color: AppColors.textSecondaryDark),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Filter chips
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final selected = tasks.filter == filters[i].$1;
                  return GestureDetector(
                    onTap: () => tasks.setFilter(filters[i].$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : AppColors.darkElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: selected ? AppColors.primary : AppColors.darkBorder),
                      ),
                      child: Text(filters[i].$2,
                          style: TextStyle(
                              fontFamily: 'Outfit', fontSize: 13, fontWeight: FontWeight.w500,
                              color: selected ? Colors.white : AppColors.textSecondaryDark)),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Task list
            Expanded(
              child: tasks.loading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : tasks.filteredTasks.isEmpty
                      ? Center(
                          child: Column(mainAxisSize: MainAxisSize.min, children: [
                            const Text('✅', style: TextStyle(fontSize: 52)),
                            const SizedBox(height: 12),
                            const Text('No tasks here!',
                                style: TextStyle(fontFamily: 'Outfit', fontSize: 20,
                                    fontWeight: FontWeight.w600, color: Colors.white)),
                            const SizedBox(height: 6),
                            Text('Tap + to add a task',
                                style: TextStyle(fontFamily: 'Outfit', fontSize: 14,
                                    color: AppColors.textSecondaryDark)),
                          ]),
                        )
                      : RefreshIndicator(
                          onRefresh: () => context.read<TaskProvider>().loadTasks(),
                          color: AppColors.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            itemCount: tasks.filteredTasks.length,
                            itemBuilder: (_, i) => TaskTile(task: tasks.filteredTasks[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AddTaskScreen())),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Task',
            style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }
}
