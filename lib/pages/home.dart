import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> todos = [];
  late TextEditingController _todocontroller;
  late TextEditingController _datecontroller;

  @override
  void initState() {
    super.initState();
    _todocontroller = TextEditingController();
    _datecontroller = TextEditingController();
  }

  @override
  void dispose() {
    _todocontroller.dispose();
    _datecontroller.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_todocontroller.text.isNotEmpty) {
      setState(() {
        String newTodo = _todocontroller.text;
        if (_datecontroller.text.isNotEmpty) {
          newTodo += ' - ${_datecontroller.text}';
        }
        todos.add(newTodo);
        _todocontroller.clear();
        _datecontroller.clear();
      });
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
            // Date picker field (existing)
            TextField(
              controller: _datecontroller,
              readOnly: true,
              decoration: const InputDecoration(
                hintText: 'Select a date',
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
            Expanded(
              child: ListView.builder(
                itemCount: todos.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(todos[index]),
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