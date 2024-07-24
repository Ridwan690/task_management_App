import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  AddTaskScreen({this.task});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _labelController = TextEditingController();
  final _dueDateController = TextEditingController();
  final _dueTimeController = TextEditingController();
  final _reminderDateController = TextEditingController();
  final _reminderTimeController = TextEditingController();
  final List<TextEditingController> _subtaskControllers = [];
  String _selectedPriority = 'low';

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      // Initialize the fields with the provided task details.
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _categoryController.text = widget.task!.category;
      _labelController.text = widget.task!.label;
      _selectedPriority = widget.task!.priority;
      _dueDateController.text =
          DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.task!.dueDate));
      _dueTimeController.text =
          DateFormat('h:mm a').format(DateTime.parse(widget.task!.dueDate));
      _reminderDateController.text = DateFormat('yyyy-MM-dd')
          .format(DateTime.parse(widget.task!.reminder));
      _reminderTimeController.text =
          DateFormat('h:mm a').format(DateTime.parse(widget.task!.reminder));

      widget.task!.subtasks.forEach((subtask) {
        _subtaskControllers.add(TextEditingController(text: subtask.title));
      });
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        controller.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        final now = DateTime.now();
        final dt =
            DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
        final formattedTime = DateFormat('h:mm a').format(dt);
        controller.text = formattedTime;

        // Debug print to check the formatted time
        print('Selected Time: $formattedTime');
      });
    }
  }

  void _addSubtaskField() {
    setState(() {
      _subtaskControllers.add(TextEditingController());
    });
  }

  void _removeSubtaskField(int index) {
    setState(() {
      _subtaskControllers.removeAt(index);
    });
  }

  void _saveTask() async {
    List<Subtask> subtasks = _subtaskControllers
        .map((controller) => Subtask(id: 0, title: controller.text))
        .toList();

    // Combine date and time fields
    String dueDateTime =
        '${_dueDateController.text} ${_dueTimeController.text}';
    String reminderDateTime =
        '${_reminderDateController.text} ${_reminderTimeController.text}';

    // Debug print to check the combined date-time strings
    print('Due DateTime: $dueDateTime');
    print('Reminder DateTime: $reminderDateTime');

    try {
      // Parse date and time fields
      DateTime dueDate = DateFormat('yyyy-MM-dd h:mm a').parse(dueDateTime);
      DateTime reminderDate =
          DateFormat('yyyy-MM-dd h:mm a').parse(reminderDateTime);

      // Format date and time to 'yyyy-MM-ddTHH:mm:ss'
      String formattedDueDate =
          DateFormat('yyyy-MM-ddTHH:mm:ss').format(dueDate);
      String formattedReminderDate =
          DateFormat('yyyy-MM-ddTHH:mm:ss').format(reminderDate);

      // Debug print to check the formatted date-time strings
      print('Formatted Due DateTime: $formattedDueDate');
      print('Formatted Reminder DateTime: $formattedReminderDate');

      Task task = Task(
        id: 0, // Ensure this is set to 0 as it's a new task
        title: _titleController.text,
        description: _descriptionController.text,
        category: _categoryController.text,
        label: _labelController.text,
        priority: _selectedPriority,
        dueDate: formattedDueDate,
        reminder: formattedReminderDate,
        subtasks: subtasks,
      );

      await ApiService.addTask(task);

      Navigator.pop(context, true);
    } catch (e) {
      // Handle invalid date format exception
      print('Error parsing date: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        backgroundColor: Color(0xFF40BFA8),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF40BFA8), Color(0xFFFEECAD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        _buildTextField(
                            _titleController, 'Title', 'Enter task title'),
                        SizedBox(height: 10),
                        _buildTextField(_descriptionController, 'Description',
                            'Enter task description',
                            maxLines: 3),
                        SizedBox(height: 10),
                        _buildTextField(_categoryController, 'Category',
                            'Enter task category'),
                        SizedBox(height: 10),
                        _buildTextField(
                            _labelController, 'Label', 'Enter task label'),
                        SizedBox(height: 10),
                        _buildDropdownField('Priority', _selectedPriority,
                            (value) {
                          setState(() {
                            _selectedPriority = value!;
                          });
                        }),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateTimeField(
                                context,
                                _dueDateController,
                                'Due Date',
                                Icons.calendar_today,
                                () => _selectDate(context, _dueDateController),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _buildDateTimeField(
                                context,
                                _dueTimeController,
                                'Due Time',
                                Icons.access_time,
                                () => _selectTime(context, _dueTimeController),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildDateTimeField(
                                context,
                                _reminderDateController,
                                'Reminder Date',
                                Icons.calendar_today,
                                () => _selectDate(
                                    context, _reminderDateController),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _buildDateTimeField(
                                context,
                                _reminderTimeController,
                                'Reminder Time',
                                Icons.access_time,
                                () => _selectTime(
                                    context, _reminderTimeController),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        ..._buildSubtaskFields(),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _addSubtaskField,
                          child: Text('Add Subtask'),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _saveTask,
                          child: Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildDropdownField(
      String label, String value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      items: [
        DropdownMenuItem(value: 'high', child: Text('High')),
        DropdownMenuItem(value: 'medium', child: Text('Medium')),
        DropdownMenuItem(value: 'low', child: Text('Low')),
      ],
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildDateTimeField(
      BuildContext context,
      TextEditingController controller,
      String label,
      IconData icon,
      VoidCallback onTap) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(icon),
          onPressed: onTap,
        ),
        border: OutlineInputBorder(),
      ),
      readOnly: true, // Prevent manual input
    );
  }

  List<Widget> _buildSubtaskFields() {
    return _subtaskControllers.asMap().entries.map((entry) {
      int index = entry.key;
      TextEditingController controller = entry.value;
      return Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Subtask',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove_circle_outline),
            onPressed: () => _removeSubtaskField(index),
          ),
        ],
      );
    }).toList();
  }
}
