// lib/design/state/client_provider.dart
import 'package:flutter/material.dart';
import 'package:serviceflow/data/models/client_model.dart';
import 'package:serviceflow/data/repositories/client_repository.dart';

class ClientProvider with ChangeNotifier {
  final ClientRepository _repository = ClientRepository();
  List<Client> _clients = [];
  List<Client> _filteredClients = [];
  Client? _selectedClient;
  bool _isLoading = false;

  List<Client> get filteredClients => _filteredClients;
  Client? get selectedClient => _selectedClient;
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
        return client.nombreCompleto.toLowerCase().contains(queryLower) ||
            client.correo.toLowerCase().contains(queryLower);
      }).toList();
    }
    // Si el cliente seleccionado ya no está en la lista filtrada, deselecciónalo
    if (_selectedClient != null && !_filteredClients.contains(_selectedClient)) {
      _selectedClient = _filteredClients.isNotEmpty ? _filteredClients.first : null;
    }
    notifyListeners();
  }

  void selectClient(Client client) {
    _selectedClient = client;
    notifyListeners();
  }

  Future<void> addClient(Client newClient) async {
    final addedClient = await _repository.addClient(newClient);
    _clients.add(addedClient);
    filterClients(''); // para refrescar la lista
    _selectedClient = addedClient;
    notifyListeners();
  }

  Future<void> updateClient(Client updatedClient) async {
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