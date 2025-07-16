import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/expense.dart';
import 'auth_service.dart';

class ExpenseService {
  final String baseUrl = 'http://192.168.1.117:3000/expenses';
  final AuthService _authService = AuthService();

  // Crear nuevo gasto
  Future<Map<String, dynamic>> createExpense(CreateExpenseDto expenseDto) async {
    try {
      final headers = await _authService.getAuthHeaders();
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(expenseDto.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': Expense.fromJson(data)};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Error al crear gasto'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener todos mis gastos
  Future<Map<String, dynamic>> getMyExpenses() async {
    try {
      final headers = await _authService.getAuthHeaders();
      print('🔍 EXPENSE SERVICE - Headers: $headers');
      print('🔍 EXPENSE SERVICE - URL: $baseUrl/my-expenses');
      
      final response = await http.get(
        Uri.parse('$baseUrl/my-expenses'),
        headers: headers,
      );
      
      print('🔍 EXPENSE SERVICE - Status: ${response.statusCode}');
      print('🔍 EXPENSE SERVICE - Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Expense> expenses = data.map((json) => Expense.fromJson(json)).toList();
        return {'success': true, 'data': expenses};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Error al obtener gastos'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener estadísticas de gastos
  Future<Map<String, dynamic>> getMyStats() async {
    try {
      final headers = await _authService.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/my-totals'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': ExpenseStats.fromJson(data)};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Error al obtener estadísticas'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener un gasto específico
  Future<Map<String, dynamic>> getExpense(int id) async {
    try {
      final headers = await _authService.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': Expense.fromJson(data)};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Error al obtener gasto'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Actualizar gasto
  Future<Map<String, dynamic>> updateExpense(int id, UpdateExpenseDto expenseDto) async {
    try {
      final headers = await _authService.getAuthHeaders();
      
      final response = await http.patch(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
        body: jsonEncode(expenseDto.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Error al actualizar gasto'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Eliminar gasto
  Future<Map<String, dynamic>> deleteExpense(int id) async {
    try {
      final headers = await _authService.getAuthHeaders();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Gasto eliminado correctamente'};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Error al eliminar gasto'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Filtrar gastos por fecha
  List<Expense> filterExpensesByDate(List<Expense> expenses, DateTime startDate, DateTime endDate) {
    return expenses.where((expense) {
      return expense.fechaGasto.isAfter(startDate.subtract(Duration(days: 1))) &&
             expense.fechaGasto.isBefore(endDate.add(Duration(days: 1)));
    }).toList();
  }

  // Filtrar gastos por tipo de pago
  List<Expense> filterExpensesByPaymentType(List<Expense> expenses, String paymentType) {
    return expenses.where((expense) => expense.tipoPago == paymentType).toList();
  }

  // Calcular total de una lista de gastos
  double calculateTotal(List<Expense> expenses) {
    return expenses.fold(0, (sum, expense) => sum + expense.gasto);
  }
}