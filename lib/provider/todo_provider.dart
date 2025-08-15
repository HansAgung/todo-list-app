import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_list_app/model/todo.dart';
import 'package:todo_list_app/todo_service.dart';

class TodoProvider extends ChangeNotifier {
  final _service = TodoService();

  final List<Todo> _todos = [];
  List<Todo> get todos => List.unmodifiable(_todos);

  bool loading = false;
  String? error;
  String? notificationMessage;
  String query = '';

  Future<List<Todo>>? initialFuture;

  static const _cacheKey = 'cached_todos_v1';

  Future<List<Todo>> initAndFetch() {
    initialFuture ??= _init();
    return initialFuture!;
  }

  Future<List<Todo>> _init() async {
    await _loadCache();
    notifyListeners();

    await fetchFromApi(); 
    return todos;
  }

  Future<void> fetchFromApi() async {
    loading = true;
    error = null;
    notificationMessage = null;
    notifyListeners();

    try {
      final data = await _service.fetchTodos();
      _todos
        ..clear()
        ..addAll(data);
      await _saveCache();
    } on SocketException {
      notificationMessage = "Kamu sedang offline";
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> add(String title) async {
    if (title.trim().isEmpty) return;
    loading = true;
    notifyListeners();
    try {
      final created = await _service.addTodo(title.trim());
      _todos.insert(0, created);
      await _saveCache();
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> toggle(Todo todo, bool value) async {
    final idx = _todos.indexWhere((t) => t.id == todo.id);
    if (idx == -1) return;

    final old = _todos[idx];
    _todos[idx] = old.copyWith(completed: value);
    notifyListeners();

    try {
      await _service.toggleCompleted(todo.id, value);
      await _saveCache();
    } catch (e) {
      _todos[idx] = old;
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> remove(Todo todo) async {
    final idx = _todos.indexWhere((t) => t.id == todo.id);
    if (idx == -1) return;
    final removed = _todos.removeAt(idx);
    notifyListeners();
    try {
      await _service.deleteTodo(removed.id);
      await _saveCache();
    } catch (e) {
      _todos.insert(idx, removed);
      error = e.toString();
      notifyListeners();
    }
  }

  void setQuery(String q) {
    query = q;
    notifyListeners();
  }

  List<Todo> get filtered {
    if (query.isEmpty) return todos;
    final q = query.toLowerCase();
    return todos.where((t) => t.title.toLowerCase().contains(q)).toList();
  }

  Future<void> _saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    final str = jsonEncode(_todos.map((e) => e.toJson()).toList());
    await prefs.setString(_cacheKey, str);
  }

  Future<void> _loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_cacheKey);
    if (str != null) {
      final List list = jsonDecode(str);
      _todos
        ..clear()
        ..addAll(list.map((e) => Todo.fromJson(e)).toList());
    }
  }
}
