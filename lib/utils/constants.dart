import 'package:flutter/material.dart';

class AppConstants {
  // File names
  static const String configFileName = 'daily_tasks_config.json';
  
  // Colors
  static const Color primaryColor = Colors.blue;
  static const Color completedColor = Colors.green;
  static const Color optionalColor = Colors.orange;
  
  // Supported media file extensions
  static const List<String> supportedVideoExtensions = [
    '.mp4', '.mov', '.avi', '.mkv', '.webm', '.m4v', '.3gp'
  ];
  
  static const List<String> supportedAudioExtensions = [
    '.mp3', '.wav', '.m4a', '.aac', '.ogg', '.flac', '.wma'
  ];
  
  static List<String> get allSupportedExtensions => [
    ...supportedVideoExtensions,
    ...supportedAudioExtensions,
  ];
  
  // UI Constants
  static const double taskItemHeight = 72.0;
  static const double taskItemPadding = 16.0;
  static const double iconSize = 24.0;
  static const double thumbnailSize = 120.0;
  
  // TV specific constants
  static const double tvTaskItemHeight = 80.0;
  static const double tvFontSize = 18.0;
  static const double tvIconSize = 32.0;
  
  // Widget specific constants
  static const double widgetItemHeight = 48.0;
  static const double widgetFontSize = 14.0;
  static const double widgetIconSize = 20.0;
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  
  // Default folder names (for new tasks)
  static const List<String> commonFolderNames = [
    'Movies',
    'Music',
    'Videos',
    'Audio',
    'Downloads',
    'Documents',
  ];
}

class AppStrings {
  static const String appTitle = 'Daily Tasks';
  static const String addTask = 'Add Task';
  static const String editTask = 'Edit Task';
  static const String deleteTask = 'Delete Task';
  static const String taskName = 'Task Name';
  static const String mediaFolder = 'Media Folder';
  static const String taskType = 'Task Type';
  static const String required = 'Required';
  static const String sequence = 'Sequence';
  static const String choose = 'Choose';  
  static const String daily = 'Daily';
  static const String optional = 'Optional';
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String confirm = 'Confirm';
  static const String noMediaFound = 'No media files found in this folder';
  static const String folderNotFound = 'Media folder not found';
  static const String selectMediaFile = 'Select a media file to play';
  static const String completedTasks = 'Completed Tasks';
  static const String pendingTasks = 'Pending Tasks';
  static const String optionalTasks = 'Optional Tasks';
}