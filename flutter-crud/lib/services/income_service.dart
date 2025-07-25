import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/income.dart';
import 'auth_service.dart';

class IncomeService {
  final String baseUrl = 'https://expenses-tracker-snowy-three.vercel.app/incomes';
  final AuthService _authService = AuthService();

  // Crear nuevo ingreso
  Future<Map<String, dynamic>> createIncome(CreateIncomeDto incomeDto) async {
    try {
      final headers = await _authService.getAuthHeaders();
      
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(incomeDto.toJson()),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': Income.fromJson(data)};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Error al crear ingreso'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener todos mis ingresos
  Future<Map<String, dynamic>> getMyIncomes() async {
    try {
      final headers = await _authService.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/my-incomes'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Income> incomes = data.map((json) => Income.fromJson(json)).toList();
        return {'success': true, 'data': incomes};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Error al obtener ingresos'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener estadísticas de ingresos
  Future<Map<String, dynamic>> getMyStats() async {
    try {
      final headers = await _authService.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/my-totals'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': IncomeStats.fromJson(data)};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Error al obtener estadísticas'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener ingresos por rango de fechas
  Future<Map<String, dynamic>> getIncomesByDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final headers = await _authService.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/by-date-range?startDate=${startDate.toIso8601String().split('T')[0]}&endDate=${endDate.toIso8601String().split('T')[0]}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final List<Income> incomes = data.map((json) => Income.fromJson(json)).toList();
        return {'success': true, 'data': incomes};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Error al obtener ingresos'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Obtener un ingreso específico
  Future<Map<String, dynamic>> getIncome(int id) async {
    try {
      final headers = await _authService.getAuthHeaders();
      
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': Income.fromJson(data)};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Error al obtener ingreso'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Actualizar ingreso
  Future<Map<String, dynamic>> updateIncome(int id, UpdateIncomeDto incomeDto) async {
    try {
      final headers = await _authService.getAuthHeaders();
      
      final response = await http.patch(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
        body: jsonEncode(incomeDto.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Error al actualizar ingreso'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Eliminar ingreso
  Future<Map<String, dynamic>> deleteIncome(int id) async {
    try {
      final headers = await _authService.getAuthHeaders();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Ingreso eliminado correctamente'};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Error al eliminar ingreso'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error de conexión: $e'};
    }
  }

  // Filtrar ingresos por fuente
  List<Income> filterIncomesBySource(List<Income> incomes, String source) {
    return incomes.where((income) => income.fuenteIngreso == source).toList();
  }

  // Filtrar ingresos por fecha
  List<Income> filterIncomesByDate(List<Income> incomes, DateTime startDate, DateTime endDate) {
    return incomes.where((income) {
      return income.fechaIngreso.isAfter(startDate.subtract(Duration(days: 1))) &&
             income.fechaIngreso.isBefore(endDate.add(Duration(days: 1)));
    }).toList();
  }

  // Calcular total de una lista de ingresos
  double calculateTotal(List<Income> incomes) {
    return incomes.fold(0, (sum, income) => sum + income.monto);
  }

  // Agrupar ingresos por fuente
  Map<String, List<Income>> groupIncomesBySource(List<Income> incomes) {
    Map<String, List<Income>> grouped = {};
    for (var income in incomes) {
      final source = income.fuenteIngreso ?? 'Sin especificar';
      if (!grouped.containsKey(source)) {
        grouped[source] = [];
      }
      grouped[source]!.add(income);
    }
    return grouped;
  }

  // Obtener ingresos del mes actual
  List<Income> getCurrentMonthIncomes(List<Income> incomes) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return filterIncomesByDate(incomes, startOfMonth, endOfMonth);
  }

  // Obtener ingresos del año actual
  List<Income> getCurrentYearIncomes(List<Income> incomes) {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    final endOfYear = DateTime(now.year, 12, 31);
    
    return filterIncomesByDate(incomes, startOfYear, endOfYear);
  }
}