// In your models/todo.dart
class Task {
  String id;
  String title;
  String? description; // Make sure this is nullable if it can be
  DateTime? dueDate;   // Nullable
  bool done;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    this.done = false, // Default value
  });

  // Factory constructor to create a Task from a map (e.g., from JSON)
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      // Handle DateTime conversion carefully
      dueDate: map['dueDate'] == null ? null : DateTime.tryParse(map['dueDate'] as String),
      done: map['done'] as bool? ?? false,
    );
  }

  // Method to convert a Task instance to a map (e.g., for JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      // Store DateTime as ISO 8601 string
      'dueDate': dueDate?.toIso8601String(),
      'done': done,
    };
  }
}

