// lib/data/repositories/service_order_repository.dart
import 'dart:math';
import 'package:serviceflow/data/models/client_model.dart';
import 'package:serviceflow/data/models/orden_servicio_model.dart';
import 'package:serviceflow/data/models/usuario_model.dart';

class ServiceOrderRepository {
  // --- DATOS DE EJEMPLO ---
  static final _cliente1 = Cliente(
    id: 'cl-1',
    empresaId: 'emp-1',
    nombreCuenta: 'TechCorp S.A. de C.V.',
    telefonoPrincipal: '555-1111-2222',
    emailFacturacion: 'facturacion@techcorp.com',
    direcciones: [
      Direccion(
        id: 'dir-1',
        calleYNumero: 'Av. Siempre Viva 742',
        colonia: 'Springfield',
        codigoPostal: '12345',
        municipio: 'Springfield',
        estado: 'Oregon',
        // --- CORRECCIÓN AQUÍ ---
        latitud: 17.9625,
        longitud: -102.2033,
      ),
    ],
  );

  static final _cliente2 = Cliente(
    id: 'cl-2',
    empresaId: 'emp-1',
    nombreCuenta: 'Industrias BetaMax',
    telefonoPrincipal: '555-3333-4444',
    emailFacturacion: 'compras@betamax.com',
    direcciones: [
      Direccion(
        id: 'dir-2',
        calleYNumero: 'Blvd. Industrial 100',
        colonia: 'Parque Industrial',
        codigoPostal: '12346',
        municipio: 'Springfield',
        estado: 'Oregon',
        // --- CORRECCIÓN AQUÍ ---
        latitud: 17.9740,
        longitud: -102.1995,
      ),
    ],
  );

  static final _tecnico1 = Usuario(
      id: 'user-2', empresaId: 'emp-1', nombres: 'Carlos', apellidoPaterno: 'Sánchez', email: 'carlos@example.com', telefono: '312-000-1111', rol: 'Tecnico'
  );
  static final _tecnico2 = Usuario(
      id: 'user-3', empresaId: 'emp-1', nombres: 'María', apellidoPaterno: 'Gómez', email: 'maria@example.com', telefono: '312-000-2222', rol: 'Tecnico'
  );


  final List<OrdenServicio> _orders = [
    OrdenServicio(
        id: 'os-1',
        empresaId: 'emp-1',
        folio: 'OS-2024-001',
        cliente: _cliente1,
        direccion: _cliente1.direcciones.first,
        servicio: Servicio(id: 'ser-1', nombre: 'Mantenimiento Preventivo A/C', costoBase: 1250.00),
        status: OrdenStatus.finalizada,
        fechaSolicitud: DateTime.now().subtract(const Duration(days: 5)),
        fechaAgendadaInicio: DateTime.now().subtract(const Duration(days: 4, hours: 2)),
        fechaAgendadaFin: DateTime.now().subtract(const Duration(days: 4, hours: 1)),
        fechaInicioReal: DateTime.now().subtract(const Duration(days: 4, hours: 2, minutes: 5)),
        fechaFinReal: DateTime.now().subtract(const Duration(days: 4, hours: 1, minutes: 10)),
        detallesSolicitud: 'El equipo no enfría correctamente en la oficina principal.',
        costoTotal: 1450.00,
        tecnicosAsignados: [_tecnico1],
        evidencias: [
          OrdenEvidencia(id: 'ev-1', urlImagen: 'http://via.placeholder.com/300/CCCCCC/FFFFFF?text=Antes', descripcion: 'Unidad antes del mantenimiento', fechaSubida: DateTime.now()),
          OrdenEvidencia(id: 'ev-2', urlImagen: 'http://via.placeholder.com/300/CCCCCC/FFFFFF?text=Después', descripcion: 'Unidad limpia y funcional', fechaSubida: DateTime.now()),
        ],
        costosAdicionales: [
          OrdenCostoAdicional(id: 'ca-1', descripcion: 'Reemplazo de filtro', costo: 200.00)
        ],
        firmaClienteUrl: 'http://via.placeholder.com/200x100.png?text=Firma+Cliente',
        nombreReceptor: 'Ana García',
        firmaTecnicoUrl: 'http://via.placeholder.com/200x100.png?text=Firma+Tecnico'
    ),
    OrdenServicio(
        id: 'os-2',
        empresaId: 'emp-1',
        folio: 'OS-2024-002',
        cliente: _cliente2,
        direccion: _cliente2.direcciones.first,
        servicio: Servicio(id: 'ser-2', nombre: 'Instalación Panel Solar', costoBase: 25000.00),
        status: OrdenStatus.enProceso,
        fechaSolicitud: DateTime.now().subtract(const Duration(days: 2)),
        fechaAgendadaInicio: DateTime.now().subtract(const Duration(hours: 4)),
        fechaAgendadaFin: DateTime.now().add(const Duration(hours: 8)),
        fechaInicioReal: DateTime.now().subtract(const Duration(hours: 4, minutes: 15)),
        detallesSolicitud: 'Instalación de 5 paneles solares en techo de bodega.',
        costoTotal: 25000.00,
        tecnicosAsignados: [_tecnico1, _tecnico2],
        evidencias: [
          OrdenEvidencia(id: 'ev-3', urlImagen: 'http://via.placeholder.com/300/CCCCCC/FFFFFF?text=Progreso+1', descripcion: 'Montaje de rieles', fechaSubida: DateTime.now()),
        ]
    ),
    OrdenServicio(
      id: 'os-3',
      empresaId: 'emp-1',
      folio: 'OS-2024-003',
      cliente: _cliente1,
      direccion: _cliente1.direcciones.first,
      servicio: Servicio(id: 'ser-3', nombre: 'Reparación de Fuga', costoBase: 800.00),
      status: OrdenStatus.agendada,
      fechaSolicitud: DateTime.now().subtract(const Duration(days: 1)),
      fechaAgendadaInicio: DateTime.now().add(const Duration(days: 1, hours: 9)),
      fechaAgendadaFin: DateTime.now().add(const Duration(days: 1, hours: 11)),
      detallesSolicitud: 'Fuga de agua en la tubería principal del baño.',
      costoTotal: 800.00,
      tecnicosAsignados: [_tecnico2],
    ),
  ];

  Future<List<OrdenServicio>> getServiceOrders() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _orders;
  }

  Future<OrdenServicio> addServiceOrder(OrdenServicio newOrder) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final orderWithId = newOrder.copyWith(
      id: 'os-${Random().nextInt(9000) + 1000}',
    );
    _orders.insert(0, orderWithId);
    return orderWithId;
  }

  Future<OrdenServicio> updateServiceOrder(OrdenServicio updatedOrder) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _orders.indexWhere((o) => o.id == updatedOrder.id);
    if (index != -1) {
      _orders[index] = updatedOrder;
      return updatedOrder;
    }
    throw Exception('Order not found');
  }

  Future<void> deleteServiceOrder(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _orders.removeWhere((o) => o.id == orderId);
  }
}