
class Usuario {
  final String id;
  final String empresaId;
  final String? clienteId;
  final String nombres;
  final String apellidoPaterno;
  final String email;
  final String telefono;
  final String rol; // 'Admin', 'Tecnico', 'Cliente'
  final bool activo;
  final String? fotoUrl;

  // Campos adicionales para tecnicos
  final TecnicoPerfil? perfilTecnico;

  Usuario({
    required this.id,
    required this.empresaId,
    this.clienteId,
    required this.nombres,
    required this.apellidoPaterno,
    required this.email,
    required this.telefono,
    required this.rol,
    this.activo = true,
    this.fotoUrl,
    this.perfilTecnico,
  });

  String get nombreCompleto => '$nombres $apellidoPaterno';
}

class TecnicoPerfil {
  final List<Habilidad> habilidades;
  final String especialidad; // Asumiendo que especialidad es un campo importante

  TecnicoPerfil({
    required this.habilidades,
    required this.especialidad,
  });
}

class Habilidad {
  final String id;
  final String nombre;

  Habilidad({required this.id, required this.nombre});
}