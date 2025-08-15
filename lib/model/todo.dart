class Todo {
  final int id;
  final int userId;
  final String title;
  final bool completed;

  const Todo({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        id: json['id'] as int,
        userId: json['userId'] as int,
        title: json['title'] as String? ?? '',
        completed: json['completed'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'completed': completed,
      };

  Todo copyWith({
    int? id,
    int? userId,
    String? title,
    bool? completed,
  }) {
    return Todo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
    );
  }
}
