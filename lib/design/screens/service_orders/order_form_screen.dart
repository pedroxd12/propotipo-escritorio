// lib/design/screens/service_orders/order_form_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:serviceflow/data/models/client_model.dart';
import 'package:serviceflow/data/models/orden_servicio_model.dart';
import 'package:serviceflow/data/models/usuario_model.dart';
import 'package:serviceflow/design/state/client_provider.dart';
import 'package:serviceflow/design/state/service_order_provider.dart';
import 'package:serviceflow/design/state/technician_provider.dart';

class OrderFormScreen extends StatefulWidget {
  final OrdenServicio? order; // Para editar una orden existente

  const OrderFormScreen({super.key, this.order});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  late TextEditingController _folioController;
  late TextEditingController _detallesController;
  late TextEditingController _servicioNombreController;
  late TextEditingController _servicioCostoController;

  // Selección de Modelos
  Cliente? _selectedClient;
  Direccion? _selectedAddress;
  List<Usuario> _selectedTechnicians = [];

  // Selección de Fechas
  DateTime _fechaAgendadaInicio = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _horaAgendadaInicio = const TimeOfDay(hour: 9, minute: 0);
  DateTime _fechaAgendadaFin = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _horaAgendadaFin = const TimeOfDay(hour: 11, minute: 0);

  @override
  void initState() {
    super.initState();
    _folioController = TextEditingController(text: widget.order?.folio ?? '');
    _detallesController = TextEditingController(text: widget.order?.detallesSolicitud ?? '');
    _servicioNombreController = TextEditingController(text: widget.order?.servicio.nombre ?? '');
    _servicioCostoController = TextEditingController(text: widget.order?.servicio.costoBase.toString() ?? '');

    if (widget.order != null) {
      final order = widget.order!;
      _selectedClient = order.cliente;
      _selectedAddress = order.direccion;
      _selectedTechnicians = List.from(order.tecnicosAsignados);
      _fechaAgendadaInicio = order.fechaAgendadaInicio;
      _horaAgendadaInicio = TimeOfDay.fromDateTime(order.fechaAgendadaInicio);
      _fechaAgendadaFin = order.fechaAgendadaFin;
      _horaAgendadaFin = TimeOfDay.fromDateTime(order.fechaAgendadaFin);
    }
  }

  @override
  void dispose() {
    _folioController.dispose();
    _detallesController.dispose();
    _servicioNombreController.dispose();
    _servicioCostoController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime(BuildContext context, bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart ? _fechaAgendadaInicio : _fechaAgendadaFin,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate == null) return;

    if (!context.mounted) return;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: isStart ? _horaAgendadaInicio : _horaAgendadaFin,
    );
    if (pickedTime == null) return;

    if (!context.mounted) return;

    setState(() {
      if (isStart) {
        _fechaAgendadaInicio = pickedDate;
        _horaAgendadaInicio = pickedTime;
      } else {
        _fechaAgendadaFin = pickedDate;
        _horaAgendadaFin = pickedTime;
      }
    });
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      if (_selectedClient == null || _selectedAddress == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text(
                    'Por favor, seleccione un cliente y una dirección.'),
                backgroundColor: AppColors.errorColor),
          );
        }
        return;
      }

      final serviceOrderProvider = context.read<ServiceOrderProvider>();

      final newOrder = OrdenServicio(
        id: widget.order?.id ?? '', // Se mantiene el ID si se edita
        empresaId: 'emp-1', // Asumir un ID de empresa
        folio: _folioController.text,
        cliente: _selectedClient!,
        direccion: _selectedAddress!,
        servicio: Servicio(
          id: 'ser-temp',
          nombre: _servicioNombreController.text,
          costoBase: double.tryParse(_servicioCostoController.text) ?? 0.0,
        ),
        status: OrdenStatus.agendada,
        fechaSolicitud: DateTime.now(),
        fechaAgendadaInicio: DateTime(_fechaAgendadaInicio.year, _fechaAgendadaInicio.month, _fechaAgendadaInicio.day, _horaAgendadaInicio.hour, _horaAgendadaInicio.minute),
        fechaAgendadaFin: DateTime(_fechaAgendadaFin.year, _fechaAgendadaFin.month, _fechaAgendadaFin.day, _horaAgendadaFin.hour, _horaAgendadaFin.minute),
        detallesSolicitud: _detallesController.text,
        costoTotal: double.tryParse(_servicioCostoController.text) ?? 0.0, // El costo total inicial es el costo base
        tecnicosAsignados: _selectedTechnicians,
      );

      serviceOrderProvider.addOrder(newOrder);

      Navigator.of(context).pop(); // Cierra el diálogo/pantalla del formulario
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos los providers para acceder a las listas de clientes y técnicos
    final clientProvider = context.watch<ClientProvider>();
    final technicianProvider = context.watch<TechnicianProvider>();

    return AlertDialog(
      title: Text(widget.order == null ? 'Crear Nueva Orden de Servicio' : 'Editar Orden'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle("Información Principal"),
                TextFormField(
                  controller: _folioController,
                  decoration: const InputDecoration(labelText: 'Folio de Orden'),
                  validator: (value) => value!.isEmpty ? 'El folio es requerido' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Cliente>(
                  initialValue: _selectedClient,
                  hint: const Text('Seleccionar Cliente'),
                  items: clientProvider.filteredClients.map((client) {
                    return DropdownMenuItem(
                      value: client,
                      child: Text(client.nombreCuenta),
                    );
                  }).toList(),
                  onChanged: (client) {
                    setState(() {
                      _selectedClient = client;
                      _selectedAddress = null; // Reiniciar dirección al cambiar de cliente
                    });
                  },
                  validator: (value) => value == null ? 'Seleccione un cliente' : null,
                ),
                if (_selectedClient != null) ...[
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Direccion>(
                    initialValue: _selectedAddress,
                    hint: const Text('Seleccionar Dirección'),
                    items: _selectedClient!.direcciones.map((address) {
                      return DropdownMenuItem(
                        value: address,
                        child: Text(address.toString(), overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (address) {
                      setState(() {
                        _selectedAddress = address;
                      });
                    },
                    validator: (value) => value == null ? 'Seleccione una dirección' : null,
                  ),
                ],
                const SizedBox(height: 24),
                _SectionTitle("Detalles del Servicio"),
                TextFormField(
                  controller: _servicioNombreController,
                  decoration: const InputDecoration(labelText: 'Nombre del Servicio'),
                  validator: (value) => value!.isEmpty ? 'El nombre es requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _servicioCostoController,
                  decoration: const InputDecoration(labelText: 'Costo Base', prefixText: '\$ '),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if(value == null || value.isEmpty) return 'El costo es requerido';
                    if(double.tryParse(value) == null) return 'Ingrese un número válido';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _detallesController,
                  decoration: const InputDecoration(labelText: 'Detalles de la Solicitud'),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                _SectionTitle("Programación"),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDateTime(context, true),
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Fecha y Hora de Inicio'),
                          child: Text(DateFormat('yMd').add_jm().format(DateTime(_fechaAgendadaInicio.year, _fechaAgendadaInicio.month, _fechaAgendadaInicio.day, _horaAgendadaInicio.hour, _horaAgendadaInicio.minute))),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectDateTime(context, false),
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Fecha y Hora de Fin'),
                          child: Text(DateFormat('yMd').add_jm().format(DateTime(_fechaAgendadaFin.year, _fechaAgendadaFin.month, _fechaAgendadaFin.day, _horaAgendadaFin.hour, _horaAgendadaFin.minute))),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                _SectionTitle("Asignar Técnicos"),
                // Un Dropdown para selección múltiple sería más complejo.
                // Usaremos uno simple para asignar el técnico principal por ahora.
                DropdownButtonFormField<Usuario>(
                    initialValue: _selectedTechnicians.isNotEmpty ? _selectedTechnicians.first : null,
                    hint: const Text('Asignar técnico principal'),
                    items: technicianProvider.filteredTechnicians.map((tech) {
                      return DropdownMenuItem(value: tech, child: Text(tech.nombreCompleto));
                    }).toList(),
                    onChanged: (tech) {
                      if (tech != null) {
                        setState(() {
                          _selectedTechnicians = [tech];
                        });
                      }
                    }
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton.icon(
          onPressed: _saveForm,
          icon: const Icon(Icons.save),
          label: const Text('Guardar Orden'),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0, top: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}