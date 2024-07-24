class Subtask {
  int? id;
  String title;
  bool isCompleted;

  Subtask({
    this.id,
    required this.title,
    this.isCompleted = false,
  });

  factory Subtask.fromJson(Map<String, dynamic> json) {
    return Subtask(
      id: json['id'],
      title: json['title'],
      isCompleted: json['is_completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'is_completed': isCompleted,
    };
  }
}
