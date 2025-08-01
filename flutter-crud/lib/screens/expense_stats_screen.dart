import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';
import '../models/income.dart';
import '../services/expense_service.dart';
import '../services/income_service.dart';

class ExpenseStatsScreen extends StatefulWidget {
  @override
  _ExpenseStatsScreenState createState() => _ExpenseStatsScreenState();
}

class _ExpenseStatsScreenState extends State<ExpenseStatsScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final IncomeService _incomeService = IncomeService();
  ExpenseStats? _stats;
  List<Expense> _expenses = [];
  List<Income> _incomes = [];
  bool _isLoading = true;
  
  DateTime _startDate = DateTime.now().subtract(Duration(days: 30));
  DateTime _endDate = DateTime.now();
  String _selectedPeriod = '30 días';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final statsResult = await _expenseService.getMyStats();
    final expensesResult = await _expenseService.getMyExpenses();
    final incomesResult = await _incomeService.getMyIncomes();
    
    if (statsResult['success'] && expensesResult['success'] && incomesResult['success']) {
      setState(() {
        _stats = statsResult['data'];
        _expenses = expensesResult['data'];
        _incomes = incomesResult['data'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar estadísticas')),
      );
    }
  }

  void _updateDateRange(String period) {
    final now = DateTime.now();
    setState(() {
      _selectedPeriod = period;
      switch (period) {
        case '7 días':
          _startDate = now.subtract(Duration(days: 7));
          _endDate = now;
          break;
        case '30 días':
          _startDate = now.subtract(Duration(days: 30));
          _endDate = now;
          break;
        case '90 días':
          _startDate = now.subtract(Duration(days: 90));
          _endDate = now;
          break;
        case 'Este mes':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = DateTime(now.year, now.month + 1, 0);
          break;
        case 'Este año':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = DateTime(now.year, 12, 31);
          break;
      }
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDialog<DateTimeRange>(
      context: context,
      builder: (BuildContext context) {
        return _DateRangePickerDialog(
          initialStartDate: _startDate,
          initialEndDate: _endDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedPeriod = 'Personalizado';
      });
      _loadData(); // Recargar datos con el nuevo rango
    }
  }

  List<Expense> _getFilteredExpenses() {
    return _expenseService.filterExpensesByDate(_expenses, _startDate, _endDate);
  }

  List<Income> _getFilteredIncomes() {
    return _incomeService.filterIncomesByDate(_incomes, _startDate, _endDate);
  }

  Map<String, Map<String, double>> _getChartData() {
    final filteredExpenses = _getFilteredExpenses();
    final filteredIncomes = _getFilteredIncomes();
    
    Map<String, Map<String, double>> chartData = {};
    
    // Procesar gastos
    for (var expense in filteredExpenses) {
      final dateKey = '${expense.fechaGasto.day}/${expense.fechaGasto.month}';
      if (!chartData.containsKey(dateKey)) {
        chartData[dateKey] = {'expenses': 0, 'incomes': 0};
      }
      chartData[dateKey]!['expenses'] = (chartData[dateKey]!['expenses'] ?? 0) + expense.gasto;
    }
    
    // Procesar ingresos
    for (var income in filteredIncomes) {
      final dateKey = '${income.fechaIngreso.day}/${income.fechaIngreso.month}';
      if (!chartData.containsKey(dateKey)) {
        chartData[dateKey] = {'expenses': 0, 'incomes': 0};
      }
      chartData[dateKey]!['incomes'] = (chartData[dateKey]!['incomes'] ?? 0) + income.monto;
    }
    
    return chartData;
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
                        // Filtros de fecha
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Filtros de Fecha',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    '7 días',
                                    '30 días', 
                                    '90 días',
                                    'Este mes',
                                    'Este año'
                                  ].map((period) => FilterChip(
                                    label: Text(period),
                                    selected: _selectedPeriod == period,
                                    onSelected: (selected) {
                                      if (selected) _updateDateRange(period);
                                    },
                                  )).toList(),
                                ),
                                SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Desde',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Hasta',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: IconButton(
                                        icon: Icon(Icons.calendar_today, color: Colors.white),
                                        onPressed: _selectDateRange,
                                        tooltip: 'Seleccionar fechas personalizadas',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        
                        // Gráfica de barras
                        Card(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Gastos vs Ingresos por Día',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                SizedBox(height: 16),
                                SizedBox(
                                  height: 300,
                                  child: _buildBarChart(),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        
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

  Widget _buildBarChart() {
    final chartData = _getChartData();
    
    if (chartData.isEmpty) {
      return Center(
        child: Text(
          'No hay datos para mostrar en el período seleccionado',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }
    
    final sortedKeys = chartData.keys.toList()..sort((a, b) {
      final aParts = a.split('/');
      final bParts = b.split('/');
      final aDate = DateTime(DateTime.now().year, int.parse(aParts[1]), int.parse(aParts[0]));
      final bDate = DateTime(DateTime.now().year, int.parse(bParts[1]), int.parse(bParts[0]));
      return aDate.compareTo(bDate);
    });
    
    List<BarChartGroupData> barGroups = [];
    
    for (int i = 0; i < sortedKeys.length; i++) {
      final key = sortedKeys[i];
      final data = chartData[key]!;
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: data['expenses']!,
              color: Colors.red,
              width: 12,
              borderRadius: BorderRadius.circular(4),
            ),
            BarChartRodData(
              toY: data['incomes']!,
              color: Colors.green,
              width: 12,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        // Leyenda
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 16,
              color: Colors.red,
            ),
            SizedBox(width: 4),
            Text('Gastos'),
            SizedBox(width: 16),
            Container(
              width: 16,
              height: 16,
              color: Colors.green,
            ),
            SizedBox(width: 4),
            Text('Ingresos'),
          ],
        ),
        SizedBox(height: 16),
        Expanded(
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxValue(chartData) * 1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final key = sortedKeys[group.x];
                    final isExpense = rodIndex == 0;
                    return BarTooltipItem(
                      '$key\n${isExpense ? 'Gastos' : 'Ingresos'}: \$${rod.toY.toStringAsFixed(2)}',
                      TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      if (value.toInt() < sortedKeys.length) {
                        return Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            sortedKeys[value.toInt()],
                            style: TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 60,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      return Text(
                        '\$${value.toStringAsFixed(0)}',
                        style: TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              barGroups: barGroups,
            ),
          ),
        ),
      ],
    );
  }
  
  double _getMaxValue(Map<String, Map<String, double>> chartData) {
    double max = 0;
    for (var data in chartData.values) {
      final expenseValue = data['expenses'] ?? 0;
      final incomeValue = data['incomes'] ?? 0;
      if (expenseValue > max) max = expenseValue;
      if (incomeValue > max) max = incomeValue;
    }
    return max == 0 ? 100 : max;
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

class _DateRangePickerDialog extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _DateRangePickerDialog({
    required this.initialStartDate,
    required this.initialEndDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  _DateRangePickerDialogState createState() => _DateRangePickerDialogState();
}

class _DateRangePickerDialogState extends State<_DateRangePickerDialog> {
  late DateTime _startDate;
  late DateTime _endDate;
  late DateTime _displayedMonth;
  bool _isSelectingStart = true;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    _displayedMonth = DateTime(_startDate.year, _startDate.month);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seleccionar rango de fechas',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Date selection buttons
            Row(
              children: [
                Expanded(
                  child: _buildDateButton(
                    'Fecha inicio',
                    _startDate,
                    _isSelectingStart,
                    () => setState(() => _isSelectingStart = true),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: _buildDateButton(
                    'Fecha fin',
                    _endDate,
                    !_isSelectingStart,
                    () => setState(() => _isSelectingStart = false),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Quick selection buttons
            Wrap(
              spacing: 8,
              children: [
                _buildQuickButton('Últimos 7 días', 7),
                _buildQuickButton('Últimos 30 días', 30),
                _buildQuickButton('Últimos 90 días', 90),
                _buildQuickButton('Este mes', 0),
              ],
            ),
            SizedBox(height: 16),
            
            // Calendar header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
                    });
                  },
                ),
                Text(
                  _getMonthYearString(_displayedMonth),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
                    });
                  },
                ),
              ],
            ),
            
            // Calendar grid
            _buildCalendarGrid(),
            
            SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _startDate.isBefore(_endDate) || _startDate.isAtSameMomentAs(_endDate)
                      ? () => Navigator.of(context).pop(DateTimeRange(start: _startDate, end: _endDate))
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Aplicar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateButton(String label, DateTime date, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange.withOpacity(0.1) : Colors.grey[100],
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey[300]!,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.orange : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '${date.day}/${date.month}/${date.year}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.orange : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(String label, int days) {
    return ElevatedButton(
      onPressed: () {
        final now = DateTime.now();
        setState(() {
          if (days == 0) {
            // Este mes
            _startDate = DateTime(now.year, now.month, 1);
            _endDate = DateTime(now.year, now.month + 1, 0);
          } else {
            _startDate = now.subtract(Duration(days: days));
            _endDate = now;
          }
          _displayedMonth = DateTime(_startDate.year, _startDate.month);
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      child: Text(label, style: TextStyle(fontSize: 12)),
    );
  }

  Widget _buildCalendarGrid() {
    return Container(
      height: 300,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          childAspectRatio: 1,
        ),
        itemCount: 42, // 6 semanas * 7 días
        itemBuilder: (context, index) {
          final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
          final firstDayWeekday = firstDayOfMonth.weekday % 7;
          
          if (index < 7) {
            // Header con días de la semana
            final weekdays = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
            return Container(
              alignment: Alignment.center,
              child: Text(
                weekdays[index],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            );
          }
          
          final dayIndex = index - 7;
          final day = dayIndex - firstDayWeekday + 1;
          
          if (day <= 0 || day > _daysInMonth(_displayedMonth)) {
            return Container();
          }
          
          final currentDate = DateTime(_displayedMonth.year, _displayedMonth.month, day);
          final isInRange = _isDateInRange(currentDate);
          final isStartDate = _isSameDay(currentDate, _startDate);
          final isEndDate = _isSameDay(currentDate, _endDate);
          final isToday = _isSameDay(currentDate, DateTime.now());
          
          return GestureDetector(
            onTap: () {
              if (currentDate.isBefore(widget.firstDate) || currentDate.isAfter(widget.lastDate)) {
                return;
              }
              
              setState(() {
                if (_isSelectingStart) {
                  _startDate = currentDate;
                  if (_startDate.isAfter(_endDate)) {
                    _endDate = _startDate;
                  }
                  _isSelectingStart = false;
                } else {
                  _endDate = currentDate;
                  if (_endDate.isBefore(_startDate)) {
                    _startDate = _endDate;
                  }
                }
              });
            },
            child: Container(
              margin: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: isStartDate || isEndDate
                    ? Colors.orange
                    : isInRange
                        ? Colors.orange.withOpacity(0.3)
                        : isToday
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isToday ? Border.all(color: Colors.orange, width: 1) : null,
              ),
              alignment: Alignment.center,
              child: Text(
                day.toString(),
                style: TextStyle(
                  color: isStartDate || isEndDate
                      ? Colors.white
                      : currentDate.isBefore(widget.firstDate) || currentDate.isAfter(widget.lastDate)
                          ? Colors.grey[400]
                          : Colors.black87,
                  fontWeight: isStartDate || isEndDate || isToday
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isDateInRange(DateTime date) {
    return (date.isAfter(_startDate) || _isSameDay(date, _startDate)) &&
           (date.isBefore(_endDate) || _isSameDay(date, _endDate));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }

  int _daysInMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0).day;
  }

  String _getMonthYearString(DateTime date) {
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}