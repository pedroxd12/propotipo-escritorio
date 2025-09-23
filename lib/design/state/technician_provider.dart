// lib/design/state/technician_provider.dart
import 'package:flutter/material.dart';
import 'package:serviceflow/data/models/usuario_model.dart';
import 'package:serviceflow/data/repositories/technician_repository.dart';

class TechnicianProvider with ChangeNotifier {
  final TechnicianRepository _repository = TechnicianRepository();
  List<Usuario> _technicians = [];
  List<Usuario> _filteredTechnicians = [];
  Usuario? _selectedTechnician;
  bool _isLoading = false;

  List<Usuario> get filteredTechnicians => _filteredTechnicians;
  Usuario? get selectedTechnician => _selectedTechnician;
  bool get isLoading => _isLoading;

  TechnicianProvider() {
    fetchTechnicians();
  }

  Future<void> fetchTechnicians() async {
    _isLoading = true;
    notifyListeners();
    _technicians = await _repository.getTechnicians();
    _filteredTechnicians = _technicians;
    if (_technicians.isNotEmpty) {
      _selectedTechnician = _technicians.first;
    }
    _isLoading = false;
    notifyListeners();
  }

  void filterTechnicians(String query) {
    if (query.isEmpty) {
      _filteredTechnicians = _technicians;
    } else {
      final queryLower = query.toLowerCase();
      _filteredTechnicians = _technicians.where((tech) {
        return tech.nombreCompleto.toLowerCase().contains(queryLower) ||
            tech.email.toLowerCase().contains(queryLower);
      }).toList();
    }
    notifyListeners();
  }

  void selectTechnician(Usuario technician) {
    _selectedTechnician = technician;
    notifyListeners();
  }

  Future<void> addTechnician(Usuario newTechnician) async {
    final addedTechnician = await _repository.addTechnician(newTechnician);
    _technicians.add(addedTechnician);
    filterTechnicians('');
    _selectedTechnician = addedTechnician;
    notifyListeners();
  }

  Future<void> updateTechnician(Usuario updatedTechnician) async {
    // La lógica de actualización real iría aquí
    final index = _technicians.indexWhere((t) => t.id == updatedTechnician.id);
    if (index != -1) {
      _technicians[index] = updatedTechnician;
      filterTechnicians('');
      _selectedTechnician = updatedTechnician;
      notifyListeners();
    }
  }

  Future<void> deleteTechnician(String technicianId) async {
    // La lógica de borrado real iría aquí
    _technicians.removeWhere((t) => t.id == technicianId);
    filterTechnicians('');
    _selectedTechnician = _filteredTechnicians.isNotEmpty ? _filteredTechnicians.first : null;
    notifyListeners();
  }
}