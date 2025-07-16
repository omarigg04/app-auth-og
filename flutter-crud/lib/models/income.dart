class Income {
  final int id;
  final int userId;
  final String nombreIngreso;
  final double monto;
  final String? fuenteIngreso;
  final String? descripcion;
  final DateTime fechaIngreso;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Income({
    required this.id,
    required this.userId,
    required this.nombreIngreso,
    required this.monto,
    this.fuenteIngreso,
    this.descripcion,
    required this.fechaIngreso,
    this.createdAt,
    this.updatedAt,
  });

  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      userId: json['user_id'],
      nombreIngreso: json['nombre_ingreso'],
      monto: double.parse(json['monto'].toString()),
      fuenteIngreso: json['fuente_ingreso'],
      descripcion: json['descripcion'],
      fechaIngreso: DateTime.parse(json['fecha_ingreso']),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nombre_ingreso': nombreIngreso,
      'monto': monto,
      'fuente_ingreso': fuenteIngreso,
      'descripcion': descripcion,
      'fecha_ingreso': fechaIngreso.toIso8601String().split('T')[0], // Solo fecha YYYY-MM-DD
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class CreateIncomeDto {
  final String nombreIngreso;
  final double monto;
  final String? fuenteIngreso;
  final String? descripcion;
  final DateTime fechaIngreso;

  CreateIncomeDto({
    required this.nombreIngreso,
    required this.monto,
    this.fuenteIngreso,
    this.descripcion,
    required this.fechaIngreso,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre_ingreso': nombreIngreso,
      'monto': monto,
      'fuente_ingreso': fuenteIngreso,
      'descripcion': descripcion,
      'fecha_ingreso': fechaIngreso.toIso8601String().split('T')[0],
    };
  }
}

class UpdateIncomeDto {
  final String? nombreIngreso;
  final double? monto;
  final String? fuenteIngreso;
  final String? descripcion;
  final DateTime? fechaIngreso;

  UpdateIncomeDto({
    this.nombreIngreso,
    this.monto,
    this.fuenteIngreso,
    this.descripcion,
    this.fechaIngreso,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (nombreIngreso != null) data['nombre_ingreso'] = nombreIngreso;
    if (monto != null) data['monto'] = monto;
    if (fuenteIngreso != null) data['fuente_ingreso'] = fuenteIngreso;
    if (descripcion != null) data['descripcion'] = descripcion;
    if (fechaIngreso != null) data['fecha_ingreso'] = fechaIngreso!.toIso8601String().split('T')[0];
    return data;
  }
}

class IncomeStats {
  final double total;
  final Map<String, double> porFuente;

  IncomeStats({
    required this.total,
    required this.porFuente,
  });

  factory IncomeStats.fromJson(Map<String, dynamic> json) {
    return IncomeStats(
      total: double.parse(json['total'].toString()),
      porFuente: (json['por_fuente'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, double.parse(value.toString())),
      ),
    );
  }
}

// Fuentes de ingreso predefinidas
class IncomeSources {
  static const List<String> sources = [
    'Salario',
    'Freelance',
    'Inversiones',
    'Negocio',
    'Bonificación',
    'Renta',
    'Venta',
    'Regalo',
    'Otros',
  ];

  static const Map<String, String> sourceIcons = {
    'Salario': '💼',
    'Freelance': '💻',
    'Inversiones': '📈',
    'Negocio': '🏢',
    'Bonificación': '🎁',
    'Renta': '🏠',
    'Venta': '💰',
    'Regalo': '🎉',
    'Otros': '📊',
  };
}