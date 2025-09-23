// lib/data/models/client_model.dart
class Client {
  final String id;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String telefono;
  final String celular;
  final String rfc;
  final List<ClientAddress> direcciones;
  final List<String> serviciosRealizados;

  Client({
    required this.id,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.telefono,
    required this.celular,
    required this.rfc,
    required this.direcciones,
    required this.serviciosRealizados,
  });

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';
}

class ClientAddress {
  final String colonia;
  final String calle;
  final String numInt;
  final String numExt;
  final String codigoPostal;
  final String referencias;

  ClientAddress({
    required this.colonia,
    required this.calle,
    this.numInt = '',
    required this.numExt,
    required this.codigoPostal,
    this.referencias = '',
  });

  @override
  String toString() {
    return '$calle $numExt${numInt.isNotEmpty ? ', Int. $numInt' : ''}\n$colonia, C.P. $codigoPostal${referencias.isNotEmpty ? '\nRef: $referencias' : ''}';
  }
}