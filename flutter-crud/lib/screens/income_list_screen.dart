import 'package:flutter/material.dart';
import '../models/income.dart';
import '../services/income_service.dart';
import '../services/auth_service.dart';
import 'create_income_screen.dart';
import 'edit_income_screen.dart';
import 'login_screen.dart';

class IncomeListScreen extends StatefulWidget {
  @override
  _IncomeListScreenState createState() => _IncomeListScreenState();
}

class _IncomeListScreenState extends State<IncomeListScreen> {
  final IncomeService _incomeService = IncomeService();
  final AuthService _authService = AuthService();
  List<Income> _incomes = [];
  bool _isLoading = true;
  String _filterSource = 'all';

  @override
  void initState() {
    super.initState();
    _loadIncomes();
  }

  Future<void> _loadIncomes() async {
    setState(() => _isLoading = true);
    
    final result = await _incomeService.getMyIncomes();
    
    if (result['success']) {
      setState(() {
        _incomes = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  Future<void> _deleteIncome(int id) async {
    final result = await _incomeService.deleteIncome(id);
    
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ingreso eliminado correctamente')),
      );
      _loadIncomes();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
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

  List<Income> get _filteredIncomes {
    if (_filterSource == 'all') return _incomes;
    return _incomeService.filterIncomesBySource(_incomes, _filterSource);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    
    return Scaffold(
      backgroundColor: Color(0xFFFAFBFC),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Column(
                    children: [
                      _buildFilterSection(),
                      Expanded(
                        child: _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : _filteredIncomes.isEmpty
                                ? _buildEmptyState()
                                : _buildIncomesList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      drawer: isDesktop ? null : _buildDrawer(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: Color(0xFF2C3E50),
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
                Icon(Icons.attach_money, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Text(
                  'Ingresos',
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
                _buildSidebarItem(Icons.dashboard, 'Dashboard', false, () {
                  Navigator.pop(context);
                }),
                _buildSidebarItem(Icons.attach_money, 'Ingresos', true),
                _buildSidebarItem(Icons.shopping_cart, 'Gastos', false, () {
                  Navigator.pop(context);
                }),
                _buildSidebarItem(Icons.bar_chart, 'Estadísticas', false),
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
                Icon(Icons.attach_money, color: Colors.white, size: 32),
                SizedBox(width: 12),
                Text(
                  'Ingresos',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.attach_money, color: Color(0xFFB8E6B8)),
            title: Text('Ingresos', style: TextStyle(color: Color(0xFFB8E6B8))),
          ),
          ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Gastos'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Estadísticas'),
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
              'Mis Ingresos',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
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
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.all(24),
      margin: EdgeInsets.all(24),
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
      child: Row(
        children: [
          Text(
            'Filtrar por fuente: ',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3E50),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFFE1E8ED)),
              ),
              child: DropdownButton<String>(
                value: _filterSource,
                underline: SizedBox(),
                isExpanded: true,
                onChanged: (value) {
                  setState(() => _filterSource = value!);
                },
                items: [
                  DropdownMenuItem(value: 'all', child: Text('Todos')),
                  ...IncomeSources.sources.map((source) => DropdownMenuItem(
                    value: source,
                    child: Row(
                      children: [
                        Text(IncomeSources.sourceIcons[source] ?? '📊'),
                        SizedBox(width: 8),
                        Text(source),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFFB8E6B8).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(Icons.attach_money, size: 64, color: Color(0xFFB8E6B8)),
            ),
            SizedBox(height: 24),
            Text(
              'No tienes ingresos registrados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C3E50),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Comienza registrando tu primer ingreso',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateIncomeScreen()),
                );
                _loadIncomes();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFB8E6B8),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Crear primer ingreso',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomesList() {
    return RefreshIndicator(
      onRefresh: _loadIncomes,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24),
        itemCount: _filteredIncomes.length,
        itemBuilder: (context, index) {
          final income = _filteredIncomes[index];
          final sourceIcon = IncomeSources.sourceIcons[income.fuenteIngreso] ?? '📊';
          
          return Container(
            margin: EdgeInsets.only(bottom: 16),
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
            child: ListTile(
              contentPadding: EdgeInsets.all(20),
              leading: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFFB8E6B8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  sourceIcon,
                  style: TextStyle(fontSize: 24),
                ),
              ),
              title: Text(
                income.nombreIngreso,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (income.fuenteIngreso != null)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFFB8E6B8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${income.fuenteIngreso}',
                          style: TextStyle(
                            color: Color(0xFFB8E6B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (income.descripcion != null)
                    Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        income.descripcion!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      '${income.fechaIngreso.day}/${income.fechaIngreso.month}/${income.fechaIngreso.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '+\$${income.monto.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFB8E6B8),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFFB8E6B8).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'INGRESO',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB8E6B8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditIncomeScreen(income: income),
                          ),
                        );
                        _loadIncomes();
                      } else if (value == 'delete') {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            title: Text('Confirmar eliminación'),
                            content: Text('¿Estás seguro de que quieres eliminar este ingreso?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteIncome(income.id);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFFFB3BA),
                                ),
                                child: Text('Eliminar'),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Color(0xFF2C3E50)),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Color(0xFFFFB3BA)),
                            SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: Color(0xFFFFB3BA)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0xFFB8E6B8).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateIncomeScreen()),
          );
          _loadIncomes();
        },
        backgroundColor: Color(0xFFB8E6B8),
        elevation: 0,
        child: Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _oldBuild(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Ingresos'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [];
      ),
      body: Container(),
    );
  }
}