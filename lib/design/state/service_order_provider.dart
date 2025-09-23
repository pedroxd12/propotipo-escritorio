// lib/design/state/service_order_provider.dart
import 'package:flutter/material.dart';
import 'package:serviceflow/data/models/orden_servicio_model.dart';
import 'package:serviceflow/data/repositories/service_order_repository.dart';

class ServiceOrderProvider with ChangeNotifier {
  final ServiceOrderRepository _repository = ServiceOrderRepository();
  List<OrdenServicio> _orders = [];
  List<OrdenServicio> _filteredOrders = [];
  OrdenServicio? _selectedOrder;
  bool _isLoading = false;

  List<OrdenServicio> get filteredOrders => _filteredOrders;
  OrdenServicio? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;

  ServiceOrderProvider() {
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();
    _orders = await _repository.getServiceOrders();
    _filteredOrders = _orders;
    if (_orders.isNotEmpty) {
      _selectedOrder = _orders.first;
    }
    _isLoading = false;
    notifyListeners();
  }

  void filterOrders(String query) {
    if (query.isEmpty) {
      _filteredOrders = _orders;
    } else {
      final queryLower = query.toLowerCase();
      _filteredOrders = _orders.where((order) {
        return order.folio.toLowerCase().contains(queryLower) ||
            order.cliente.nombreCuenta.toLowerCase().contains(queryLower) ||
            order.servicio.nombre.toLowerCase().contains(queryLower);
      }).toList();
    }
    if (_selectedOrder != null && !_filteredOrders.contains(_selectedOrder)) {
      _selectedOrder = _filteredOrders.isNotEmpty ? _filteredOrders.first : null;
    }
    notifyListeners();
  }

  void selectOrder(OrdenServicio order) {
    _selectedOrder = order;
    notifyListeners();
  }

  Future<void> addOrder(OrdenServicio newOrder) async {
    final addedOrder = await _repository.addServiceOrder(newOrder);
    _orders.insert(0, addedOrder);
    filterOrders('');
    _selectedOrder = addedOrder;
    notifyListeners();
  }

  Future<void> updateOrder(OrdenServicio updatedOrder) async {
    await _repository.updateServiceOrder(updatedOrder);
    final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
      filterOrders('');
      if(_selectedOrder?.id == updatedOrder.id) {
        _selectedOrder = updatedOrder;
      }
      notifyListeners();
    }
  }

  Future<void> deleteOrder(String orderId) async {
    await _repository.deleteServiceOrder(orderId);
    _orders.removeWhere((o) => o.id == orderId);
    filterOrders('');
    if (_selectedOrder?.id == orderId) {
      _selectedOrder = _filteredOrders.isNotEmpty ? _filteredOrders.first : null;
    }
    notifyListeners();
  }
}