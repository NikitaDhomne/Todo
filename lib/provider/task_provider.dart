import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:todo_app/model/task_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  static const String _tasksKey = 'tasks';

  Future<void> loadTasksFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? tasksJson = prefs.getStringList(_tasksKey);
    if (tasksJson != null) {
      _tasks =
          tasksJson.map((json) => Task.fromJson(jsonDecode(json))).toList();
    }
    notifyListeners();
  }

  Future<void> saveTasksToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasksJson =
        _tasks.map((task) => jsonEncode(task.toJson())).toList();
    prefs.setStringList(_tasksKey, tasksJson);
  }

  void addTask(Task task) {
    _tasks.add(task);
    saveTasksToPrefs();
    notifyListeners();
  }

  void toggleTaskCompletion(Task task) {
    task.isCompleted = !task.isCompleted;
    saveTasksToPrefs();
    notifyListeners();
  }

  void deleteTask(Task task) {
    _tasks.remove(task);
    saveTasksToPrefs();
    notifyListeners();
  }
}
