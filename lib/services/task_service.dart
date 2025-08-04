import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/daily_task.dart';
import '../models/task_enums.dart';
import '../utils/constants.dart';
import '../utils/date_utils.dart' as date_utils;

class TaskService extends ChangeNotifier {
  List<DailyTask> _tasks = [];
  DateTime? _lastMidnightCheck;
  
  List<DailyTask> get tasks => List.unmodifiable(_tasks);
  
  List<DailyTask> get dailyTasks => 
      _tasks.where((task) => task.required == RequiredType.daily).toList();
  
  List<DailyTask> get optionalTasks => 
      _tasks.where((task) => task.required == RequiredType.optional).toList();
  
  List<DailyTask> get pendingDailyTasks => 
      dailyTasks.where((task) => !task.isCompletedToday).toList();
  
  List<DailyTask> get completedDailyTasks => 
      dailyTasks.where((task) => task.isCompletedToday).toList();
  
  List<DailyTask> get pendingOptionalTasks => 
      optionalTasks.where((task) => !task.isCompletedToday).toList();
  
  List<DailyTask> get completedOptionalTasks => 
      optionalTasks.where((task) => task.isCompletedToday).toList();

  /// Initialize the service by loading tasks from storage
  Future<void> initialize() async {
    await loadTasks();
    await checkMidnightReset();
  }

  /// Load tasks from JSON file
  Future<void> loadTasks() async {
    try {
      final file = await _getConfigFile();
      
      if (await file.exists()) {
        final contents = await file.readAsString();
        final jsonData = json.decode(contents) as Map<String, dynamic>;
        final tasksJson = jsonData['tasks'] as List<dynamic>? ?? [];
        
        _tasks = tasksJson
            .map((taskJson) => DailyTask.fromJson(taskJson as Map<String, dynamic>))
            .toList();
        
        // Load last midnight check time
        if (jsonData.containsKey('lastMidnightCheck')) {
          _lastMidnightCheck = DateTime.parse(jsonData['lastMidnightCheck'] as String);
        }
      } else {
        // Create default config file with empty tasks
        _tasks = [];
        await saveTasks();
      }
      
      notifyListeners();
    } catch (e) {
      print('Error loading tasks: $e');
      _tasks = [];
      notifyListeners();
    }
  }

  /// Save tasks to JSON file
  Future<void> saveTasks() async {
    try {
      final file = await _getConfigFile();
      
      final jsonData = {
        'tasks': _tasks.map((task) => task.toJson()).toList(),
        'lastMidnightCheck': DateTime.now().toIso8601String(),
      };
      
      await file.writeAsString(json.encode(jsonData));
      _lastMidnightCheck = DateTime.now();
    } catch (e) {
      print('Error saving tasks: $e');
    }
  }

  /// Add a new task
  Future<void> addTask(DailyTask task) async {
    _tasks.add(task);
    await saveTasks();
    notifyListeners();
  }

  /// Update an existing task
  Future<void> updateTask(DailyTask updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await saveTasks();
      notifyListeners();
    }
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await saveTasks();
    notifyListeners();
  }

  /// Mark a task as completed
  Future<void> markTaskCompleted(String taskId, String? playedMediaFile) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final task = _tasks[taskIndex];
      _tasks[taskIndex] = task.copyWith(
        isCompletedToday: true,
        lastCompletedDate: DateTime.now(),
        lastMediaFilePlayed: playedMediaFile,
      );
      
      await saveTasks();
      notifyListeners();
    }
  }

  /// Check if we need to reset tasks after midnight
  Future<void> checkMidnightReset() async {
    if (date_utils.DateUtils.hasCrossedMidnight(_lastMidnightCheck)) {
      await resetDailyTasks();
    }
  }

  /// Reset all tasks for a new day
  Future<void> resetDailyTasks() async {
    bool hasChanges = false;
    
    for (int i = 0; i < _tasks.length; i++) {
      final task = _tasks[i];
      if (task.isCompletedToday || task.needsReset()) {
        _tasks[i] = task.copyWith(isCompletedToday: false);
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      await saveTasks();
      notifyListeners();
    }
  }

  /// Get a task by ID
  DailyTask? getTaskById(String id) {
    try {
      return _tasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get completion progress (0.0 to 1.0)
  double get completionProgress {
    if (dailyTasks.isEmpty) return 1.0;
    return completedDailyTasks.length / dailyTasks.length;
  }

  /// Get summary statistics
  Map<String, int> get statistics {
    return {
      'totalTasks': _tasks.length,
      'dailyTasks': dailyTasks.length,
      'optionalTasks': optionalTasks.length,
      'completedDaily': completedDailyTasks.length,
      'pendingDaily': pendingDailyTasks.length,
      'completedOptional': completedOptionalTasks.length,
      'pendingOptional': pendingOptionalTasks.length,
    };
  }

  /// Reorder tasks
  Future<void> reorderTasks(List<DailyTask> reorderedTasks) async {
    _tasks = reorderedTasks;
    await saveTasks();
    notifyListeners();
  }

  /// Get the config file
  Future<File> _getConfigFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/${AppConstants.configFileName}');
  }

  /// Create a new task with a unique ID
  DailyTask createNewTask({
    required String name,
    required String onDeviceMediaFolder,
    required TaskType taskType,
    required RequiredType required,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    return DailyTask(
      id: id,
      name: name,
      onDeviceMediaFolder: onDeviceMediaFolder,
      taskType: taskType,
      required: required,
    );
  }

  /// Export tasks to JSON string (for backup/sharing)
  String exportTasks() {
    final data = {
      'tasks': _tasks.map((task) => task.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
      'version': '1.0',
    };
    return json.encode(data);
  }

  /// Import tasks from JSON string (for restore/sharing)
  Future<bool> importTasks(String jsonString, {bool replaceExisting = false}) async {
    try {
      final data = json.decode(jsonString) as Map<String, dynamic>;
      final tasksJson = data['tasks'] as List<dynamic>;
      
      final importedTasks = tasksJson
          .map((taskJson) => DailyTask.fromJson(taskJson as Map<String, dynamic>))
          .toList();
      
      if (replaceExisting) {
        _tasks = importedTasks;
      } else {
        // Add imported tasks, avoiding duplicates by ID
        for (final importedTask in importedTasks) {
          if (!_tasks.any((task) => task.id == importedTask.id)) {
            _tasks.add(importedTask);
          }
        }
      }
      
      await saveTasks();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error importing tasks: $e');
      return false;
    }
  }
}