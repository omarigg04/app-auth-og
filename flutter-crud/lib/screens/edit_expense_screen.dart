import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';

class EditExpenseScreen extends StatefulWidget {
  final Expense expense;

  EditExpenseScreen({required this.expense});

  @override
  _EditExpenseScreenState createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _expenseService = ExpenseService();
  
  late final TextEditingController _nombreGastoController;
  late final TextEditingController _gastoController;
  late final TextEditingController _descripcionController;
  
  late String _tipoPago;
  late DateTime _fechaGasto;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreGastoController = TextEditingController(text: widget.expense.nombreGasto);
    _gastoController = TextEditingController(text: widget.expense.gasto.toString());
    _descripcionController = TextEditingController(text: widget.expense.descripcion ?? '');
    _tipoPago = widget.expense.tipoPago;
    _fechaGasto = widget.expense.fechaGasto;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Gasto'),
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
              
              // Botón actualizar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateExpense,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Actualizar Gasto'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updateExpenseDto = UpdateExpenseDto(
      nombreGasto: _nombreGastoController.text != widget.expense.nombreGasto 
          ? _nombreGastoController.text : null,
      gasto: double.parse(_gastoController.text) != widget.expense.gasto 
          ? double.parse(_gastoController.text) : null,
      tipoPago: _tipoPago != widget.expense.tipoPago ? _tipoPago : null,
      descripcion: _descripcionController.text != (widget.expense.descripcion ?? '') 
          ? (_descripcionController.text.isEmpty ? null : _descripcionController.text) : null,
      fechaGasto: _fechaGasto != widget.expense.fechaGasto ? _fechaGasto : null,
    );

    final result = await _expenseService.updateExpense(widget.expense.id, updateExpenseDto);

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gasto actualizado correctamente'),
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