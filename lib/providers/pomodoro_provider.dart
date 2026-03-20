import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SessionType { work, shortBreak, longBreak }

class PomodoroProvider extends ChangeNotifier {
  SessionType sessionType = SessionType.work;
  int workMins = 25;
  int shortMins = 5;
  int longMins = 15;
  int sessionsPerLong = 4;

  int sessionsCompleted = 0;
  String currentTaskTitle = '';
  bool isRunning = false;

  late int _msLeft;
  late int _totalMs;
  Timer? _timer;

  PomodoroProvider() {
    _reset(SessionType.work);
  }

  int get msLeft => _msLeft;
  int get totalMs => _totalMs;
  double get progress => _totalMs == 0 ? 0 : (_totalMs - _msLeft) / _totalMs;

  String get formattedTime {
    final s = _msLeft ~/ 1000;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }

  String get sessionLabel => switch (sessionType) {
        SessionType.work => 'Focus Time 🎯',
        SessionType.shortBreak => 'Short Break ☕',
        SessionType.longBreak => 'Long Break 🌿',
      };

  Color get sessionColor => switch (sessionType) {
        SessionType.work => const Color(0xFF6C63FF),
        SessionType.shortBreak => const Color(0xFF43E97B),
        SessionType.longBreak => const Color(0xFF38F9D7),
      };

  void start() {
    if (isRunning) return;
    isRunning = true;
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _msLeft -= 500;
      if (_msLeft <= 0) {
        _msLeft = 0;
        _onDone();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    isRunning = false;
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    isRunning = false;
    _reset(sessionType);
    notifyListeners();
  }

  void skip() {
    _timer?.cancel();
    isRunning = false;
    _onDone();
  }

  void setTask(String title) {
    currentTaskTitle = title;
    notifyListeners();
  }

  void _onDone() {
    if (sessionType == SessionType.work) {
      sessionsCompleted++;
      final next = sessionsCompleted % sessionsPerLong == 0
          ? SessionType.longBreak
          : SessionType.shortBreak;
      _reset(next);
    } else {
      _reset(SessionType.work);
    }
    notifyListeners();
  }

  void _reset(SessionType type) {
    sessionType = type;
    final mins = switch (type) {
      SessionType.work => workMins,
      SessionType.shortBreak => shortMins,
      SessionType.longBreak => longMins,
    };
    _totalMs = mins * 60 * 1000;
    _msLeft = _totalMs;
  }

  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
}
