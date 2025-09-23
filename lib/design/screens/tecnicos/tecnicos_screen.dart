// lib/design/screens/tecnicos/tecnicos_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:serviceflow/data/models/technician_model.dart';
import 'package:serviceflow/design/state/technician_provider.dart';

class TechniciansScreen extends StatelessWidget {
  const TechniciansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Consumer<TechnicianProvider>(
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
                        onPressed: () => _showTechnicianForm(context, provider),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text("Nuevo Técnico"),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _TechnicianList(
                          technicians: provider.filteredTechnicians,
                          selectedTechnician: provider.selectedTechnician,
                          onSelect: (tech) => provider.selectTechnician(tech),
                          onFilter: (query) => provider.filterTechnicians(query),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 3,
                  child: provider.selectedTechnician != null
                      ? _TechnicianDetails(
                    technician: provider.selectedTechnician!,
                    onEdit: () => _showTechnicianForm(context, provider, technician: provider.selectedTechnician),
                    onDelete: () async {
                      final confirm = await _showDeleteConfirmation(context);
                      if (confirm ?? false) {
                        provider.deleteTechnician(provider.selectedTechnician!.id);
                      }
                    },
                  )
                      : const Card(child: Center(child: Text("Seleccione un técnico para ver sus detalles."))),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTechnicianForm(BuildContext context, TechnicianProvider provider, {Technician? technician}) {
    showDialog(
      context: context,
      // CORRECCIÓN: Usamos el 'dialogContext' que provee el builder
      builder: (dialogContext) => AlertDialog(
        title: Text(technician == null ? 'Nuevo Técnico' : 'Editar Técnico'),
        content: _TechnicianForm(
          technician: technician,
          onSave: (newTechData) {
            if (technician == null) {
              provider.addTechnician(newTechData);
            } else {
              final updatedTech = Technician(
                id: technician.id,
                nombre: newTechData.nombre,
                apellidoPaterno: newTechData.apellidoPaterno,
                apellidoMaterno: newTechData.apellidoMaterno,
                correo: newTechData.correo,
                telefono: newTechData.telefono,
                especialidad: newTechData.especialidad,
                habilidades: newTechData.habilidades,
                serviciosRealizados: technician.serviciosRealizados,
              );
              provider.updateTechnician(updatedTech);
            }
            Navigator.of(dialogContext).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text("Cancelar"),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Está seguro de que desea eliminar a este técnico? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
  }
}

class _TechnicianList extends StatelessWidget {
  final List<Technician> technicians;
  final Technician? selectedTechnician;
  final Function(Technician) onSelect;
  final Function(String) onFilter;

  const _TechnicianList(
      {required this.technicians, this.selectedTechnician, required this.onSelect, required this.onFilter});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child:
            TextField(onChanged: onFilter, decoration: const InputDecoration(hintText: 'Buscar...', prefixIcon: Icon(Icons.search))),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: technicians.length,
              itemBuilder: (context, index) {
                final tech = technicians[index];
                return ListTile(
                  title: Text(tech.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(tech.especialidad),
                  selected: selectedTechnician?.id == tech.id,
                  selectedTileColor: AppColors.navItemActive,
                  onTap: () => onSelect(tech),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TechnicianDetails extends StatelessWidget {
  final Technician technician;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TechnicianDetails({required this.technician, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
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
                  Text('Detalles del Técnico', style: Theme.of(context).textTheme.headlineSmall),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit, tooltip: "Editar"),
                      IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.errorColor),
                          onPressed: onDelete,
                          tooltip: "Eliminar"),
                    ],
                  )
                ],
              ),
              const Divider(height: 24),
              _DetailRow(label: 'ID Técnico', value: technician.id),
              _DetailRow(label: 'Nombre', value: technician.nombreCompleto),
              _DetailRow(label: 'Correo', value: technician.correo),
              _DetailRow(label: 'Teléfono', value: technician.telefono),
              _DetailRow(label: 'Especialidad', value: technician.especialidad),
              _DetailRow(label: 'Habilidades', value: technician.habilidades.join(', ')),
              const Divider(height: 32),
              Text("Servicios Asignados", style: Theme.of(context).textTheme.titleLarge),
              if (technician.serviciosRealizados.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text("No tiene servicios asignados."),
                )
              else
                ...technician.serviciosRealizados.map((id) => ListTile(
                  leading: const Icon(Icons.assignment_outlined, color: AppColors.primaryColor),
                  title: Text("Orden de Servicio #$id"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.go('/order-detail/$id'),
                )),
            ],
          ),
        ),
      ),
    );
  }
}

class _TechnicianForm extends StatefulWidget {
  final Technician? technician;
  final Function(Technician) onSave;

  const _TechnicianForm({this.technician, required this.onSave});

  @override
  State<_TechnicianForm> createState() => _TechnicianFormState();
}

class _TechnicianFormState extends State<_TechnicianForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _paternoController;
  late TextEditingController _maternoController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _especialidadController;
  late TextEditingController _habilidadesController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.technician?.nombre ?? '');
    _paternoController = TextEditingController(text: widget.technician?.apellidoPaterno ?? '');
    _maternoController = TextEditingController(text: widget.technician?.apellidoMaterno ?? '');
    _correoController = TextEditingController(text: widget.technician?.correo ?? '');
    _telefonoController = TextEditingController(text: widget.technician?.telefono ?? '');
    _especialidadController = TextEditingController(text: widget.technician?.especialidad ?? '');
    _habilidadesController = TextEditingController(text: widget.technician?.habilidades.join(', ') ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _paternoController.dispose();
    _maternoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _especialidadController.dispose();
    _habilidadesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final newTechData = Technician(
        id: widget.technician?.id ?? '',
        nombre: _nombreController.text,
        apellidoPaterno: _paternoController.text,
        apellidoMaterno: _maternoController.text,
        correo: _correoController.text,
        telefono: _telefonoController.text,
        especialidad: _especialidadController.text,
        habilidades: _habilidadesController.text.split(',').map((e) => e.trim()).toList(),
        serviciosRealizados: widget.technician?.serviciosRealizados ?? [],
      );
      widget.onSave(newTechData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre(s)')),
              const SizedBox(height: 16),
              TextFormField(controller: _paternoController, decoration: const InputDecoration(labelText: 'Apellido Paterno')),
              const SizedBox(height: 16),
              TextFormField(controller: _maternoController, decoration: const InputDecoration(labelText: 'Apellido Materno')),
              const SizedBox(height: 16),
              TextFormField(controller: _correoController, decoration: const InputDecoration(labelText: 'Correo')),
              const SizedBox(height: 16),
              TextFormField(controller: _telefonoController, decoration: const InputDecoration(labelText: 'Teléfono')),
              const SizedBox(height: 16),
              TextFormField(controller: _especialidadController, decoration: const InputDecoration(labelText: 'Especialidad')),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _habilidadesController,
                  decoration: const InputDecoration(labelText: 'Habilidades (separadas por coma)')),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _handleSave,
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value.isNotEmpty ? value : "N/A")),
        ],
      ),
    );
  }
}