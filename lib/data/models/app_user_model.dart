
class AppUser {
  final String id;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String telefono;

  AppUser({
    required this.id,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.telefono,
  });

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';
}