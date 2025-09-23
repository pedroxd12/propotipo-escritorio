// lib/data/repositories/technician_repository.dart
import 'package:serviceflow/data/models/technician_model.dart';

class TechnicianRepository {
  // En una aplicación real, esta lista estaría vacía y los datos se obtendrían de una API.
  // Por ahora, usamos los datos de ejemplo que tenías.
  final List<Technician> _technicians = [
    Technician(
      id: '1',
      nombre: 'Carlos',
      apellidoPaterno: 'Sánchez',
      apellidoMaterno: 'Ramírez',
      correo: 'carlos@example.com',
      telefono: '312-000-1111',
      especialidad: 'Climatización',
      habilidades: ['Instalación', 'Mantenimiento'],
      serviciosRealizados: ['22101', '33104'],
    ),
    Technician(
      id: '2',
      nombre: 'María',
      apellidoPaterno: 'Gómez',
      apellidoMaterno: 'Luna',
      correo: 'maria@example.com',
      telefono: '312-000-2222',
      especialidad: 'Paneles Solares',
      habilidades: ['Mantenimiento', 'Reparación'],
      serviciosRealizados: ['22203'],
    ),
  ];

  /// Obtiene la lista completa de técnicos.
  /// En el futuro, aquí se haría la llamada a la API (ej: GET /api/technicians).
  Future<List<Technician>> getTechnicians() async {
    // Simula un pequeño retraso de red para imitar una llamada a API.
    await Future.delayed(const Duration(milliseconds: 400));
    return _technicians;
  }

  /// Añade un nuevo técnico a la lista.
  /// En el futuro, aquí se haría la llamada a la API (ej: POST /api/technicians).
  Future<Technician> addTechnician(Technician newTechnician) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // En la simulación, creamos un nuevo ID. En una app real, la API devolvería el objeto completo.
    final technicianToAdd = Technician(
      id: 'T${_technicians.length + 1}',
      nombre: newTechnician.nombre,
      apellidoPaterno: newTechnician.apellidoPaterno,
      apellidoMaterno: newTechnician.apellidoMaterno,
      correo: newTechnician.correo,
      telefono: newTechnician.telefono,
      especialidad: newTechnician.especialidad,
      habilidades: newTechnician.habilidades,
      serviciosRealizados: [], // Empieza sin servicios
    );
    _technicians.add(technicianToAdd);
    return technicianToAdd;
  }
}