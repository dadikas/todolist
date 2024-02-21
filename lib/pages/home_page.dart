import 'package:flutter/material.dart';
import 'package:todolist/widget/navigation_drawer.dart';
import 'package:intl/intl.dart';
import 'package:todolist/model.dart';
import 'package:todolist/notification/notification.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _todoController = TextEditingController();
  final NotificationService _notificationService = NotificationService();
  _HomePageState();
  String _searchQuery = '';
  DateTime? _selectedTime;

   @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: navigationDrawer(),
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              decoration: InputDecoration(
                labelText: 'Search TODOs',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _todoController,
                    decoration: InputDecoration(
                      labelText: 'Enter TODO',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a TODO';
                      }
                      return null;
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          _selectTime(context);
                        },
                        child: Text(
                          _selectedTime == null ? 'Select Time' : 'Selected Time: ${DateFormat('HH:mm').format(_selectedTime!)}',
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _addTodo();
                            
                          }
                        },
                        child: Text('Add TODO'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter by:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                DropdownButton<TodoCategory>(
                  value: _selectedCategory,
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                  items: TodoCategory.values.map((category) {
                    return DropdownMenuItem<TodoCategory>(
                      value: category,
                      child: Text(category.toString().split('.').last),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: getFilteredTodos().length,
                itemBuilder: (context, index) {
                  final todo = getFilteredTodos()[index];
                  return ListTile(
                    title: Text(todo.title),
                    subtitle: Text('Time: ${DateFormat('HH:mm').format(todo.time)}'),
                    // Add checkmark icon for completed todos
                    trailing: todo.isCompleted ? Icon(Icons.check) : IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteTodo(todo);
                      },
                    ),
                    onTap: () {
                      // Toggle completed status and update UI
                      setState(() {
                        todo.isCompleted = !todo.isCompleted;
                      });
                      _updateTodo(todo); // Update todo in data list
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
   Future<void> _scheduleNotification(Todo todo) async {
    await _notificationService.scheduleNotification(todo);
  }

  List<Todo> getFilteredTodos() {
    List<Todo> filteredTodos = _dataController.todos;
    if (_searchQuery.isNotEmpty) {
      filteredTodos = filteredTodos.where((todo) =>
          todo.title.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
    }
    switch (_selectedCategory) {
      case TodoCategory.All:
        return filteredTodos;
      case TodoCategory.Today:
        return filteredTodos.where((todo) => isToday(todo.time)).toList();
      case TodoCategory.Upcoming:
        return filteredTodos.where((todo) => isUpcoming(todo.time)).toList();
    }
  }
  
  void _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, pickedTime.hour, pickedTime.minute);
      });
    }
  }

  void _addTodo() {
    final String todoText = _todoController.text;
    if (todoText.isNotEmpty && _selectedTime != null) {
      final Todo newTodo = Todo(
        title: todoText,
        time: _selectedTime!,
        notificationTime: _selectedTime!.subtract(Duration(minutes: 10)),
      );
      _dataController.addTodo(newTodo);
      _scheduleNotification(newTodo);
      _todoController.clear();
      setState(() {
        _selectedTime = null;
      });
    }
    
  }
  void _markTodoAsCompleted(Todo todo) {
    _dataController.removeTodo(todo); // Remove the TODO from the list
    // Cancel the notification for this TODO
  }
  void _updateTodo(Todo todo) {
  _dataController.updateTodo(todo);
  }
  void _deleteTodo(Todo todo) {
    setState(() {
      _dataController.removeTodo(todo);
    });
  }
}
final DataController _dataController = DataController();
TodoCategory _selectedCategory = TodoCategory.All;



bool isToday(DateTime dateTime) {
  final now = DateTime.now();
  return dateTime.year == now.year && dateTime.month == now.month && dateTime.day == now.day;
}

bool isUpcoming(DateTime dateTime) {
  return dateTime.isAfter(DateTime.now());
}
