// lib/data/models/technician_model.dart
class Technician {
  final String id;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String telefono;
  final String especialidad;
  final List<String> habilidades;
  final List<String> serviciosRealizados;

  Technician({
    required this.id,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.telefono,
    required this.especialidad,
    required this.habilidades,
    required this.serviciosRealizados,
  });

  /// Combina el nombre y los apellidos para una fácil visualización.
  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';
}