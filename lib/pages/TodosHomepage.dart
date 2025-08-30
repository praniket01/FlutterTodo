import 'package:flutter/material.dart';
import 'package:todos/todo_service.dart'; // <-- Your API service

class TodosHomepage extends StatefulWidget {
  const TodosHomepage({super.key});

  @override
  State<TodosHomepage> createState() => _TodosHomepageState();
}

class _TodosHomepageState extends State<TodosHomepage> {
  late Future<List<Todo>> todosFuture;

  @override
  void initState() {
    super.initState();
    todosFuture = TodoService.getTodos(); // fetch from backend
  }

  void _refreshTodos() {
    setState(() {
      todosFuture = TodoService.getTodos();
    });
  }

  void _addTask() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController controller = TextEditingController();
        final TextEditingController anotherController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: 'Enter your task'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: anotherController,
                decoration: const InputDecoration(hintText: 'Enter task description'),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  await TodoService.createTodo(
                    controller.text,
                    anotherController.text, 
                    // optional
                  );
                  Navigator.pop(context);
                  _refreshTodos(); // refresh list
                }
              },
              child: const Text('Add'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Tasks", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Todo>>(
        future: todosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text("Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No tasks yet. Add one!",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          } else {
            final todos = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(todos[index].title), // Assuming Todo has a 'title' property
                    subtitle: Text(todos[index].description ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await TodoService.deleteTodo(todos[index]);
                        _refreshTodos();
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
