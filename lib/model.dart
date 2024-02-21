import 'package:uuid/uuid.dart';
class Todo {
  final String id;
  final String title;
  final DateTime time;
  final DateTime notificationTime;
  bool isCompleted;


  Todo({
    required this.title,
    required this.time,
    this.isCompleted = false,
    required this.notificationTime,
  }): id = Uuid().v4();
}

class DataController {
  List<Todo> todos = [];

  void addTodo(Todo todo) {
    todos.add(todo);
  }
  void removeTodo(Todo todo) {
    todos.remove(todo);
  }
  void updateTodo(Todo updatedTodo) {
    // Find the index of the todo in the list
    final index = todos.indexWhere((todo) => todo.id == updatedTodo.id);

    // If the todo is found, update it in the list
    if (index != -1) {
      todos[index] = updatedTodo;
    }
  }
}


enum TodoCategory {
  All,
  Today,
  Upcoming,
}