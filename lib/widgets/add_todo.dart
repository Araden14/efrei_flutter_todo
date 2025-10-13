import 'package:flutter/material.dart';
import 'package:flutter_todo/services/auth_service.dart';
import '../services/todo_service.dart';
import 'dart:developer' as developer;
import 'package:uuid/uuid.dart';
import "package:flutter_todo/models/Todo/todo.model.dart";

class TodoInput extends StatefulWidget {
  final TodoModel? todo;

  const TodoInput({super.key, this.todo});

  @override
  _TodoInputState createState() => _TodoInputState();
}

class _TodoInputState extends State<TodoInput> {
  final AuthService _auth = AuthService();
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
    if (widget.todo != null) {
      _todocontroller.text = widget.todo!.title;
      _descriptionController.text = widget.todo!.description ?? '';
      _datecontroller.text = widget.todo!.dueDate != null ? widget.todo!.dueDate!.toLocal().toString().split(' ')[0] : '';
      _selectedPriority = widget.todo!.priority;
      _tagsController.text = widget.todo!.tags.join(', ');
    }
  }

  @override
  void dispose() {
    _todocontroller.dispose();
    _datecontroller.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _saveItem() async {
    if (_todocontroller.text.isNotEmpty) {
      try {
        DateTime? dueDate;
        if (_datecontroller.text.isNotEmpty) {
          dueDate = DateTime.parse(_datecontroller.text);
        }
        List<String> tags = <String>[];
        if (_tagsController.text.isNotEmpty) {
          tags = _tagsController.text
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList();
        }
        if (widget.todo != null) {
          // Update
          final updatedTodo = TodoModel(
            id: widget.todo!.id,
            title: _todocontroller.text,
            description: _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
            userId: widget.todo!.userId,
            dueDate: dueDate,
            priority: _selectedPriority,
            createdAt: widget.todo!.createdAt,
            status: widget.todo!.status,
            tags: tags,
          );
          await _todoService.updateTodo(updatedTodo);
        } else {
          // Add new
          final newTodo = TodoModel(
            id: const Uuid().v4(),
            title: _todocontroller.text,
            description: _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
            userId: _auth.currentUser?.uid ?? '',
            dueDate: dueDate,
            priority: _selectedPriority,
            createdAt:
                DateTime.now(), // Will be overridden by serverTimestamp in service
            status: 'pending',
            tags: tags,
          );
          await _todoService.addNew(newTodo);
        }
        // Clear fields only if adding new
        if (widget.todo == null) {
          _todocontroller.clear();
          _datecontroller.clear();
          _descriptionController.clear();
          _tagsController.clear();
        }
        developer.log(widget.todo != null ? 'Updated todo: ${_todocontroller.text}' : 'Added todo: ${_todocontroller.text}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Todo saved successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        developer.log('Error saving todo: $e');
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _todocontroller,
          decoration: InputDecoration(
            hintText: 'Ecrivez votre todo',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: _saveItem,
            ),
          ),
          onSubmitted: (_) => _saveItem(),
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
              _datecontroller.text = "${pickedDate.toLocal()}".split(
                ' ',
              )[0]; // Format: YYYY-MM-DD
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
      ],
    );
  }
}