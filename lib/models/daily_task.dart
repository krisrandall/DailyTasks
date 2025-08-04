import 'task_enums.dart';

class DailyTask {
  final String id;
  final String name;
  final String onDeviceMediaFolder;
  final TaskType taskType;
  final RequiredType required;
  String? lastMediaFilePlayed;
  bool isCompletedToday;
  DateTime? lastCompletedDate;

  DailyTask({
    required this.id,
    required this.name,
    required this.onDeviceMediaFolder,
    required this.taskType,
    required this.required,
    this.lastMediaFilePlayed,
    this.isCompletedToday = false,
    this.lastCompletedDate,
  });

  // Create a copy with updated values
  DailyTask copyWith({
    String? id,
    String? name,
    String? onDeviceMediaFolder,
    TaskType? taskType,
    RequiredType? required,
    String? lastMediaFilePlayed,
    bool? isCompletedToday,
    DateTime? lastCompletedDate,
  }) {
    return DailyTask(
      id: id ?? this.id,
      name: name ?? this.name,
      onDeviceMediaFolder: onDeviceMediaFolder ?? this.onDeviceMediaFolder,
      taskType: taskType ?? this.taskType,
      required: required ?? this.required,
      lastMediaFilePlayed: lastMediaFilePlayed ?? this.lastMediaFilePlayed,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'onDeviceMediaFolder': onDeviceMediaFolder,
      'taskType': taskType.toJson(),
      'required': required.toJson(),
      'lastMediaFilePlayed': lastMediaFilePlayed,
      'isCompletedToday': isCompletedToday,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
    };
  }

  // Create from JSON
  factory DailyTask.fromJson(Map<String, dynamic> json) {
    return DailyTask(
      id: json['id'] as String,
      name: json['name'] as String,
      onDeviceMediaFolder: json['onDeviceMediaFolder'] as String,
      taskType: TaskType.fromJson(json['taskType'] as String),
      required: RequiredType.fromJson(json['required'] as String),
      lastMediaFilePlayed: json['lastMediaFilePlayed'] as String?,
      isCompletedToday: json['isCompletedToday'] as bool? ?? false,
      lastCompletedDate: json['lastCompletedDate'] != null 
          ? DateTime.parse(json['lastCompletedDate'] as String)
          : null,
    );
  }

  // Check if this task needs to be reset (after midnight)
  bool needsReset() {
    if (lastCompletedDate == null) return false;
    
    final now = DateTime.now();
    final lastCompleted = lastCompletedDate!;
    
    // If last completed date is not today, reset is needed
    return lastCompleted.day != now.day || 
           lastCompleted.month != now.month || 
           lastCompleted.year != now.year;
  }

  @override
  String toString() {
    return 'DailyTask(id: $id, name: $name, taskType: $taskType, required: $required, completed: $isCompletedToday)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyTask && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
