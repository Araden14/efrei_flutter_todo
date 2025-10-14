import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/Todo/todo.model.dart';
import '../services/todo_service.dart';
import '../pages/add_todo.dart';

class TodoList extends StatelessWidget {
  const TodoList(this.todos, {super.key});
  final List<TodoModel> todos;

  @override
  Widget build(BuildContext context) {
      final todoService = TodoService();
      
        return AnimationLimiter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 1.5,
              ),
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
                final stickyNoteColors = [
                  Colors.yellow.shade200,
                  Colors.pink.shade100,
                  Colors.blue.shade100,
                  Colors.green.shade100,
                  Colors.orange.shade100,
                ];
                final noteColor = stickyNoteColors[index % stickyNoteColors.length];
                
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 3,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: _StickyNoteCard(
                        todo: todo,
                        noteColor: noteColor,
                        todoService: todoService,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
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
          // Sticky note tape effect at top
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha : 0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
            ),
          ),
          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title with checkbox
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
                    Transform.scale(
                      scale: 0.8,
                      child: Checkbox(
                        value: todo.status == 'done',
                        onChanged: (value) async {
                          final newStatus = value! ? 'done' : 'pending';
                          await todoService.updateStatus(todo.id ?? '', newStatus);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Description
                if (todo.description != null)
                  Expanded(
                    child: Text(
                      todo.description!,
                      style: const TextStyle(fontSize: 14),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const Spacer(),
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
                if (todo.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Wrap(
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
                  ),
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
}
