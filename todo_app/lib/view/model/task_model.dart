import 'dart:convert';

class Task {
  int? id;
  String? title;
  bool? isCompleted;
  bool? isEdit;
  String? priority;

  Task({
    this.id,
    this.title,
    this.isCompleted = false,
    this.isEdit = false,
    this.priority,
  });

  // Convert a Task object into a Map object (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'isEdit': isEdit,
      'priority': priority,
    };
  }

  // Convert a Map object (JSON) into a Task object
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'] ?? false,
      isEdit: json['isEdit'] ?? false,
      priority: json['priority'],
    );
  }

  // Convert a list of Task objects to a list of JSON maps
  static String encode(List<Task> tasks) => json.encode(
        tasks.map<Map<String, dynamic>>((task) => task.toJson()).toList(),
      );

  // Decode a list of JSON maps into a list of Task objects
  static List<Task> decode(String tasks) =>
      (json.decode(tasks) as List<dynamic>)
          .map<Task>((item) => Task.fromJson(item))
          .toList();
}
