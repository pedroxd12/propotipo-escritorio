import 'package:flutter/material.dart';

class Technician {
  final String id;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final List<String> habilidades;
  final List<String> serviciosRealizados;

  Technician({
    required this.id,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.habilidades,
    required this.serviciosRealizados,
  });

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';
}

class TechniciansScreen extends StatefulWidget {
  const TechniciansScreen({super.key});

  @override
  State<TechniciansScreen> createState() => _TechniciansScreenState();
}

class _TechniciansScreenState extends State<TechniciansScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoPController = TextEditingController();
  final TextEditingController _apellidoMController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  List<Technician> _technicians = [
    Technician(
      id: '1',
      nombre: 'Alondra',
      apellidoPaterno: 'Martínez',
      apellidoMaterno: 'Pino',
      correo: 'martinezpinoalondra@gmail.com',
      habilidades: ['Mantenimiento a Paneles Solares', 'Mantenimiento a Aires acondicionados'],
      serviciosRealizados: ['159445', '4589'],
    ),
  ];

  Technician? _selectedTechnician;
  List<Technician> _filteredTechnicians = [];

  @override
  void initState() {
    super.initState();
    _filteredTechnicians = _technicians;
    if (_technicians.isNotEmpty) _selectedTechnician = _technicians.first;
  }

  void _filterTechnicians(String query) {
    setState(() {
      _filteredTechnicians = _technicians.where((tech) =>
      tech.nombreCompleto.toLowerCase().contains(query.toLowerCase()) ||
          tech.correo.toLowerCase().contains(query.toLowerCase()) ||
          tech.id.contains(query)).toList();
    });
  }

  void _addTechnician() {
    if (_nombreController.text.isEmpty || _apellidoPController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Nombre y apellido paterno requeridos."),
        backgroundColor: Colors.red.shade600,
      ));
      return;
    }

    Technician newTech = Technician(
      id: (_technicians.length + 1).toString(),
      nombre: _nombreController.text,
      apellidoPaterno: _apellidoPController.text,
      apellidoMaterno: _apellidoMController.text,
      correo: _correoController.text,
      habilidades: [],
      serviciosRealizados: [],
    );

    setState(() {
      _technicians.add(newTech);
      _filteredTechnicians = _technicians;
      _selectedTechnician = newTech;
    });

    _clearForm();
  }

  void _clearForm() {
    _nombreController.clear();
    _apellidoPController.clear();
    _apellidoMController.clear();
    _correoController.clear();
    _passController.clear();
    _confirmPassController.clear();
  }

  void _editTechnician(Technician tech) {
    _nombreController.text = tech.nombre;
    _apellidoPController.text = tech.apellidoPaterno;
    _apellidoMController.text = tech.apellidoMaterno;
    _correoController.text = tech.correo;
    _selectedTechnician = tech;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar técnico'),
        content: SizedBox(
          width: 400,
          child: _buildTechnicianForm(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _updateTechnician();
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearForm();
            },
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _updateTechnician() {
    if (_selectedTechnician == null) return;

    setState(() {
      final updated = Technician(
        id: _selectedTechnician!.id,
        nombre: _nombreController.text,
        apellidoPaterno: _apellidoPController.text,
        apellidoMaterno: _apellidoMController.text,
        correo: _correoController.text,
        habilidades: _selectedTechnician!.habilidades,
        serviciosRealizados: _selectedTechnician!.serviciosRealizados,
      );
      final index = _technicians.indexWhere((t) => t.id == updated.id);
      if (index != -1) {
        _technicians[index] = updated;
        _filterTechnicians(_searchController.text);
        _selectedTechnician = updated;
        _clearForm();
      }
    });
  }

  void _deleteTechnician(Technician tech) {
    setState(() {
      _technicians.removeWhere((t) => t.id == tech.id);
      _filterTechnicians(_searchController.text);
      if (_selectedTechnician?.id == tech.id) {
        _selectedTechnician = null;
      }
    });
  }

  Widget _buildTechnicianForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Agregar técnico', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(child: _buildTextField(_nombreController, 'Nombre')),
              const SizedBox(width: 10),
              Expanded(child: _buildTextField(_apellidoPController, 'Apellido paterno')),
            ]),
            _buildTextField(_apellidoMController, 'Apellido materno'),
            _buildTextField(_correoController, 'Correo asignado'),
            _buildTextField(_passController, 'Contraseña asignada', obscure: true),
            _buildTextField(_confirmPassController, 'Confirmar contraseña asignada', obscure: true),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _addTechnician,
                child: const Text('Agregar'),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildTechnicianList() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lista de técnicos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar técnico',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: _filterTechnicians,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredTechnicians.length,
              itemBuilder: (context, index) {
                final tech = _filteredTechnicians[index];
                return Card(
                  child: ListTile(
                    title: Text(tech.nombreCompleto),
                    subtitle: Text(tech.correo),
                    selected: _selectedTechnician?.id == tech.id,
                    onTap: () {
                      setState(() => _selectedTechnician = tech);
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editTechnician(tech),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTechnician(tech),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechnicianDetails() {
    if (_selectedTechnician == null) {
      return const Text('Seleccione un técnico.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Habilidades:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _selectedTechnician!.habilidades.isEmpty
            ? const Text('Sin habilidades registradas.')
            : Column(
          children: _selectedTechnician!.habilidades.map((h) => ListTile(
            leading: const Icon(Icons.check_circle_outline),
            title: Text(h),
          )).toList(),
        ),
        const SizedBox(height: 12),
        const Text('Servicios realizados:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _selectedTechnician!.serviciosRealizados.isEmpty
            ? const Text('Sin servicios registrados.')
            : Column(
          children: _selectedTechnician!.serviciosRealizados.map((s) => ListTile(
            leading: const Icon(Icons.build),
            title: Text('Servicio ID: $s'),
          )).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Técnicos')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Flexible(flex: 2, child: _buildTechnicianList()),
            const SizedBox(width: 16),
            Flexible(flex: 2, child: _buildTechnicianForm()),
            const SizedBox(width: 16),
            Flexible(flex: 3, child: _buildTechnicianDetails()),
          ],
        ),
      ),
    );
  }
}
