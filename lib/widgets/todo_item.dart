import 'package:flutter/material.dart';
import 'package:todo_list_app/model/todo.dart';

class TodoItem extends StatelessWidget {
  final Todo todo;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: Checkbox(
          value: todo.completed,
          onChanged: (v) => onToggle(v ?? false),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            decoration:
                todo.completed ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Text('ID: ${todo.id}  •  userId: ${todo.userId}'),
        trailing: IconButton(
          tooltip: 'Hapus',
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
