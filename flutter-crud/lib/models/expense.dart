class Expense {
  final int id;
  final int userId;
  final String nombreGasto;
  final double gasto;
  final String tipoPago;
  final String? descripcion;
  final DateTime fechaGasto;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Expense({
    required this.id,
    required this.userId,
    required this.nombreGasto,
    required this.gasto,
    required this.tipoPago,
    this.descripcion,
    required this.fechaGasto,
    this.createdAt,
    this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      userId: json['user_id'],
      nombreGasto: json['nombre_gasto'],
      gasto: double.parse(json['gasto'].toString()),
      tipoPago: json['tipo_pago'],
      descripcion: json['descripcion'],
      fechaGasto: DateTime.parse(json['fecha_gasto']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nombre_gasto': nombreGasto,
      'gasto': gasto,
      'tipo_pago': tipoPago,
      'descripcion': descripcion,
      'fecha_gasto': fechaGasto.toIso8601String().split('T')[0], // Solo fecha YYYY-MM-DD
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class CreateExpenseDto {
  final String nombreGasto;
  final double gasto;
  final String tipoPago;
  final String? descripcion;
  final DateTime fechaGasto;

  CreateExpenseDto({
    required this.nombreGasto,
    required this.gasto,
    required this.tipoPago,
    this.descripcion,
    required this.fechaGasto,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre_gasto': nombreGasto,
      'gasto': gasto,
      'tipo_pago': tipoPago,
      'descripcion': descripcion,
      'fecha_gasto': fechaGasto.toIso8601String().split('T')[0],
    };
  }
}

class UpdateExpenseDto {
  final String? nombreGasto;
  final double? gasto;
  final String? tipoPago;
  final String? descripcion;
  final DateTime? fechaGasto;

  UpdateExpenseDto({
    this.nombreGasto,
    this.gasto,
    this.tipoPago,
    this.descripcion,
    this.fechaGasto,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (nombreGasto != null) data['nombre_gasto'] = nombreGasto;
    if (gasto != null) data['gasto'] = gasto;
    if (tipoPago != null) data['tipo_pago'] = tipoPago;
    if (descripcion != null) data['descripcion'] = descripcion;
    if (fechaGasto != null) data['fecha_gasto'] = fechaGasto!.toIso8601String().split('T')[0];
    return data;
  }
}

class ExpenseStats {
  final double total;
  final double credito;
  final double efectivo;

  ExpenseStats({
    required this.total,
    required this.credito,
    required this.efectivo,
  });

  factory ExpenseStats.fromJson(Map<String, dynamic> json) {
    return ExpenseStats(
      total: double.parse(json['total'].toString()),
      credito: double.parse(json['credito'].toString()),
      efectivo: double.parse(json['efectivo'].toString()),
    );
  }
}