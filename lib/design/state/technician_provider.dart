// lib/design/state/technician_provider.dart
import 'package:flutter/material.dart';
import 'package:serviceflow/data/models/technician_model.dart';
import 'package:serviceflow/data/repositories/technician_repository.dart';

class TechnicianProvider with ChangeNotifier {
  final TechnicianRepository _repository = TechnicianRepository();
  List<Technician> _technicians = [];
  List<Technician> _filteredTechnicians = [];
  Technician? _selectedTechnician;
  bool _isLoading = false;

  List<Technician> get filteredTechnicians => _filteredTechnicians;
  Technician? get selectedTechnician => _selectedTechnician;
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
            tech.correo.toLowerCase().contains(queryLower);
      }).toList();
    }
    notifyListeners();
  }

  void selectTechnician(Technician technician) {
    _selectedTechnician = technician;
    notifyListeners();
  }

  Future<void> addTechnician(Technician newTechnician) async {
    final addedTechnician = await _repository.addTechnician(newTechnician);
    _technicians.add(addedTechnician);
    filterTechnicians('');
    _selectedTechnician = addedTechnician;
    notifyListeners();
  }

  Future<void> updateTechnician(Technician updatedTechnician) async {
    final index = _technicians.indexWhere((t) => t.id == updatedTechnician.id);
    if (index != -1) {
      _technicians[index] = updatedTechnician;
      filterTechnicians('');
      _selectedTechnician = updatedTechnician;
      notifyListeners();
    }
  }

  Future<void> deleteTechnician(String technicianId) async {
    _technicians.removeWhere((t) => t.id == technicianId);
    filterTechnicians('');
    _selectedTechnician = _filteredTechnicians.isNotEmpty ? _filteredTechnicians.first : null;
    notifyListeners();
  }
}