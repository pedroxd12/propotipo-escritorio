// lib/data/repositories/technician_repository.dart
import 'package:serviceflow/data/models/usuario_model.dart';

class TechnicianRepository {
  final List<Usuario> _technicians = [
    Usuario(
        id: 'user-2',
        empresaId: 'emp-1',
        nombres: 'Carlos',
        apellidoPaterno: 'Sánchez',
        email: 'carlos@example.com',
        telefono: '312-000-1111',
        rol: 'Tecnico',
        perfilTecnico: TecnicoPerfil(
          especialidad: 'Climatización',
          habilidades: [
            Habilidad(id: 'hab-1', nombre: 'Instalación'),
            Habilidad(id: 'hab-2', nombre: 'Mantenimiento Preventivo')
          ],
        )),
    Usuario(
        id: 'user-3',
        empresaId: 'emp-1',
        nombres: 'María',
        apellidoPaterno: 'Gómez',
        email: 'maria@example.com',
        telefono: '312-000-2222',
        rol: 'Tecnico',
        perfilTecnico: TecnicoPerfil(
          especialidad: 'Paneles Solares',
          habilidades: [
            Habilidad(id: 'hab-2', nombre: 'Mantenimiento Preventivo'),
            Habilidad(id: 'hab-3', nombre: 'Reparación de Inversores')
          ],
        )),
  ];

  Future<List<Usuario>> getTechnicians() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _technicians.where((u) => u.rol == 'Tecnico').toList();
  }

  Future<Usuario> addTechnician(Usuario newTechnician) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final technicianToAdd = Usuario(
      id: 'user-${_technicians.length + 2}',
      empresaId: newTechnician.empresaId,
      nombres: newTechnician.nombres,
      apellidoPaterno: newTechnician.apellidoPaterno,
      email: newTechnician.email,
      telefono: newTechnician.telefono,
      rol: 'Tecnico',
      perfilTecnico: newTechnician.perfilTecnico,
    );
    _technicians.add(technicianToAdd);
    return technicianToAdd;
  }
}