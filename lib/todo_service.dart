import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:todo_list_app/model/todo.dart';

class TodoService {
  static const String getUrl =
      'https://jsonplaceholder.typicode.com/users/1/todos';

  static const String baseTodos = 'https://jsonplaceholder.typicode.com/todos';

  Future<List<Todo>> fetchTodos() async {
    final res = await http.get(
      Uri.parse(getUrl),
      headers: {
        "Accept": "application/json",
      },
    );

    print('Status code: ${res.statusCode}');
    print('Response body: ${res.body}');

    if (res.statusCode == 200) {
      final list = (jsonDecode(res.body) as List)
          .map((e) => Todo.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } else {
      throw Exception('Gagal memuat todos (${res.statusCode})');
    }
  }

  Future<Todo> addTodo(String title) async {
    final res = await http.post(
      Uri.parse(baseTodos),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'title': title,
        'completed': false,
        'userId': 1,
      }),
    );

    print('Status code: ${res.statusCode}');
    print('Response body: ${res.body}');

    if (res.statusCode == 201 || res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return Todo(
        id: data['id'] ?? 201,
        userId: data['userId'] ?? 1,
        title: data['title'] ?? title,
        completed: data['completed'] ?? false,
      );
    }
    throw Exception('Gagal menambahkan todo (${res.statusCode})');
  }

  Future<Todo> toggleCompleted(int id, bool completed) async {
    final res = await http.patch(
      Uri.parse('$baseTodos/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'completed': completed}),
    );

    print('Status code: ${res.statusCode}');
    print('Response body: ${res.body}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return Todo(
        id: data['id'] ?? id,
        userId: data['userId'] ?? 1,
        title: data['title'] ?? '',
        completed: data['completed'] ?? completed,
      );
    }
    throw Exception('Gagal mengubah status (${res.statusCode})');
  }
  
    Future<void> deleteTodo(int id) async {
    final res = await http.delete(
      Uri.parse('$baseTodos/$id'),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
    );

    print('Status code: ${res.statusCode}');
    print('Response body: ${res.body}');

    if (res.statusCode == 200 || res.statusCode == 204) {
      print("Todo dengan ID $id berhasil dihapus.");
      return;
    } else {
      throw Exception('Gagal menghapus todo (${res.statusCode})');
    }
  }

}
