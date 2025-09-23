// lib/design/state/client_provider.dart
import 'package:flutter/material.dart';
import 'package:serviceflow/data/models/client_model.dart';
import 'package:serviceflow/data/repositories/client_repository.dart';

class ClientProvider with ChangeNotifier {
  final ClientRepository _repository = ClientRepository();
  List<Cliente> _clients = [];
  List<Cliente> _filteredClients = [];
  Cliente? _selectedClient;
  bool _isLoading = false;

  List<Cliente> get filteredClients => _filteredClients;
  Cliente? get selectedClient => _selectedClient;
  bool get isLoading => _isLoading;

  ClientProvider() {
    fetchClients();
  }

  Future<void> fetchClients() async {
    _isLoading = true;
    notifyListeners();
    _clients = await _repository.getClients();
    _filteredClients = _clients;
    if (_clients.isNotEmpty) {
      _selectedClient = _clients.first;
    }
    _isLoading = false;
    notifyListeners();
  }

  void filterClients(String query) {
    if (query.isEmpty) {
      _filteredClients = _clients;
    } else {
      final queryLower = query.toLowerCase();
      _filteredClients = _clients.where((client) {
        return client.nombreCuenta.toLowerCase().contains(queryLower) ||
            client.emailFacturacion.toLowerCase().contains(queryLower);
      }).toList();
    }
    if (_selectedClient != null && !_filteredClients.contains(_selectedClient)) {
      _selectedClient = _filteredClients.isNotEmpty ? _filteredClients.first : null;
    }
    notifyListeners();
  }

  void selectClient(Cliente client) {
    _selectedClient = client;
    notifyListeners();
  }

  Future<void> addAddressToClient(String clientId, Direccion newAddress) async {
    final clientIndex = _clients.indexWhere((c) => c.id == clientId);
    if (clientIndex == -1) return;

    final client = _clients[clientIndex];
    final updatedAddresses = List<Direccion>.from(client.direcciones)..add(newAddress);

    final updatedClient = client.copyWith(direcciones: updatedAddresses);

    _clients[clientIndex] = updatedClient;

    filterClients('');
    if (_selectedClient?.id == clientId) {
      _selectedClient = updatedClient;
    }
    notifyListeners();
  }

  Future<void> addClient(Cliente newClient) async {
    final addedClient = await _repository.addClient(newClient);
    _clients.add(addedClient);
    filterClients('');
    _selectedClient = addedClient;
    notifyListeners();
  }

  Future<void> updateClient(Cliente updatedClient) async {
    await _repository.updateClient(updatedClient);
    final index = _clients.indexWhere((c) => c.id == updatedClient.id);
    if (index != -1) {
      _clients[index] = updatedClient;
      filterClients('');
      _selectedClient = updatedClient;
      notifyListeners();
    }
  }

  Future<void> deleteClient(String clientId) async {
    await _repository.deleteClient(clientId);
    _clients.removeWhere((c) => c.id == clientId);
    filterClients('');
    _selectedClient = _filteredClients.isNotEmpty ? _filteredClients.first : null;
    notifyListeners();
  }
}