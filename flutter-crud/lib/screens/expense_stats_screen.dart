import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class ExpenseStatsScreen extends StatefulWidget {
  @override
  _ExpenseStatsScreenState createState() => _ExpenseStatsScreenState();
}

class _ExpenseStatsScreenState extends State<ExpenseStatsScreen> {
  final ExpenseService _expenseService = ExpenseService();
  ExpenseStats? _stats;
  List<Expense> _expenses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final statsResult = await _expenseService.getMyStats();
    final expensesResult = await _expenseService.getMyExpenses();
    
    if (statsResult['success'] && expensesResult['success']) {
      setState(() {
        _stats = statsResult['data'];
        _expenses = expensesResult['data'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar estadísticas')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas de Gastos'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _stats == null
              ? Center(child: Text('No se pudieron cargar las estadísticas'))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Resumen general
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Resumen General',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                SizedBox(height: 16),
                                _buildStatItem(
                                  'Total Gastado',
                                  '\$${_stats!.total.toStringAsFixed(2)}',
                                  Colors.red,
                                  Icons.account_balance_wallet,
                                ),
                                Divider(),
                                _buildStatItem(
                                  'Gastos en Crédito',
                                  '\$${_stats!.credito.toStringAsFixed(2)}',
                                  Colors.orange,
                                  Icons.credit_card,
                                ),
                                Divider(),
                                _buildStatItem(
                                  'Gastos en Efectivo',
                                  '\$${_stats!.efectivo.toStringAsFixed(2)}',
                                  Colors.red,
                                  Icons.money,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        // Porcentajes
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Distribución por Tipo de Pago',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                SizedBox(height: 16),
                                _buildPercentageBar(
                                  'Crédito',
                                  _stats!.credito,
                                  _stats!.total,
                                  Colors.orange,
                                ),
                                SizedBox(height: 8),
                                _buildPercentageBar(
                                  'Efectivo',
                                  _stats!.efectivo,
                                  _stats!.total,
                                  Colors.red,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        // Información adicional
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Información Adicional',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                SizedBox(height: 16),
                                _buildInfoRow(
                                  'Total de Gastos',
                                  _expenses.length.toString(),
                                  Icons.receipt,
                                ),
                                _buildInfoRow(
                                  'Promedio por Gasto',
                                  _expenses.isEmpty ? '\$0.00' : '\$${(_stats!.total / _expenses.length).toStringAsFixed(2)}',
                                  Icons.trending_up,
                                ),
                                _buildInfoRow(
                                  'Gasto Mayor',
                                  _expenses.isEmpty ? '\$0.00' : '\$${_expenses.map((e) => e.gasto).reduce((a, b) => a > b ? a : b).toStringAsFixed(2)}',
                                  Icons.keyboard_arrow_up,
                                ),
                                _buildInfoRow(
                                  'Gasto Menor',
                                  _expenses.isEmpty ? '\$0.00' : '\$${_expenses.map((e) => e.gasto).reduce((a, b) => a < b ? a : b).toStringAsFixed(2)}',
                                  Icons.keyboard_arrow_down,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        // Gastos recientes
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gastos Recientes',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                SizedBox(height: 16),
                                if (_expenses.isEmpty)
                                  Text('No hay gastos registrados')
                                else
                                  ..._expenses.take(5).map((expense) => ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: expense.tipoPago == 'credito' 
                                          ? Colors.orange : Colors.red,
                                      child: Icon(
                                        expense.tipoPago == 'credito' 
                                            ? Icons.credit_card : Icons.money,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(expense.nombreGasto),
                                    subtitle: Text('${expense.fechaGasto.day}/${expense.fechaGasto.month}/${expense.fechaGasto.year}'),
                                    trailing: Text(
                                      '\$${expense.gasto.toStringAsFixed(2)}',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: color),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPercentageBar(String title, double value, double total, Color color) {
    final percentage = total > 0 ? (value / total) * 100 : 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text('${percentage.toStringAsFixed(1)}%'),
          ],
        ),
        SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String title, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(child: Text(title)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}