import 'dart:convert';
import 'package:http/http.dart' as http;

class Todo {
  final int id;
  final String title;
  final String description;
  final bool completed;

  Todo({required this.id, required this.title, required this.description, required this.completed});

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      completed: json['completed'],
    );
  }
}

class TodoService {
  static const String baseUrl = "https://fluttertodo.onrender.com"; 
  // Fetch all todos
  static Future<List<Todo>> getTodos() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((todo) => Todo.fromJson(todo)).toList();
    } else {
      throw Exception("Failed to load todos");
    }
  }

  // Add a new todo
  static Future<Todo> createTodo(String title, String description) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "title": title,
        "description": description,
        "completed": false
      }),
    );
    if (response.statusCode == 201) {
      return Todo.fromJson(json.decode(response.body));
    } else {
      throw Exception("Failed to create todo");
    }
  }

  // Delete a todo
  static Future<void> deleteTodo(Todo todo) async {
    final response = await http.delete(
      Uri.parse("$baseUrl/${todo.id}"),
      headers: {"Content-Type": "application/json"},
    );
    if (response.statusCode != 204) {
      throw Exception("Failed to delete todo");
    }
  }

}
