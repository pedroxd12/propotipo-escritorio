// lib/data/models/client_model.dart

class Cliente {
  final String id;
  final String empresaId;
  final String nombreCuenta;
  final String telefonoPrincipal;
  final String emailFacturacion;
  final bool activo;
  final List<Direccion> direcciones;

  Cliente({
    required this.id,
    required this.empresaId,
    required this.nombreCuenta,
    required this.telefonoPrincipal,
    required this.emailFacturacion,
    this.activo = true,
    this.direcciones = const [],
  });

  // --- MÉTODO AÑADIDO ---
  // Facilita la creación de una copia del cliente con datos actualizados.
  Cliente copyWith({
    String? id,
    String? empresaId,
    String? nombreCuenta,
    String? telefonoPrincipal,
    String? emailFacturacion,
    bool? activo,
    List<Direccion>? direcciones,
  }) {
    return Cliente(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      nombreCuenta: nombreCuenta ?? this.nombreCuenta,
      telefonoPrincipal: telefonoPrincipal ?? this.telefonoPrincipal,
      emailFacturacion: emailFacturacion ?? this.emailFacturacion,
      activo: activo ?? this.activo,
      direcciones: direcciones ?? this.direcciones,
    );
  }
}

class Direccion {
  final String id;
  final String calleYNumero;
  final String colonia;
  final String codigoPostal;
  final String municipio;
  final String estado;
  final String? referencias;
  // --- CAMPOS AÑADIDOS ---
  final double latitud;
  final double longitud;

  Direccion({
    required this.id,
    required this.calleYNumero,
    required this.colonia,
    required this.codigoPostal,
    required this.municipio,
    required this.estado,
    this.referencias,
    // --- CAMPOS AÑADIDOS AL CONSTRUCTOR ---
    required this.latitud,
    required this.longitud,
  });

  @override
  String toString() {
    return '$calleYNumero, $colonia, $municipio, $estado, C.P. $codigoPostal';
  }
}