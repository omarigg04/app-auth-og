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
    final isDesktop = MediaQuery.of(context).size.width > 800;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: _isLoading
                      ? Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: _loadDashboardData,
                          child: SingleChildScrollView(
                            physics: AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildWelcomeCard(),
                                SizedBox(height: 24),
                                _buildStatsGrid(),
                                SizedBox(height: 24),
                                _buildQuickActionsGrid(),
                                SizedBox(height: 24),
                                _buildRecentActivity(),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: isDesktop ? null : _buildDrawer(),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C7B7F), Color(0xFF2C3E50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(Icons.dashboard, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Text(
                  'Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                _buildSidebarItem(Icons.dashboard, 'Dashboard', true),
                _buildSidebarItem(Icons.attach_money, 'Ingresos', false, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => IncomeListScreen()));
                }),
                _buildSidebarItem(Icons.shopping_cart, 'Gastos', false, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseListScreen()));
                }),
                _buildSidebarItem(Icons.bar_chart, 'Estadísticas', false, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseStatsScreen()));
                }),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16),
            child: _buildSidebarItem(Icons.logout, 'Cerrar Sesión', false, _logout),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String title, bool isActive, [VoidCallback? onTap]) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: isActive ? Color(0xFFB8E6B8) : Colors.white70),
        title: Text(
          title,
          style: TextStyle(
            color: isActive ? Color(0xFFB8E6B8) : Colors.white70,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        tileColor: isActive ? Colors.white.withOpacity(0.1) : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF2C3E50)),
            child: Row(
              children: [
                Icon(Icons.dashboard, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Text(
                  'Dashboard',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.attach_money),
            title: Text('Ingresos'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => IncomeListScreen())),
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Gastos'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseListScreen())),
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Estadísticas'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseStatsScreen())),
          ),
          Spacer(),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar Sesión'),
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (MediaQuery.of(context).size.width <= 800)
            Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          Expanded(
            child: Text(
              'Dashboard',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') _logout();
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
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF529aff), Color(0xFF3b7cdb)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFB8E6B8).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Bienvenido de vuelta!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Gestiona tus finanzas de manera inteligente',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.account_balance_wallet,
            color: Colors.white,
            size: 48,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final crossAxisCount = isDesktop ? 3 : 1;
    
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: isDesktop ? 1.5 : 3,
      children: [
        _buildModernStatsCard(
          'Ingresos Totales',
          '+\$${_incomeStats?.total.toStringAsFixed(2) ?? '0.00'}',
          Icons.trending_up,
          Color(0xFFB8E6B8),
          Color(0xFFA8D8A8),
        ),
        _buildModernStatsCard(
          'Gastos Totales',
          '-\$${_expenseStats?.total.toStringAsFixed(2) ?? '0.00'}',
          Icons.trending_down,
          Color(0xFFF4B183),
          Color(0xFFE09C6B),
        ),
        _buildModernStatsCard(
          'Balance',
          '\$${((_incomeStats?.total ?? 0) - (_expenseStats?.total ?? 0)).toStringAsFixed(2)}',
          Icons.account_balance_wallet,
          ((_incomeStats?.total ?? 0) - (_expenseStats?.total ?? 0)) >= 0 ? Color(0xFFB8E6B8) : Color(0xFFFFB3BA),
          ((_incomeStats?.total ?? 0) - (_expenseStats?.total ?? 0)) >= 0 ? Color(0xFFA8D8A8) : Color(0xFFFF9BA3),
        ),
      ],
    );
  }

  Widget _buildModernStatsCard(String title, String amount, IconData icon, Color startColor, Color endColor) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [startColor, endColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: startColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    final crossAxisCount = isDesktop ? 3 : 2;
    
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Acciones Rápidas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildModernActionCard(
                'Ingresos',
                Icons.attach_money,
                Color(0xFFB8E6B8),
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => IncomeListScreen())),
              ),
              _buildModernActionCard(
                'Gastos',
                Icons.shopping_cart,
                Color(0xFFF4B183),
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseListScreen())),
              ),
              _buildModernActionCard(
                'Estadísticas',
                Icons.bar_chart,
                Color(0xFFC8A8D8),
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => ExpenseStatsScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Actividad Reciente',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 20),
          
          if (_recentIncomes.isNotEmpty) ...[
            Text(
              'Ingresos Recientes',
              style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF27AE60), fontSize: 16),
            ),
            SizedBox(height: 12),
            ..._recentIncomes.map((income) => Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF27AE60).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(0xFF27AE60),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 16),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(income.nombreIngreso, style: TextStyle(fontWeight: FontWeight.w500)),
                        Text(
                          '${income.fechaIngreso.day}/${income.fechaIngreso.month}/${income.fechaIngreso.year}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '+\$${income.monto.toStringAsFixed(2)}',
                    style: TextStyle(color: Color(0xFF27AE60), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
            SizedBox(height: 16),
          ],
          
          if (_recentExpenses.isNotEmpty) ...[
            Text(
              'Gastos Recientes',
              style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFFE74C3C), fontSize: 16),
            ),
            SizedBox(height: 12),
            ..._recentExpenses.map((expense) => Container(
              margin: EdgeInsets.only(bottom: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFFE74C3C).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: expense.tipoPago == 'credito' ? Color(0xFFE67E22) : Color(0xFFE74C3C),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      expense.tipoPago == 'credito' ? Icons.credit_card : Icons.money,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(expense.nombreGasto, style: TextStyle(fontWeight: FontWeight.w500)),
                        Text(
                          '${expense.fechaGasto.day}/${expense.fechaGasto.month}/${expense.fechaGasto.year}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '-\$${expense.gasto.toStringAsFixed(2)}',
                    style: TextStyle(color: Color(0xFFE74C3C), fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )),
          ],
          
          if (_recentIncomes.isEmpty && _recentExpenses.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'No hay actividad reciente',
                      style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
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