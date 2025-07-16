import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../services/expense_service.dart';
import '../services/income_service.dart';
import '../services/auth_service.dart';
import 'expense_list_screen.dart';
import 'income_list_screen.dart';
import 'expense_stats_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final IncomeService _incomeService = IncomeService();
  final AuthService _authService = AuthService();
  
  ExpenseStats? _expenseStats;
  IncomeStats? _incomeStats;
  List<Expense> _recentExpenses = [];
  List<Income> _recentIncomes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      // Cargar estadísticas de gastos
      final expenseStatsResult = await _expenseService.getMyStats();
      if (expenseStatsResult['success']) {
        _expenseStats = expenseStatsResult['data'];
      }

      // Cargar estadísticas de ingresos
      final incomeStatsResult = await _incomeService.getMyStats();
      if (incomeStatsResult['success']) {
        _incomeStats = incomeStatsResult['data'];
      }

      // Cargar gastos recientes
      final expensesResult = await _expenseService.getMyExpenses();
      if (expensesResult['success']) {
        _recentExpenses = (expensesResult['data'] as List<Expense>).take(5).toList();
      }

      // Cargar ingresos recientes
      final incomesResult = await _incomeService.getMyIncomes();
      if (incomesResult['success']) {
        _recentIncomes = (incomesResult['data'] as List<Income>).take(5).toList();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: $e')),
      );
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Resumen financiero
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Resumen Financiero',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildFinancialSummaryCard(
                                    'Ingresos',
                                    '+\$${_incomeStats?.total.toStringAsFixed(2) ?? '0.00'}',
                                    Colors.green,
                                    Icons.trending_up,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: _buildFinancialSummaryCard(
                                    'Gastos',
                                    '-\$${_expenseStats?.total.toStringAsFixed(2) ?? '0.00'}',
                                    Colors.red,
                                    Icons.trending_down,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Center(
                              child: _buildFinancialSummaryCard(
                                'Balance',
                                '\$${((_incomeStats?.total ?? 0) - (_expenseStats?.total ?? 0)).toStringAsFixed(2)}',
                                ((_incomeStats?.total ?? 0) - (_expenseStats?.total ?? 0)) >= 0 
                                    ? Colors.green : Colors.red,
                                Icons.account_balance_wallet,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Acciones rápidas
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Acciones Rápidas',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildActionCard(
                                    'Ingresos',
                                    Icons.attach_money,
                                    Colors.green,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => IncomeListScreen()),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: _buildActionCard(
                                    'Gastos',
                                    Icons.shopping_cart,
                                    Colors.orange,
                                    () => Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ExpenseListScreen()),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Center(
                              child: _buildActionCard(
                                'Estadísticas',
                                Icons.bar_chart,
                                Colors.blue,
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => ExpenseStatsScreen()),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Actividad reciente
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Actividad Reciente',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            SizedBox(height: 16),
                            
                            // Ingresos recientes
                            if (_recentIncomes.isNotEmpty) ...[
                              Text(
                                'Ingresos Recientes',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              SizedBox(height: 8),
                              ..._recentIncomes.map((income) => ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.add, color: Colors.white),
                                ),
                                title: Text(income.nombreIngreso),
                                subtitle: Text('${income.fechaIngreso.day}/${income.fechaIngreso.month}/${income.fechaIngreso.year}'),
                                trailing: Text(
                                  '+\$${income.monto.toStringAsFixed(2)}',
                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              )),
                              SizedBox(height: 16),
                            ],
                            
                            // Gastos recientes
                            if (_recentExpenses.isNotEmpty) ...[
                              Text(
                                'Gastos Recientes',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                              SizedBox(height: 8),
                              ..._recentExpenses.map((expense) => ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: expense.tipoPago == 'credito' ? Colors.orange : Colors.red,
                                  child: Icon(
                                    expense.tipoPago == 'credito' ? Icons.credit_card : Icons.money,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(expense.nombreGasto),
                                subtitle: Text('${expense.fechaGasto.day}/${expense.fechaGasto.month}/${expense.fechaGasto.year}'),
                                trailing: Text(
                                  '-\$${expense.gasto.toStringAsFixed(2)}',
                                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              )),
                            ],
                            
                            if (_recentIncomes.isEmpty && _recentExpenses.isEmpty)
                              Center(
                                child: Text(
                                  'No hay actividad reciente',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
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

  Widget _buildFinancialSummaryCard(String title, String amount, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}