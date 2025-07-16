import 'package:flutter/material.dart';
import '../models/income.dart';
import '../services/income_service.dart';

class EditIncomeScreen extends StatefulWidget {
  final Income income;

  EditIncomeScreen({required this.income});

  @override
  _EditIncomeScreenState createState() => _EditIncomeScreenState();
}

class _EditIncomeScreenState extends State<EditIncomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeService = IncomeService();
  
  late final TextEditingController _nombreIngresoController;
  late final TextEditingController _montoController;
  late final TextEditingController _descripcionController;
  
  late String? _fuenteIngreso;
  late DateTime _fechaIngreso;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreIngresoController = TextEditingController(text: widget.income.nombreIngreso);
    _montoController = TextEditingController(text: widget.income.monto.toString());
    _descripcionController = TextEditingController(text: widget.income.descripcion ?? '');
    _fuenteIngreso = widget.income.fuenteIngreso;
    _fechaIngreso = widget.income.fechaIngreso;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Ingreso'),
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
                items: [
                  DropdownMenuItem(
                    value: null,
                    child: Text('Sin especificar'),
                  ),
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
              
              // Botón actualizar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateIncome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Actualizar Ingreso'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateIncome() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final updateIncomeDto = UpdateIncomeDto(
      nombreIngreso: _nombreIngresoController.text != widget.income.nombreIngreso 
          ? _nombreIngresoController.text : null,
      monto: double.parse(_montoController.text) != widget.income.monto 
          ? double.parse(_montoController.text) : null,
      fuenteIngreso: _fuenteIngreso != widget.income.fuenteIngreso ? _fuenteIngreso : null,
      descripcion: _descripcionController.text != (widget.income.descripcion ?? '') 
          ? (_descripcionController.text.isEmpty ? null : _descripcionController.text) : null,
      fechaIngreso: _fechaIngreso != widget.income.fechaIngreso ? _fechaIngreso : null,
    );

    final result = await _incomeService.updateIncome(widget.income.id, updateIncomeDto);

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ingreso actualizado correctamente'),
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