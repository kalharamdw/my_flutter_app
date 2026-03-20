import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/task_tile.dart';
import '../widgets/stat_card.dart';
import 'add_task_screen.dart';
import 'pomodoro_screen.dart';
import 'ai_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tasks = context.watch<TaskProvider>();
    final done = tasks.completedToday;
    final total = tasks.todayTotal;
    final pct = total == 0 ? 0.0 : done / total;

    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Stack(
        children: [
          Positioned(top: -100, right: -80,
            child: Container(width: 280, height: 280,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.08)))),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => context.read<TaskProvider>().loadTasks(),
              color: AppColors.primary,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${_greeting()}, ${auth.displayName.isNotEmpty ? auth.displayName : "Kalhara"}! 👋',
                                        style: const TextStyle(fontFamily: 'Outfit',
                                            fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white)),
                                    Text(DateFormat('EEEE, MMMM d').format(DateTime.now()),
                                        style: TextStyle(fontFamily: 'Outfit', fontSize: 13,
                                            color: AppColors.textSecondaryDark)),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _showProfileMenu(context, auth),
                                child: CircleAvatar(
                                  radius: 22, backgroundColor: AppColors.darkElevated,
                                  child: Text(
                                      auth.displayName.isNotEmpty
                                          ? auth.displayName[0].toUpperCase()
                                          : "?",
                                      style: const TextStyle(fontFamily: 'Outfit',
                                          fontWeight: FontWeight.w700, color: AppColors.primary, fontSize: 18)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Overdue alert
                          if (tasks.overdueTasks.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.priorityHigh.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: AppColors.priorityHigh.withOpacity(0.5)),
                              ),
                              child: Row(children: [
                                const Text('⚠️', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 10),
                                Expanded(child: Text(
                                    '${tasks.overdueTasks.length} overdue task${tasks.overdueTasks.length > 1 ? "s" : ""}',
                                    style: const TextStyle(fontFamily: 'Outfit',
                                        color: AppColors.priorityHigh, fontWeight: FontWeight.w600))),
                              ]),
                            ),

                          // Progress card
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.darkSurface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.darkBorder),
                            ),
                            child: Row(
                              children: [
                                // Ring
                                SizedBox(width: 90, height: 90,
                                  child: Stack(alignment: Alignment.center, children: [
                                    CircularProgressIndicator(
                                      value: pct, strokeWidth: 8,
                                      backgroundColor: AppColors.darkBorder,
                                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                                    ),
                                    Column(mainAxisSize: MainAxisSize.min, children: [
                                      Text('${(pct * 100).toInt()}%',
                                          style: const TextStyle(fontFamily: 'Outfit',
                                              fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary)),
                                      Text('$done/$total', style: TextStyle(fontFamily: 'Outfit',
                                          fontSize: 10, color: AppColors.textSecondaryDark)),
                                    ]),
                                  ]),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Today's Progress",
                                          style: TextStyle(fontFamily: 'Outfit', fontSize: 16,
                                              fontWeight: FontWeight.w600, color: Colors.white)),
                                      const SizedBox(height: 4),
                                      Text('${total - done} tasks remaining',
                                          style: TextStyle(fontFamily: 'Outfit', fontSize: 13,
                                              color: AppColors.textSecondaryDark)),
                                      const SizedBox(height: 12),
                                      Row(children: [
                                        Text(done.toString(),
                                            style: const TextStyle(fontFamily: 'Outfit',
                                                fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.accent)),
                                        Text(' / $total',
                                            style: TextStyle(fontFamily: 'Outfit', fontSize: 18,
                                                color: AppColors.textSecondaryDark)),
                                      ]),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Quick access row
                          Row(
                            children: [
                              Expanded(child: _QuickCard(
                                emoji: '🍅', label: 'Pomodoro', sublabel: 'Focus Timer',
                                color: const Color(0xFF1A1030), border: AppColors.primary,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PomodoroScreen())),
                              )),
                              const SizedBox(width: 12),
                              Expanded(child: _QuickCard(
                                emoji: '🤖', label: 'AI Assistant', sublabel: 'Ask anything',
                                color: const Color(0xFF101A20), border: AppColors.accentCyan,
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiScreen())),
                              )),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Today tasks header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Today's Tasks",
                                  style: TextStyle(fontFamily: 'Outfit', fontSize: 18,
                                      fontWeight: FontWeight.w600, color: Colors.white)),
                              TextButton(
                                onPressed: () {},
                                child: const Text('View All →',
                                    style: TextStyle(color: AppColors.primary, fontFamily: 'Outfit')),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                  // Task list
                  tasks.todayTasks.isEmpty
                      ? SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(children: [
                              const Text('✅', style: TextStyle(fontSize: 48)),
                              const SizedBox(height: 12),
                              const Text('No tasks today!',
                                  style: TextStyle(fontFamily: 'Outfit', fontSize: 18,
                                      fontWeight: FontWeight.w600, color: Colors.white)),
                              const SizedBox(height: 6),
                              Text('Tap + to add your first task',
                                  style: TextStyle(fontFamily: 'Outfit', fontSize: 14,
                                      color: AppColors.textSecondaryDark)),
                            ]),
                          ))
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: TaskTile(task: tasks.todayTasks[i]),
                            ),
                            childCount: tasks.todayTasks.length,
                          ),
                        ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
          ),
        ],
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

  void _showProfileMenu(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(auth.displayName, style: const TextStyle(fontFamily: 'Outfit',
              fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          Text(auth.user?.email ?? '', style: TextStyle(
              fontFamily: 'Outfit', color: AppColors.textSecondaryDark)),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.priorityHigh),
            title: const Text('Sign Out', style: TextStyle(
                fontFamily: 'Outfit', color: AppColors.priorityHigh, fontWeight: FontWeight.w600)),
            onTap: () async {
              await auth.signOut();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
              }
            },
          ),
        ]),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final String emoji, label, sublabel;
  final Color color, border;
  final VoidCallback onTap;
  const _QuickCard({required this.emoji, required this.label, required this.sublabel,
      required this.color, required this.border, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 100,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontFamily: 'Outfit',
            fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
        Text(sublabel, style: TextStyle(fontFamily: 'Outfit',
            fontSize: 11, color: AppColors.textSecondaryDark)),
      ]),
    ),
  );
}
