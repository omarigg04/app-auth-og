import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class CreateExpenseScreen extends StatefulWidget {
  @override
  _CreateExpenseScreenState createState() => _CreateExpenseScreenState();
}

class _CreateExpenseScreenState extends State<CreateExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _expenseService = ExpenseService();
  
  final _nombreGastoController = TextEditingController();
  final _gastoController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  String _tipoPago = 'efectivo';
  DateTime _fechaGasto = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Gasto'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nombre del gasto
              TextFormField(
                controller: _nombreGastoController,
                decoration: InputDecoration(
                  labelText: 'Nombre del gasto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.shopping_cart),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del gasto';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Monto
              TextFormField(
                controller: _gastoController,
                decoration: InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el monto';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Por favor ingresa un número válido';
                  }
                  if (double.parse(value) <= 0) {
                    return 'El monto debe ser mayor a 0';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Tipo de pago
              DropdownButtonFormField<String>(
                value: _tipoPago,
                decoration: InputDecoration(
                  labelText: 'Tipo de pago',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.payment),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'efectivo',
                    child: Row(
                      children: [
                        Icon(Icons.money, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Efectivo'),
                      ],
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'credito',
                    child: Row(
                      children: [
                        Icon(Icons.credit_card, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Crédito'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipoPago = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              
              // Fecha
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _fechaGasto,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != _fechaGasto) {
                    setState(() {
                      _fechaGasto = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha del gasto',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_fechaGasto.day}/${_fechaGasto.month}/${_fechaGasto.year}',
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              // Descripción
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              
              // Botón crear
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Crear Gasto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final createExpenseDto = CreateExpenseDto(
      nombreGasto: _nombreGastoController.text,
      gasto: double.parse(_gastoController.text),
      tipoPago: _tipoPago,
      descripcion: _descripcionController.text.isEmpty ? null : _descripcionController.text,
      fechaGasto: _fechaGasto,
    );

    final result = await _expenseService.createExpense(createExpenseDto);

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gasto creado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nombreGastoController.dispose();
    _gastoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}