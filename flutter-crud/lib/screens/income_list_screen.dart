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
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Ingresos'),
        backgroundColor: Colors.green,
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
      body: Column(
        children: [
          // Filtros
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Text('Filtrar por fuente: '),
                SizedBox(width: 8),
                Expanded(
                  child: DropdownButton<String>(
                    value: _filterSource,
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
              ],
            ),
          ),
          // Lista de ingresos
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredIncomes.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.attach_money, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No tienes ingresos registrados'),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CreateIncomeScreen()),
                                );
                                _loadIncomes();
                              },
                              child: Text('Crear primer ingreso'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadIncomes,
                        child: ListView.builder(
                          itemCount: _filteredIncomes.length,
                          itemBuilder: (context, index) {
                            final income = _filteredIncomes[index];
                            final sourceIcon = IncomeSources.sourceIcons[income.fuenteIngreso] ?? '📊';
                            
                            return Card(
                              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Text(
                                    sourceIcon,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                title: Text(
                                  income.nombreIngreso,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (income.fuenteIngreso != null)
                                      Text('${income.fuenteIngreso}'),
                                    if (income.descripcion != null)
                                      Text(income.descripcion!, maxLines: 1, overflow: TextOverflow.ellipsis),
                                    Text(
                                      '${income.fechaIngreso.day}/${income.fechaIngreso.month}/${income.fechaIngreso.year}',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          '+\$${income.monto.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.green,
                                          ),
                                        ),
                                        Text(
                                          'INGRESO',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                    ),
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
                                              title: Text('Confirmar eliminación'),
                                              content: Text('¿Estás seguro de que quieres eliminar este ingreso?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.pop(context),
                                                  child: Text('Cancelar'),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                    _deleteIncome(income.id);
                                                  },
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
                                              Icon(Icons.edit),
                                              SizedBox(width: 8),
                                              Text('Editar'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Eliminar', style: TextStyle(color: Colors.red)),
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
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateIncomeScreen()),
          );
          _loadIncomes();
        },
        backgroundColor: Colors.green,
        child: Icon(Icons.add),
      ),
    );
  }
}