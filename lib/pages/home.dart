import 'package:flutter/material.dart';
import '../services/todo_service.dart';
import '../models/Todo/todo.model.dart';
import 'dart:developer' as developer;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TodoService _todoService = TodoService();
  late TextEditingController _todocontroller;
  late TextEditingController _datecontroller;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;
  String _selectedPriority = 'normal';

  @override
  void initState() {
    super.initState();
    _todocontroller = TextEditingController();
    _datecontroller = TextEditingController();
    _descriptionController = TextEditingController();
    _tagsController = TextEditingController();
  }

  @override
  void dispose() {
    _todocontroller.dispose();
    _datecontroller.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _addItem() async {
    if (_todocontroller.text.isNotEmpty) {
      try {
        DateTime? dueDate;
        if (_datecontroller.text.isNotEmpty) {
          dueDate = DateTime.parse(_datecontroller.text);
        }
        List<String> tags = <String>[];
        if (_tagsController.text.isNotEmpty) {
          tags = _tagsController.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList();
        }
        final newTodo = TodoModel(
          id: '',  // Auto-generate
          title: _todocontroller.text,
          description: _descriptionController.text.isNotEmpty ? _descriptionController.text : null,
          userId: null,
          dueDate: dueDate,
          priority: _selectedPriority,
          createdAt: DateTime.now(), 
          status: 'pending',
          tags: tags,
        );
        await _todoService.addTodo(newTodo);
        _todocontroller.clear();
        _datecontroller.clear();
        _descriptionController.clear();
        _tagsController.clear();
        developer.log('Added todo: ${newTodo.title}');
      } catch (e) {
        developer.log('Error adding todo: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "✌️MegaTODO+",
          style: TextStyle(
            fontSize: 24,
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            wordSpacing: 4.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Todo input field
            TextField(
              controller: _todocontroller,
              decoration: InputDecoration(
                hintText: 'Ecrivez votre todo',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addItem,
                ),
              ),
              onSubmitted: (_) => _addItem(),
            ),
            const SizedBox(height: 16),
            // Description field
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Description (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Date picker field
            TextField(
              controller: _datecontroller,
              readOnly: true,
              decoration: const InputDecoration(
                hintText: 'Select a date (optional)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  _datecontroller.text = "${pickedDate.toLocal()}".split(' ')[0];  // Format: YYYY-MM-DD
                }
              },
            ),
            const SizedBox(height: 16),
            // Priority dropdown
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                hintText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'normal', child: Text('Normal')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPriority = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            // Tags field
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(
                hintText: 'Tags (comma-separated, optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<TodoModel>>(
                stream: _todoService.getTodosStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final todos = snapshot.data!;
                  return ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return ListTile(
                        title: Text(todo.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (todo.description != null) Text(todo.description!),
                            if (todo.dueDate != null) Text('Due: ${todo.dueDate!.toLocal().toString().split(' ')[0]}'),
                            Text('Priority: ${todo.priority} | Status: ${todo.status}'),
                            if (todo.tags.isNotEmpty) Text('Tags: ${todo.tags.join(', ')}'),
                          ],
                        ),
                        trailing: Checkbox(
                          value: todo.status == 'done',
                          onChanged: (value) async {
                            final newStatus = value! ? 'done' : 'pending';
                            await _todoService.updateTodo(todo.id, {'status': newStatus});
                          },
                        ),
                      );
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
}