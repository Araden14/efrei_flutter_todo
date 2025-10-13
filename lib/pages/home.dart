import 'package:flutter/material.dart';
import '../services/todo_service.dart';
import '../models/Todo/todo.model.dart';
import 'dart:developer' as developer;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TodoService _todoService = TodoService();

  late TextEditingController _todocontroller;
  late TextEditingController _datecontroller;
  late TextEditingController _descriptionController;
  late TextEditingController _tagsController;
  late AnimationController _fabController;

  String _selectedPriority = 'normal';
  bool _showAddForm = false;

  @override
  void initState() {
    super.initState();
    _todocontroller = TextEditingController();
    _datecontroller = TextEditingController();
    _descriptionController = TextEditingController();
    _tagsController = TextEditingController();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _todocontroller.dispose();
    _datecontroller.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  void _toggleAddForm() {
    setState(() {
      _showAddForm = !_showAddForm;
      if (_showAddForm) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  void _addItem() async {
    if (_todocontroller.text.isNotEmpty) {
      try {
        DateTime? dueDate;
        if (_datecontroller.text.isNotEmpty) {
          dueDate = DateTime.parse(_datecontroller.text);
        }

        List<String> tags = [];
        if (_tagsController.text.isNotEmpty) {
          tags = _tagsController.text
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList();
        }

        final newTodo = TodoModel(
          id: const Uuid().v4(),
          title: _todocontroller.text,
          description: _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
          userId: _auth.currentUser?.uid ?? '',
          dueDate: dueDate,
          priority: _selectedPriority,
          createdAt: DateTime.now(),
          status: 'pending',
          tags: tags,
        );

        await _todoService.addNew(newTodo);

        _todocontroller.clear();
        _datecontroller.clear();
        _descriptionController.clear();
        _tagsController.clear();
        _toggleAddForm();

        developer.log('Added todo: ${newTodo.title}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Todo ajouté avec succès!', 
                  style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      } catch (e) {
        developer.log('Error adding todo: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }
  }

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return const Color(0xFFFF5252);
      case 'low':
        return const Color(0xFF42A5F5);
      default:
        return const Color(0xFFFFA726);
    }
  }

  IconData _priorityIcon(String priority) {
    switch (priority) {
      case 'high':
        return Icons.priority_high_rounded;
      case 'low':
        return Icons.arrow_downward_rounded;
      default:
        return Icons.remove_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'MegaTODO+',
                style: TextStyle(
                  color: Color(0xFF2D3748),
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.deepOrange.shade400,
                      Colors.orange.shade300,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.logout_rounded, 
                      color: Color(0xFF2D3748), size: 20),
                  ),
                  onPressed: _signOut,
                  tooltip: 'Déconnexion',
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Formulaire d'ajout
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                    height: _showAddForm ? null : 0,
                    child: _showAddForm
                        ? Container(
                            margin: const EdgeInsets.only(bottom: 24),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.deepOrange.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Nouveau Todo',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D3748),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: _toggleAddForm,
                                      color: Colors.grey.shade600,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  controller: _todocontroller,
                                  hint: 'Titre de la tâche',
                                  icon: Icons.edit_note_rounded,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _descriptionController,
                                  hint: 'Description (optionnel)',
                                  icon: Icons.notes_rounded,
                                  maxLines: 3,
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _datecontroller,
                                  hint: 'Date d\'échéance',
                                  icon: Icons.calendar_today_rounded,
                                  readOnly: true,
                                  onTap: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime(2101),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: ColorScheme.light(
                                              primary: Colors.deepOrange,
                                              onPrimary: Colors.white,
                                              surface: Colors.white,
                                              onSurface: Colors.grey.shade800,
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (pickedDate != null) {
                                      _datecontroller.text =
                                          "${pickedDate.toLocal()}".split(' ')[0];
                                    }
                                  },
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                        color: Colors.grey.shade200),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: _selectedPriority,
                                      isExpanded: true,
                                      icon: Icon(Icons.arrow_drop_down,
                                          color: Colors.grey.shade600),
                                      items: [
                                        DropdownMenuItem(
                                          value: 'low',
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: _priorityColor('low'),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Text('Priorité basse'),
                                            ],
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'normal',
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: _priorityColor('normal'),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Text('Priorité normale'),
                                            ],
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'high',
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: _priorityColor('high'),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Text('Priorité haute'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            _selectedPriority = value;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _tagsController,
                                  hint: 'Tags (séparés par des virgules)',
                                  icon: Icons.tag_rounded,
                                ),
                                const SizedBox(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _addItem,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.deepOrange,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_rounded),
                                        SizedBox(width: 8),
                                        Text(
                                          'Ajouter la tâche',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Liste des todos
                  StreamBuilder<List<TodoModel>>(
                    stream: _todoService.getTodosStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            children: [
                              Icon(Icons.error_outline,
                                  size: 64, color: Colors.red.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'Erreur: ${snapshot.error}',
                                style: TextStyle(color: Colors.red.shade600),
                              ),
                            ],
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: CircularProgressIndicator(
                              color: Colors.deepOrange,
                            ),
                          ),
                        );
                      }
                      final todos = snapshot.data!;
                      if (todos.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              Icon(Icons.inbox_rounded,
                                  size: 80, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                'Aucune tâche',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Appuyez sur + pour commencer',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final pendingTodos =
                          todos.where((t) => t.status != 'done').toList();
                      final completedTodos =
                          todos.where((t) => t.status == 'done').toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (pendingTodos.isNotEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'À faire',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.deepOrange.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${pendingTodos.length}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepOrange.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...pendingTodos
                                .map((todo) => _buildTodoCard(todo))
                                .toList(),
                          ],
                          if (completedTodos.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Terminées',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D3748),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${completedTodos.length}',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ...completedTodos
                                .map((todo) => _buildTodoCard(todo))
                                .toList(),
                          ],
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleAddForm,
        backgroundColor: Colors.deepOrange,
        elevation: 4,
        icon: AnimatedRotation(
          turns: _showAddForm ? 0.125 : 0,
          duration: const Duration(milliseconds: 300),
          child: Icon(_showAddForm ? Icons.close : Icons.add_rounded),
        ),
        label: Text(_showAddForm ? 'Annuler' : 'Nouveau'),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(TodoModel todo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text('Confirmer la suppression'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Êtes-vous sûr de vouloir supprimer cette tâche ?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  todo.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
              ),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _todoService.deleteTodo(todo.id ?? '');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Tâche supprimée avec succès'),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la suppression: $e'),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      }
    }
  }

  Widget _buildTodoCard(TodoModel todo) {
    final isDone = todo.status == 'done';
    return Dismissible(
      key: Key(todo.id ?? ''),
      confirmDismiss: (direction) async {
        await _showDeleteConfirmation(todo);
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      direction: DismissDirection.endToStart,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isDone
                  ? Colors.grey.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              final newStatus = isDone ? 'pending' : 'done';
              await _todoService.updateStatus(todo.id ?? '', newStatus);
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _priorityColor(todo.priority).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _priorityIcon(todo.priority),
                      color: _priorityColor(todo.priority),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDone
                                ? Colors.grey.shade400
                                : const Color(0xFF2D3748),
                            decoration:
                                isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        if (todo.description != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            todo.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDone
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                              decoration:
                                  isDone ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ],
                        if (todo.dueDate != null || todo.tags.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (todo.dueDate != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.calendar_today_rounded,
                                          size: 12, color: Colors.blue.shade700),
                                      const SizedBox(width: 4),
                                      Text(
                                        todo.dueDate!
                                            .toLocal()
                                            .toString()
                                            .split(' ')[0],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue.shade700,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ...todo.tags.map(
                                (tag) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.purple.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDone
                            ? Colors.green
                            : Colors.grey.shade300,
                        width: 2,
                      ),
                      color: isDone ? Colors.green : Colors.transparent,
                    ),
                    child: isDone
                        ? const Icon(Icons.check, color: Colors.white, size: 16)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}