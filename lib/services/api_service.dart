import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../models/user.dart';

class ApiService {

  static const String baseUrl = 'http://10.0.2.2:8000/api';

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> removeToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<http.Response> register(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': user.name,
        'email': user.email,
        'password': user.password,
        'password_confirmation': user.password,
      }),
    );
    return response;
  }

  static Future<http.Response> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return response;
  }

  static Future<List<Task>> getTasks() async {
    String? token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Task>.from(l.map((model) => Task.fromJson(model)));
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  static Future<Task> getTask(int id) async {
    String? token = await getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load task');
    }
  }

  static Future<http.Response> addTask(Task task) async {
    String? token = await getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': task.title,
        'description': task.description,
        'category': task.category,
        'label': task.label,
        'priority': task.priority,
        'due_date': task.dueDate,
        'reminder': task.reminder,
        'subtasks':
            task.subtasks.map((subtask) => {'title': subtask.title}).toList(),
      }),
    );
    return response;
  }

  static Future<http.Response> updateTask(Task task) async {
    String? token = await getToken();
    final response = await http.put(
      Uri.parse('$baseUrl/tasks/${task.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': task.title,
        'description': task.description,
        'category': task.category,
        'label': task.label,
        'priority': task.priority,
        'due_date': task.dueDate,
        'reminder': task.reminder,
        'subtasks': task.subtasks
            .map((subtask) => {'id': subtask.id, 'title': subtask.title})
            .toList(),
      }),
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    return response;
  }

  static Future<http.Response> deleteTask(int id) async {
    String? token = await getToken();
    final response = await http.delete(
      Uri.parse('$baseUrl/tasks/$id'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return response;
  }
}
