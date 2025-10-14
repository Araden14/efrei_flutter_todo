import 'package:flutter/material.dart';
import '../models/Todo/todo.model.dart';
import '../services/todo_service.dart';
import '../pages/add_todo.dart';

class TodoList extends StatelessWidget {
  const TodoList(this.todos, {super.key});
  final List<TodoModel> todos;

  @override
  Widget build(BuildContext context) {
      final todoService = TodoService();
      
      // Separate todos by status
      final pendingTodos = todos.where((todo) => todo.status == 'pending').toList();
      final inProgressTodos = todos.where((todo) => todo.status == 'in progress').toList();
      final doneTodos = todos.where((todo) => todo.status == 'done').toList();
      
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pending Column
                Expanded(
                  child: _TodoColumn(
                    title: 'Pending',
                    todos: pendingTodos,
                    todoService: todoService,
                    headerColor: Colors.orange.shade100,
                  ),
                ),
                const SizedBox(width: 16),
                // In Progress Column
                Expanded(
                  child: _TodoColumn(
                    title: 'In Progress',
                    todos: inProgressTodos,
                    todoService: todoService,
                    headerColor: Colors.blue.shade100,
                  ),
                ),
                const SizedBox(width: 16),
                // Done Column
                Expanded(
                  child: _TodoColumn(
                    title: 'Done',
                    todos: doneTodos,
                    todoService: todoService,
                    headerColor: Colors.green.shade100,
                  ),
                ),
              ],
            ),
          ),
        );  
      }
}

class _TodoColumn extends StatelessWidget {
  final String title;
  final List<TodoModel> todos;
  final TodoService todoService;
  final Color headerColor;

  const _TodoColumn({
    required this.title,
    required this.todos,
    required this.todoService,
    required this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Column Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: headerColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '$title (${todos.length})',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        // Todo Cards
        Expanded(
          child: ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              final noteColor = headerColor;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _StickyNoteCard(
                  todo: todo,
                  noteColor: noteColor,
                  todoService: todoService,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StickyNoteCard extends StatelessWidget {
  final TodoModel todo;
  final Color noteColor;
  final TodoService todoService;

  const _StickyNoteCard({
    required this.todo,
    required this.noteColor,
    required this.todoService,
  });

  @override
  Widget build(BuildContext context) {
    final previousStatus = _previousStatus(todo.status);
    final nextStatus = _nextStatus(todo.status);

    return Container(
      decoration: BoxDecoration(
        color: noteColor,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha : 0.1),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title with status arrows
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        todo.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: todo.status == 'done'
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                          tooltip: previousStatus == null
                              ? null
                              : 'Move to ${_formatStatus(previousStatus)}',
                          onPressed: previousStatus == null || todo.id == null
                              ? null
                              : () async {
                                  await todoService.updateStatus(
                                    todo.id!,
                                    previousStatus,
                                  );
                                },
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                          tooltip: nextStatus == null
                              ? null
                              : 'Move to ${_formatStatus(nextStatus)}',
                          onPressed: nextStatus == null || todo.id == null
                              ? null
                              : () async {
                                  await todoService.updateStatus(
                                    todo.id!,
                                    nextStatus,
                                  );
                                },
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Description
                if (todo.description != null) ...[
                  Text(
                    todo.description!,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                ],
                // Due date
                if (todo.dueDate != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          todo.dueDate!.toLocal().toString().split(' ')[0],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                if (todo.dueDate != null) const SizedBox(height: 12),
                // Priority badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(todo.priority),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        todo.priority,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Menu button
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 20,
                      onSelected: (value) async {
                        if (value == 'delete') {
                          await todoService.deleteTodo(todo.id ?? '');
                        } else if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddTodoPage(todo: todo),
                            ),
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Tags
                if (todo.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 4.0,
                    runSpacing: 4.0,
                    children: todo.tags.map((tag) {
                      return Chip(
                        label: Text(
                          tag,
                          style: const TextStyle(fontSize: 10),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 0),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red.shade600;
      case 'medium':
        return Colors.orange.shade600;
      case 'low':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  String? _previousStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in progress':
        return 'pending';
      case 'done':
        return 'in progress';
      default:
        return null;
    }
  }

  String? _nextStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'in progress';
      case 'in progress':
        return 'done';
      default:
        return null;
    }
  }

  String _formatStatus(String status) {
    return status
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .join(' ');
  }
}
