// lib/data/repositories/client_repository.dart
import 'package:serviceflow/data/models/client_model.dart';
import 'dart:math';

class ClientRepository {
  final List<Client> _clients = [
    Client(
      id: '1',
      nombre: 'Alondra',
      apellidoPaterno: 'Martinez',
      apellidoMaterno: 'Pino',
      correo: 'martinezpinoalondra@gmail.com',
      telefono: '555-1111',
      celular: '312-555-2222',
      rfc: 'MAPA800101XXX',
      direcciones: [
        ClientAddress(calle: 'Belisario Dominguez', numExt: '555', colonia: 'INFONAVIT', codigoPostal: '60950', referencias: 'Casa azul con portón blanco'),
        ClientAddress(calle: 'Av. Heroica Escuela Naval Militar', numExt: '39', colonia: 'Centro', codigoPostal: '60950', referencias: 'Frente al parque'),
      ],
      serviciosRealizados: ['15890', '156900', '157000'],
    ),
    // Puedes agregar más clientes de ejemplo si lo necesitas
  ];

  /// Obtiene la lista completa de clientes.
  Future<List<Client>> getClients() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _clients;
  }

  /// Añade un nuevo cliente a la lista.
  Future<Client> addClient(Client newClient) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Simula la creación de un ID único como lo haría una base de datos.
    final clientWithId = Client(
      id: (Random().nextInt(9000) + 1000).toString(), // ID aleatorio de 4 dígitos
      nombre: newClient.nombre,
      apellidoPaterno: newClient.apellidoPaterno,
      apellidoMaterno: newClient.apellidoMaterno,
      correo: newClient.correo,
      telefono: newClient.telefono,
      celular: newClient.celular,
      rfc: newClient.rfc,
      direcciones: newClient.direcciones,
      serviciosRealizados: [],
    );
    _clients.add(clientWithId);
    return clientWithId;
  }

  /// Actualiza un cliente existente.
  Future<Client> updateClient(Client updatedClient) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _clients.indexWhere((c) => c.id == updatedClient.id);
    if (index != -1) {
      _clients[index] = updatedClient;
      return updatedClient;
    }
    throw Exception('Client not found');
  }

  /// Elimina un cliente por su ID.
  Future<void> deleteClient(String clientId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _clients.removeWhere((c) => c.id == clientId);
  }
}