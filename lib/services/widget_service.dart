import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import '../models/daily_task.dart';
import '../services/task_service.dart';

class WidgetService {
  static const String _widgetName = 'DailyTasksWidget';
  static const String _tasksKey = 'widget_tasks';
  static const String _progressKey = 'widget_progress';
  static const String _lastUpdateKey = 'widget_last_update';

  /// Initialize the widget service
  static Future<void> initialize() async {
    try {
      await HomeWidget.setAppGroupId('group.dailytasks.widget');
    } catch (e) {
      print('Error initializing widget service: $e');
    }
  }

  /// Update widget with current task data
  static Future<void> updateWidget(TaskService taskService) async {
    try {
      final tasks = taskService.tasks;
      final dailyTasks = taskService.dailyTasks;
      final completedDaily = taskService.completedDailyTasks.length;
      final totalDaily = dailyTasks.length;
      
      // Prepare widget data
      final widgetTasks = tasks.take(5).map((task) => {
        'id': task.id,
        'name': task.name,
        'isCompleted': task.isCompletedToday,
        'isRequired': task.required.name,
        'taskType': task.taskType.name,
      }).toList();

      // Send data to widget
      await HomeWidget.saveWidgetData<String>(
        _tasksKey, 
        jsonEncode(widgetTasks),
      );
      
      await HomeWidget.saveWidgetData<double>(
        _progressKey, 
        totalDaily > 0 ? completedDaily / totalDaily : 0.0,
      );
      
      await HomeWidget.saveWidgetData<String>(
        _lastUpdateKey, 
        DateTime.now().toIso8601String(),
      );

      await HomeWidget.saveWidgetData<int>(
        'completed_count', 
        completedDaily,
      );
      
      await HomeWidget.saveWidgetData<int>(
        'total_count', 
        totalDaily,
      );

      // Update the widget
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _widgetName,
        iOSName: _widgetName,
      );
      
      print('Widget updated successfully');
    } catch (e) {
      print('Error updating widget: $e');
    }
  }

  /// Handle widget tap - opens the app
  static Future<void> handleWidgetTap() async {
    try {
      // This will open the main app
      await HomeWidget.initiallyLaunchedFromHomeWidget();
    } catch (e) {
      print('Error handling widget tap: $e');
    }
  }

  /// Register widget update callback
  static void registerCallback() {
    try {
      HomeWidget.widgetClicked.listen((uri) {
        // Handle different widget interactions
        if (uri != null) {
          _handleWidgetAction(uri);
        }
      });
    } catch (e) {
      print('Error registering widget callback: $e');
    }
  }

  static void _handleWidgetAction(Uri uri) {
    final action = uri.host;
    switch (action) {
      case 'open_app':
        // App is already opening, no additional action needed
        break;
      case 'refresh':
        // Could trigger a refresh in the app
        break;
      default:
        print('Unknown widget action: $action');
    }
  }

  /// Clear widget data
  static Future<void> clearWidget() async {
    try {
      await HomeWidget.saveWidgetData<String>(_tasksKey, '[]');
      await HomeWidget.saveWidgetData<double>(_progressKey, 0.0);
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _widgetName,
        iOSName: _widgetName,
      );
    } catch (e) {
      print('Error clearing widget: $e');
    }
  }
}