// lib/data/models/orden_servicio_model.dart
import 'package:serviceflow/data/models/client_model.dart';
import 'package:serviceflow/data/models/usuario_model.dart';

enum OrdenStatus {
  solicitada,
  agendada,
  en_camino,
  en_proceso,
  finalizada,
  cancelada
}

// Clase añadida para manejar los costos adicionales
class OrdenCostoAdicional {
  final String id;
  final String descripcion;
  final double costo;

  OrdenCostoAdicional({
    required this.id,
    required this.descripcion,
    required this.costo,
  });
}

class OrdenServicio {
  final String id;
  final String empresaId;
  final String folio;
  final Cliente cliente;
  final Direccion direccion;
  final Servicio servicio;
  final OrdenStatus status;
  final DateTime fechaSolicitud;
  final DateTime fechaAgendadaInicio;
  final DateTime fechaAgendadaFin;
  final DateTime? fechaInicioReal;
  final DateTime? fechaFinReal;
  final String? detallesSolicitud;
  final double costoTotal;
  final List<Usuario> tecnicosAsignados;
  final List<OrdenEvidencia> evidencias;
  // --- CAMPOS AÑADIDOS ---
  final List<OrdenCostoAdicional> costosAdicionales;
  final String? firmaClienteUrl;
  final String? nombreReceptor;
  final String? firmaTecnicoUrl;

  OrdenServicio({
    required this.id,
    required this.empresaId,
    required this.folio,
    required this.cliente,
    required this.direccion,
    required this.servicio,
    required this.status,
    required this.fechaSolicitud,
    required this.fechaAgendadaInicio,
    required this.fechaAgendadaFin,
    this.fechaInicioReal,
    this.fechaFinReal,
    this.detallesSolicitud,
    required this.costoTotal,
    this.tecnicosAsignados = const [],
    this.evidencias = const [],
    // --- CAMPOS AÑADIDOS AL CONSTRUCTOR ---
    this.costosAdicionales = const [],
    this.firmaClienteUrl,
    this.nombreReceptor,
    this.firmaTecnicoUrl,
  });

  // --- MÉTODO COPYWITH AÑADIDO DIRECTAMENTE A LA CLASE ---
  OrdenServicio copyWith({
    String? id,
    String? empresaId,
    String? folio,
    Cliente? cliente,
    Direccion? direccion,
    Servicio? servicio,
    OrdenStatus? status,
    DateTime? fechaSolicitud,
    DateTime? fechaAgendadaInicio,
    DateTime? fechaAgendadaFin,
    DateTime? fechaInicioReal,
    DateTime? fechaFinReal,
    String? detallesSolicitud,
    double? costoTotal,
    List<Usuario>? tecnicosAsignados,
    List<OrdenEvidencia>? evidencias,
    List<OrdenCostoAdicional>? costosAdicionales,
    String? firmaClienteUrl,
    String? nombreReceptor,
    String? firmaTecnicoUrl,
  }) {
    return OrdenServicio(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      folio: folio ?? this.folio,
      cliente: cliente ?? this.cliente,
      direccion: direccion ?? this.direccion,
      servicio: servicio ?? this.servicio,
      status: status ?? this.status,
      fechaSolicitud: fechaSolicitud ?? this.fechaSolicitud,
      fechaAgendadaInicio: fechaAgendadaInicio ?? this.fechaAgendadaInicio,
      fechaAgendadaFin: fechaAgendadaFin ?? this.fechaAgendadaFin,
      fechaInicioReal: fechaInicioReal ?? this.fechaInicioReal,
      fechaFinReal: fechaFinReal ?? this.fechaFinReal,
      detallesSolicitud: detallesSolicitud ?? this.detallesSolicitud,
      costoTotal: costoTotal ?? this.costoTotal,
      tecnicosAsignados: tecnicosAsignados ?? this.tecnicosAsignados,
      evidencias: evidencias ?? this.evidencias,
      costosAdicionales: costosAdicionales ?? this.costosAdicionales,
      firmaClienteUrl: firmaClienteUrl ?? this.firmaClienteUrl,
      nombreReceptor: nombreReceptor ?? this.nombreReceptor,
      firmaTecnicoUrl: firmaTecnicoUrl ?? this.firmaTecnicoUrl,
    );
  }
}

class Servicio {
  final String id;
  final String nombre;
  final String? descripcion;
  final double costoBase;

  Servicio({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.costoBase,
  });
}

class OrdenEvidencia {
  final String id;
  final String urlImagen;
  final String? descripcion;
  final DateTime fechaSubida;

  OrdenEvidencia({
    required this.id,
    required this.urlImagen,
    this.descripcion,
    required this.fechaSubida,
  });
}