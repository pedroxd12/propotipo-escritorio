// lib/design/screens/service_orders/service_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Modelo para una orden de servicio (datos de ejemplo)
enum ServiceStatus { reparado, noFinalizada, enProceso, noSe }

class ServiceOrder {
  final String fechaIngreso;
  final String numeroOrden;
  final String nombreCliente;
  final String equipo;
  final String marca;
  final String telefonoCliente;
  final String numeroSerie;
  final ServiceStatus status;

  ServiceOrder({
    required this.fechaIngreso,
    required this.numeroOrden,
    required this.nombreCliente,
    required this.equipo,
    required this.marca,
    required this.telefonoCliente,
    required this.numeroSerie,
    required this.status,
  });
}

class ServiceOrdersScreen extends StatefulWidget {
  const ServiceOrdersScreen({super.key});

  @override
  State<ServiceOrdersScreen> createState() => _ServiceOrdersScreenState();
}

class _ServiceOrdersScreenState extends State<ServiceOrdersScreen> {
  // Controladores para los campos de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _noOrdenController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  // Valores seleccionados para los filtros
  String? _selectedTipo;
  String? _selectedTecnico;
  String _entregadosOption = 'Todos'; // Si, No, Todos
  String _ordenarPorOption = 'No. de orden'; // No. de orden, Fecha
  String _formaOrdenOption = 'Ascendente'; // Ascendente, Descendente

  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  // Lista de ejemplo de órdenes de servicio
  final List<ServiceOrder> _serviceOrders = [
    ServiceOrder(
        fechaIngreso: '10/03/2025',
        numeroOrden: '12564',
        nombreCliente: 'Alondra Martinez P.',
        equipo: 'Aire acondicionado',
        marca: 'MIRAGE',
        telefonoCliente: '555-1234',
        numeroSerie: 'XGC4423095',
        status: ServiceStatus.reparado),
    ServiceOrder(
        fechaIngreso: '10/03/2025',
        numeroOrden: '12565',
        nombreCliente: 'Pedro Abdiel Villatoro Ch.',
        equipo: 'Aire acondicionado',
        marca: 'CARRIER',
        telefonoCliente: '555-5678',
        numeroSerie: '3304118',
        status: ServiceStatus.noFinalizada),
    ServiceOrder(
        fechaIngreso: '11/03/2025',
        numeroOrden: '12566',
        nombreCliente: 'Maria López',
        equipo: 'Refrigerador',
        marca: 'LG',
        telefonoCliente: '555-8765',
        numeroSerie: 'REF98765',
        status: ServiceStatus.enProceso),
    ServiceOrder(
        fechaIngreso: '12/03/2025',
        numeroOrden: '12567',
        nombreCliente: 'Carlos Sánchez',
        equipo: 'Lavadora',
        marca: 'Samsung',
        telefonoCliente: '555-4321',
        numeroSerie: 'LAVS12345',
        status: ServiceStatus.noSe),
  ];

  // Colores para la simbología y filas
  Color _getStatusColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.reparado:
        return Colors.green.shade100; // Verde claro para la fila
      case ServiceStatus.noFinalizada:
        return Colors.red.shade100; // Rojo claro para la fila
      case ServiceStatus.enProceso:
        return Colors.yellow.shade100; // Amarillo claro para la fila
      case ServiceStatus.noSe:
        return Colors.grey.shade200; // Gris claro para la fila
    }
  }

  Color _getSymbolColor(ServiceStatus status) {
    switch (status) {
      case ServiceStatus.reparado:
        return Colors.green;
      case ServiceStatus.noFinalizada:
        return Colors.red;
      case ServiceStatus.enProceso:
        return Colors.yellow.shade700;
      case ServiceStatus.noSe:
        return Colors.grey;
    }
  }


  Future<void> _selectDate(BuildContext context, bool isDesde) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isDesde ? _fechaDesde : _fechaHasta) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('es', 'ES'), // Para calendario en español
    );
    if (picked != null) {
      setState(() {
        if (isDesde) {
          _fechaDesde = picked;
        } else {
          _fechaHasta = picked;
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SE ELIMINA LA SIGUIENTE LÍNEA:
      // appBar: AppBar(
      //   title: const Text('Lista de órdenes de servicio'),
      // ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFilterSection(),
            const SizedBox(height: 20),
            _buildTableHeader(),
            _buildServiceOrderList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna Izquierda de Filtros
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField('Nombre:', _nombreController),
                      _buildTextField('No. de orden:', _noOrdenController),
                      _buildTextField('Teléfono:', _telefonoController),
                      const SizedBox(height: 8),
                      const Text('¿Entregados?', style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Radio<String>(value: 'Si', groupValue: _entregadosOption, onChanged: (val) => setState(() => _entregadosOption = val!)),
                          const Text('Si'),
                          Radio<String>(value: 'No', groupValue: _entregadosOption, onChanged: (val) => setState(() => _entregadosOption = val!)),
                          const Text('No'),
                          Radio<String>(value: 'Todos', groupValue: _entregadosOption, onChanged: (val) => setState(() => _entregadosOption = val!)),
                          const Text('Todos'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Columna Central de Filtros
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDropdown('Tipo', ['Aire acondicionado', 'Refrigerador', 'Lavadora', 'Otro'], _selectedTipo, (val) => setState(() => _selectedTipo = val)),
                      _buildDropdown('Técnico', ['Juan Perez', 'Ana Gomez', 'Luis Rdz.'], _selectedTecnico, (val) => setState(() => _selectedTecnico = val)),
                      const SizedBox(height: 10),
                      Text('Cant. de servicios: ${_serviceOrders.length}', style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Columna Derecha de Filtros y Simbología
                Expanded(
                  flex: 3, // Dar más espacio para fechas y simbología
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Ordenar por:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Radio<String>(value: 'No. de orden', groupValue: _ordenarPorOption, onChanged: (val) => setState(() => _ordenarPorOption = val!)),
                          const Text('No. orden'),
                          Radio<String>(value: 'Fecha', groupValue: _ordenarPorOption, onChanged: (val) => setState(() => _ordenarPorOption = val!)),
                          const Text('Fecha'),
                        ],
                      ),
                      const Text('Forma:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          Radio<String>(value: 'Ascendente', groupValue: _formaOrdenOption, onChanged: (val) => setState(() => _formaOrdenOption = val!)),
                          const Text('Asc.'),
                          Radio<String>(value: 'Descendente', groupValue: _formaOrdenOption, onChanged: (val) => setState(() => _formaOrdenOption = val!)),
                          const Text('Desc.'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: _buildDateField("Desde:", _fechaDesde, () => _selectDate(context, true))),
                          const SizedBox(width: 8),
                          Expanded(child: _buildDateField("Hasta:", _fechaHasta, () => _selectDate(context, false))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSimbologia(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SizedBox(
            height: 35,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SizedBox(
            height: 40,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              ),
              value: selectedValue,
              hint: const Text('(no seleccionado)', style: TextStyle(fontSize: 14)),
              isExpanded: true,
              items: items.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 14)),
                );
              }).toList(),
              onChanged: onChanged,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(String label, DateTime? date, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[200],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date == null ? 'dd/mm/aaaa' : _dateFormat.format(date),
                  style: TextStyle(fontSize: 14, color: date == null ? Colors.grey[600] : Colors.black),
                ),
                const Icon(Icons.calendar_today, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimbologia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Simbología:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        _buildSimbologiaItem(_getSymbolColor(ServiceStatus.reparado), 'Reparado'),
        _buildSimbologiaItem(_getSymbolColor(ServiceStatus.noFinalizada), 'No finalizada'),
        _buildSimbologiaItem(_getSymbolColor(ServiceStatus.enProceso), 'En proceso'),
        _buildSimbologiaItem(_getSymbolColor(ServiceStatus.noSe), 'No sé'),
      ],
    );
  }

  Widget _buildSimbologiaItem(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.0),
      child: Row(
        children: [
          Container(width: 10, height: 10, color: color),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }


  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      decoration: BoxDecoration(
          color: const Color(0xFF1976D2), // Azul medio para la cabecera de la tabla
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4.0),
            topRight: Radius.circular(4.0),
          )
      ),
      child: Row(
        children: [
          _headerCell('F. Ingreso', flex: 2),
          _headerCell('No. orden', flex: 2),
          _headerCell('Nombre', flex: 3),
          _headerCell('Equipo', flex: 3),
          _headerCell('Marca', flex: 2),
          _headerCell('Teléfono', flex: 2),
          _headerCell('No. Serie', flex: 2),
        ],
      ),
    );
  }

  Widget _headerCell(String title, {int flex = 1}) {
    return Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12), textAlign: TextAlign.center),
        )
    );
  }


  Widget _buildServiceOrderList() {
    if (_serviceOrders.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No hay órdenes de servicio para mostrar.'),
      ));
    }
    return ListView.builder(
      shrinkWrap: true, // Necesario dentro de SingleChildScrollView
      physics: const NeverScrollableScrollPhysics(), // Deshabilita el scroll de ListView
      itemCount: _serviceOrders.length,
      itemBuilder: (context, index) {
        final order = _serviceOrders[index];
        final rowColor = _getStatusColor(order.status);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 4.0),
          decoration: BoxDecoration(
              color: rowColor,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300))
          ),
          child: Row(
            children: [
              _dataCell(order.fechaIngreso, flex: 2),
              _dataCell(order.numeroOrden, flex: 2),
              _dataCell(order.nombreCliente, flex: 3),
              _dataCell(order.equipo, flex: 3),
              _dataCell(order.marca, flex: 2),
              _dataCell(order.telefonoCliente, flex: 2),
              _dataCell(order.numeroSerie, flex: 2),
            ],
          ),
        );
      },
    );
  }

  Widget _dataCell(String text, {int flex = 1, TextAlign align = TextAlign.center}) {
    return Expanded(
        flex: flex,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Text(text, style: const TextStyle(fontSize: 11), textAlign: align, overflow: TextOverflow.ellipsis),
        )
    );
  }
}