class Task {
  int id;
  String title;
  String description;
  String category;
  String label;
  String priority;
  String dueDate;
  String reminder;
  List<Subtask> subtasks;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.label,
    required this.priority,
    required this.dueDate,
    required this.reminder,
    required this.subtasks,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    var subtasksFromJson = json['subtasks'] as List;
    List<Subtask> subtasksList =
        subtasksFromJson.map((i) => Subtask.fromJson(i)).toList();

    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      label: json['label'],
      priority: json['priority'],
      dueDate: json['due_date'],
      reminder: json['reminder'],
      subtasks: subtasksList,
    );
  }
}

class Subtask {
  int id;
  String title;

  Subtask({required this.id, required this.title});

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'],
      title: json['title'],
    );
  }
}
