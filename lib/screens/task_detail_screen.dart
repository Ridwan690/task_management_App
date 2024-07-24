import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'update_task_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  TaskDetailScreen({required this.task});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late Future<Task> _task;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  void _loadTask() {
    setState(() {
      _task = ApiService.getTask(widget.task.id);
    });
  }

  Future<void> _navigateToUpdateTask() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateTaskScreen(task: widget.task),
      ),
    );

    if (result == true) {
      _loadTask(); // Reload task data if updated
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Details'),
        backgroundColor: Color(0xFF40BFA8),
      ),
      body: FutureBuilder<Task>(
        future: _task,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('No task details found'));
          } else {
            Task task = snapshot.data!;
            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF40BFA8), Color(0xFFFEECAD)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: EdgeInsets.all(16.0),
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
                            Text(
                              task.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              task.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            SizedBox(height: 16),
                            _buildDetailRow('Category', task.category),
                            _buildDetailRow('Label', task.label),
                            _buildDetailRow(
                                'Priority', _priorityToString(task.priority)),
                            _buildDetailRow(
                                'Due Date',
                                DateFormat('yyyy-MM-dd')
                                    .format(DateTime.parse(task.dueDate))),
                            _buildDetailRow(
                                'Due Time',
                                DateFormat('hh:mm a')
                                    .format(DateTime.parse(task.dueDate))),
                            _buildDetailRow(
                                'Reminder Date',
                                DateFormat('yyyy-MM-dd')
                                    .format(DateTime.parse(task.reminder))),
                            _buildDetailRow(
                                'Reminder Time',
                                DateFormat('hh:mm a')
                                    .format(DateTime.parse(task.reminder))),
                            SizedBox(height: 16),
                            Text(
                              'Subtasks',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            ...task.subtasks.map((subtask) => Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    '- ${subtask.title}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                )),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _navigateToUpdateTask,
                              child: Text('Edit Task'),
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF40BFA8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _priorityToString(String priority) {
    switch (priority) {
      case 'high':
        return 'High';
      case 'medium':
        return 'Medium';
      case 'low':
        return 'Low';
      default:
        return 'Unknown';
    }
  }
}
