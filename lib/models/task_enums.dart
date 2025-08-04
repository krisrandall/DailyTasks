enum TaskType {
  sequence,
  choose;

  String toJson() => name;
  
  static TaskType fromJson(String json) {
    return TaskType.values.firstWhere((e) => e.name == json);
  }
}

enum RequiredType {
  daily,
  optional;

  String toJson() => name;
  
  static RequiredType fromJson(String json) {
    return RequiredType.values.firstWhere((e) => e.name == json);
  }
}