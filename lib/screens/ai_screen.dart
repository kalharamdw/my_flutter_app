import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../services/claude_service.dart';
import '../utils/app_theme.dart';
import '../models/task.dart';

class _Message {
  final String text;
  final bool isUser;
  final DateTime time;
  _Message(this.text, this.isUser) : time = DateTime.now();
}

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});
  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<_Message> _messages = [];
  bool _loading = false;

  final _suggestions = [
    'Plan my day',
    'What\'s overdue?',
    'Suggest priorities',
    'Motivate me! 🔥',
    'Give me a tip',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(_Message(
        'Hi! I\'m your AI productivity assistant 🤖\n\nI can help you plan tasks, set priorities, and boost your focus. I can see your current tasks too. What would you like to do today?',
        false));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send([String? text]) async {
    final msg = (text ?? _ctrl.text).trim();
    if (msg.isEmpty || _loading) return;
    _ctrl.clear();
    setState(() {
      _messages.add(_Message(msg, true));
      _loading = true;
    });
    _scrollToBottom();

    final taskProvider = context.read<TaskProvider>();
    final tasks = taskProvider.allTasks.take(15).toList();
    final taskSummary = tasks.isEmpty
        ? 'No tasks yet.'
        : tasks.map((t) =>
            '- ${t.title} [${t.priority.label}] [${t.status.name}]'
            '${t.dueDate != null ? ' due: ${t.dueDate!.toLocal().toString().substring(0, 10)}' : ''}')
            .join('\n');

    final systemPrompt = '''You are TaskMaster AI, a friendly and motivating productivity assistant.
The user's current tasks:
$taskSummary

Keep responses concise (2-4 sentences max, unless listing tasks). Be encouraging, practical and actionable. Use emojis sparingly.''';

    final history = _messages
        .where((m) => m != _messages.last)
        .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
        .toList();
    history.add({'role': 'user', 'content': msg});

    final reply = await ClaudeService.chat(
        messages: history.cast<Map<String, String>>(),
        systemPrompt: systemPrompt);

    if (mounted) {
      setState(() {
        _messages.add(_Message(reply, false));
        _loading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Column(children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            decoration: const BoxDecoration(color: AppColors.darkBg),
            child: Row(children: [
              Container(
                width: 42, height: 42,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.accentCyan]),
                ),
                child: const Center(child: Text('🤖', style: TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('AI Assistant', style: TextStyle(fontFamily: 'Outfit',
                    fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                Row(children: [
                  Container(width: 8, height: 8,
                      decoration: const BoxDecoration(
                          color: AppColors.accent, shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text('Online', style: TextStyle(fontFamily: 'Outfit',
                      fontSize: 12, color: AppColors.accent)),
                ]),
              ]),
            ]),
          ),
          // Suggestion chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _send(_suggestions[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.darkElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                  ),
                  child: Text(_suggestions[i], style: const TextStyle(
                      fontFamily: 'Outfit', fontSize: 12,
                      color: AppColors.primary, fontWeight: FontWeight.w500)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length + (_loading ? 1 : 0),
              itemBuilder: (_, i) {
                if (_loading && i == _messages.length) {
                  return _TypingIndicator();
                }
                final m = _messages[i];
                return _Bubble(message: m);
              },
            ),
          ),
          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.darkSurface,
              border: Border(top: BorderSide(color: AppColors.darkBorder)),
            ),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: const TextStyle(fontFamily: 'Outfit', color: Colors.white),
                  maxLines: 3,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: const InputDecoration(
                    hintText: 'Ask me anything…',
                    hintStyle: TextStyle(fontFamily: 'Outfit',
                        color: AppColors.textSecondaryDark),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _loading ? null : () => _send(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: _loading ? AppColors.darkBorder : AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final _Message message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ...[
            Container(width: 30, height: 30,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [AppColors.primary, AppColors.accentCyan])),
                child: const Center(child: Text('🤖', style: TextStyle(fontSize: 14)))),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: message.isUser ? AppColors.primary : AppColors.darkElevated,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(message.isUser ? 18 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 18),
                ),
                border: message.isUser
                    ? null
                    : Border.all(color: AppColors.darkBorder),
              ),
              child: Text(message.text,
                  style: const TextStyle(fontFamily: 'Outfit',
                      fontSize: 14, color: Colors.white, height: 1.5)),
            ),
          ),
          if (message.isUser) const SizedBox(width: 4),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Container(width: 30, height: 30,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppColors.primary, AppColors.accentCyan])),
            child: const Center(child: Text('🤖', style: TextStyle(fontSize: 14)))),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.darkElevated,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => Row(mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Opacity(
                    opacity: i == 0 ? _anim.value : i == 1 ? (1 - _anim.value * 0.5) : (0.3 + _anim.value * 0.4),
                    child: Container(width: 7, height: 7,
                        decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle)),
                  ),
                ))),
          ),
        ),
      ]),
    );
  }
}
