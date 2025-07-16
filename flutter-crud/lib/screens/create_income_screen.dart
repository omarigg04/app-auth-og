import 'package:flutter/material.dart';
import '../models/income.dart';
import '../services/income_service.dart';

class CreateIncomeScreen extends StatefulWidget {
  @override
  _CreateIncomeScreenState createState() => _CreateIncomeScreenState();
}

class _CreateIncomeScreenState extends State<CreateIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeService = IncomeService();
  
  final _nombreIngresoController = TextEditingController();
  final _montoController = TextEditingController();
  final _descripcionController = TextEditingController();
  
  String? _fuenteIngreso;
  DateTime _fechaIngreso = DateTime.now();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Ingreso'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nombre del ingreso
              TextFormField(
                controller: _nombreIngresoController,
                decoration: InputDecoration(
                  labelText: 'Nombre del ingreso',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del ingreso';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Monto
              TextFormField(
                controller: _montoController,
                decoration: InputDecoration(
                  labelText: 'Monto',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.monetization_on),
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
              
              // Fuente de ingreso
              DropdownButtonFormField<String>(
                value: _fuenteIngreso,
                decoration: InputDecoration(
                  labelText: 'Fuente de ingreso (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.source),
                ),
                items: IncomeSources.sources.map((source) => DropdownMenuItem(
                  value: source,
                  child: Row(
                    children: [
                      Text(IncomeSources.sourceIcons[source] ?? '📊'),
                      SizedBox(width: 8),
                      Text(source),
                    ],
                  ),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _fuenteIngreso = value;
                  });
                },
              ),
              SizedBox(height: 16),
              
              // Fecha
              InkWell(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _fechaIngreso,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null && picked != _fechaIngreso) {
                    setState(() {
                      _fechaIngreso = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Fecha del ingreso',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_fechaIngreso.day}/${_fechaIngreso.month}/${_fechaIngreso.year}',
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
                  onPressed: _isLoading ? null : _createIncome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Crear Ingreso'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createIncome() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final createIncomeDto = CreateIncomeDto(
      nombreIngreso: _nombreIngresoController.text,
      monto: double.parse(_montoController.text),
      fuenteIngreso: _fuenteIngreso,
      descripcion: _descripcionController.text.isEmpty ? null : _descripcionController.text,
      fechaIngreso: _fechaIngreso,
    );

    final result = await _incomeService.createIncome(createIncomeDto);

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ingreso creado correctamente'),
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
    _nombreIngresoController.dispose();
    _montoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }
}