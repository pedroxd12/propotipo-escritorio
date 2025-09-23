// lib/data/repositories/client_repository.dart
import 'dart:math';
import 'package:serviceflow/data/models/client_model.dart';

class ClientRepository {
  final List<Cliente> _clients = [
    Cliente(
      id: 'cl-1',
      empresaId: 'emp-1',
      nombreCuenta: 'TechCorp S.A. de C.V.',
      telefonoPrincipal: '555-1111-2222',
      emailFacturacion: 'facturacion@techcorp.com',
      direcciones: [
        Direccion(
          id: 'dir-1',
          calleYNumero: 'Av. Melchor Ocampo 15',
          colonia: 'Centro',
          codigoPostal: '60950',
          municipio: 'Lázaro Cárdenas',
          estado: 'Michoacán',
          referencias: 'Frente al malecón de la cultura y las artes.',
          // Coordenadas del Palacio Municipal de Lázaro Cárdenas
          latitud: 17.9625,
          longitud: -102.2033,
        ),
        Direccion(
          id: 'dir-2',
          calleYNumero: 'Av. Noyola 55',
          colonia: 'Ejido',
          codigoPostal: '60950',
          municipio: 'Lázaro Cárdenas',
          estado: 'Michoacán',
          referencias: 'Bodega 3B, portón azul.',
          // Coordenadas de una zona industrial cercana
          latitud: 17.9740,
          longitud: -102.1995,
        ),
      ],
    ),
  ];

  Future<List<Cliente>> getClients() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _clients;
  }

  Future<Cliente> addClient(Cliente newClient) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final clientWithId = Cliente(
      id: 'cl-${Random().nextInt(9000) + 1000}',
      empresaId: newClient.empresaId,
      nombreCuenta: newClient.nombreCuenta,
      telefonoPrincipal: newClient.telefonoPrincipal,
      emailFacturacion: newClient.emailFacturacion,
      direcciones: newClient.direcciones,
    );
    _clients.add(clientWithId);
    return clientWithId;
  }

  Future<Cliente> updateClient(Cliente updatedClient) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _clients.indexWhere((c) => c.id == updatedClient.id);
    if (index != -1) {
      _clients[index] = updatedClient;
      return updatedClient;
    }
    throw Exception('Client not found');
  }

  Future<void> deleteClient(String clientId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _clients.removeWhere((c) => c.id == clientId);
  }
}