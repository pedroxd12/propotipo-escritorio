// lib/design/screens/service_orders/service_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:serviceflow/data/models/orden_servicio_model.dart';
import 'package:serviceflow/design/state/service_order_provider.dart';
import 'package:serviceflow/design/screens/service_orders/order_form_screen.dart';

import '../../state/client_provider.dart';
import '../../state/technician_provider.dart';

class ServiceOrdersScreen extends StatelessWidget {
  const ServiceOrdersScreen({super.key});

  void _showOrderForm(BuildContext context, {OrdenServicio? order}) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Envolvemos el formulario con los providers que necesita (Cliente y Técnico)
        return MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: context.read<ClientProvider>()),
            ChangeNotifierProvider.value(value: context.read<TechnicianProvider>()),
          ],
          child: OrderFormScreen(order: order),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Consumer<ServiceOrderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        // --- CORRECCIÓN 3: LLAMAR AL MÉTODO DEL FORMULARIO ---
                        onPressed: () => _showOrderForm(context),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text("Nueva Orden de Servicio"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _OrderList(
                          orders: provider.filteredOrders,
                          selectedOrder: provider.selectedOrder,
                          onSelect: (order) => provider.selectOrder(order),
                          onFilter: (query) => provider.filterOrders(query),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 3,
                  child: provider.selectedOrder != null
                      ? _OrderDetails(
                    key: ValueKey(provider.selectedOrder!.id),
                    order: provider.selectedOrder!,
                    // --- CORRECCIÓN 4: PASAR LA ORDEN AL FORMULARIO PARA EDITAR ---
                    onEdit: () => _showOrderForm(context, order: provider.selectedOrder!),
                    onDelete: () async {
                      final confirm = await _showDeleteConfirmation(context);
                      if (confirm == true) {
                        provider.deleteOrder(provider.selectedOrder!.id);
                      }
                    },
                  )
                      : const Card(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          "Seleccione una orden para ver sus detalles o cree una nueva.",
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Está seguro de que desea eliminar esta orden de servicio? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
  }
}

// --- LOS WIDGETS DE ABAJO PERMANECEN IGUAL ---

class _OrderList extends StatelessWidget {
  final List<OrdenServicio> orders;
  final OrdenServicio? selectedOrder;
  final Function(OrdenServicio) onSelect;
  final Function(String) onFilter;

  const _OrderList({
    required this.orders,
    this.selectedOrder,
    required this.onSelect,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: onFilter,
              decoration: const InputDecoration(
                hintText: 'Buscar por folio, cliente...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: orders.isEmpty
                ? const Center(child: Text("No se encontraron órdenes."))
                : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final isSelected = selectedOrder?.id == order.id;
                return ListTile(
                  leading: _StatusDot(status: order.status),
                  title: Text(order.folio, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${order.cliente.nombreCuenta}\n${DateFormat.yMMMd('es_ES').format(order.fechaAgendadaInicio)}',
                  ),
                  isThreeLine: true,
                  onTap: () => onSelect(order),
                  selected: isSelected,
                  selectedTileColor: AppColors.navItemActive,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetails extends StatelessWidget {
  final OrdenServicio order;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OrderDetails({super.key, required this.order, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final DateFormat dateTimeFormat = DateFormat('EEE, d MMM y, hh:mm a', 'es_ES');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Folio: ${order.folio}", style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 4),
                      _StatusBadge(status: order.status),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit, tooltip: "Editar Orden"),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.errorColor),
                        onPressed: onDelete,
                        tooltip: "Eliminar Orden",
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              _SectionTitle(title: 'Información del Servicio'),
              _DetailRow(label: 'Cliente', value: order.cliente.nombreCuenta),
              _DetailRow(label: 'Servicio', value: order.servicio.nombre),
              _DetailRow(label: 'Dirección', value: order.direccion.toString()),
              _DetailRow(label: 'Detalles Solicitud', value: order.detallesSolicitud ?? 'N/A'),
              const SizedBox(height: 16),
              _SectionTitle(title: 'Programación'),
              _DetailRow(label: 'Fecha Solicitud', value: dateTimeFormat.format(order.fechaSolicitud)),
              _DetailRow(label: 'Agendado', value: '${dateTimeFormat.format(order.fechaAgendadaInicio)}\n a ${dateTimeFormat.format(order.fechaAgendadaFin)}'),
              _DetailRow(label: 'Inicio Real', value: order.fechaInicioReal != null ? dateTimeFormat.format(order.fechaInicioReal!) : 'Pendiente'),
              _DetailRow(label: 'Fin Real', value: order.fechaFinReal != null ? dateTimeFormat.format(order.fechaFinReal!) : 'Pendiente'),
              const SizedBox(height: 16),
              _SectionTitle(title: 'Equipo Asignado'),
              ...order.tecnicosAsignados.map((tech) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(child: Text(tech.nombres[0])),
                title: Text(tech.nombreCompleto),
                subtitle: const Text('Técnico'),
              )),
              const SizedBox(height: 16),
              _SectionTitle(title: 'Costos'),
              _CostRow(description: 'Costo Base Servicio', cost: order.servicio.costoBase),
              ...order.costosAdicionales.map((costo) => _CostRow(description: costo.descripcion, cost: costo.costo)),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Costo Total', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  Text(NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(order.costoTotal), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primaryDarkColor)),
                ],
              ),
              const SizedBox(height: 16),
              _SectionTitle(title: 'Evidencias'),
              if (order.evidencias.isEmpty)
                const Text('No hay evidencias fotográficas.')
              else
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: order.evidencias.length,
                    itemBuilder: (context, index) {
                      final evidence = order.evidencias[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Image.network(evidence.urlImagen, width: 100, height: 80, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Icon(Icons.error)),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Text(evidence.descripcion ?? '', style: Theme.of(context).textTheme.bodySmall),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              if(order.status == OrdenStatus.finalizada) ...[
                _SectionTitle(title: 'Firmas de Conformidad'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SignatureBox(title: 'Firma del Cliente', imageUrl: order.firmaClienteUrl, receptor: order.nombreReceptor),
                    _SignatureBox(title: 'Firma del Técnico', imageUrl: order.firmaTecnicoUrl),
                  ],
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final OrdenStatus status;
  const _StatusDot({required this.status});

  Color _getStatusColor() {
    switch (status) {
      case OrdenStatus.finalizada: return AppColors.successColor;
      case OrdenStatus.en_proceso: return AppColors.infoColor;
      case OrdenStatus.agendada: return AppColors.warningColor;
      case OrdenStatus.cancelada: return AppColors.errorColor;
      default: return AppColors.textTertiaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _getStatusColor(),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final OrdenStatus status;
  const _StatusBadge({required this.status});

  Color _getBackgroundColor() {
    switch (status) {
      case OrdenStatus.finalizada: return AppColors.successColor.withOpacity(0.1);
      case OrdenStatus.en_proceso: return AppColors.infoColor.withOpacity(0.1);
      case OrdenStatus.agendada: return AppColors.warningColor.withOpacity(0.1);
      case OrdenStatus.cancelada: return AppColors.errorColor.withOpacity(0.1);
      default: return AppColors.textTertiaryColor.withOpacity(0.1);
    }
  }

  Color _getForegroundColor() {
    switch (status) {
      case OrdenStatus.finalizada: return AppColors.successColor;
      case OrdenStatus.en_proceso: return AppColors.infoColor;
      case OrdenStatus.agendada: return AppColors.warningColor;
      case OrdenStatus.cancelada: return AppColors.errorColor;
      default: return AppColors.textTertiaryColor;
    }
  }

  String _getStatusText() {
    return status.toString().split('.').last.replaceAll('_', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(color: _getForegroundColor(), fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 130, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String description;
  final double cost;
  const _CostRow({required this.description, required this.cost});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(description)),
          Text(NumberFormat.currency(locale: 'es_MX', symbol: '\$').format(cost)),
        ],
      ),
    );
  }
}

class _SignatureBox extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String? receptor;

  const _SignatureBox({required this.title, this.imageUrl, this.receptor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 100,
          width: 200,
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.outline),
          ),
          child: imageUrl != null
              ? Image.network(imageUrl!, fit: BoxFit.contain, errorBuilder: (context, error, stackTrace) => const Icon(Icons.error))
              : const Center(child: Text('Sin Firma', style: TextStyle(color: AppColors.textTertiaryColor))),
        ),
        if (receptor != null) ...[
          const SizedBox(height: 4),
          Text(receptor!, style: Theme.of(context).textTheme.bodySmall)
        ]
      ],
    );
  }
}