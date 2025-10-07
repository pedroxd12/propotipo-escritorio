// lib/design/screens/tecnicos/tecnicos_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:serviceflow/data/models/usuario_model.dart';
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
                  // >>> MEJORA DE FLUIDEZ: AnimatedSwitcher para el panel de detalles
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.98, end: 1.0).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: provider.selectedTechnician != null
                        ? _TechnicianDetails(
                      key: ValueKey(provider.selectedTechnician!.id), // Clave para la animación
                      technician: provider.selectedTechnician!,
                      onEdit: () => _showTechnicianForm(context, provider, technician: provider.selectedTechnician),
                      onDelete: () async {
                        final confirm = await _showDeleteConfirmation(context);
                        if (confirm ?? false) {
                          provider.deleteTechnician(provider.selectedTechnician!.id);
                        }
                      },
                    )
                        : const Card(
                      key: ValueKey('empty_details'), // Clave para el estado vacío
                      child: Center(child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text("Seleccione un técnico para ver sus detalles o añada uno nuevo.", textAlign: TextAlign.center),
                      )),
                    ),
                  ),
                  // <<< FIN DE MEJORA
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTechnicianForm(BuildContext context, TechnicianProvider provider, {Usuario? technician}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(technician == null ? 'Nuevo Técnico' : 'Editar Técnico'),
        content: _TechnicianForm(
          technician: technician,
          onSave: (newTechData) {
            if (technician == null) {
              provider.addTechnician(newTechData);
            } else {
              provider.updateTechnician(newTechData);
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
  final List<Usuario> technicians;
  final Usuario? selectedTechnician;
  final Function(Usuario) onSelect;
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
            TextField(onChanged: onFilter, decoration: const InputDecoration(hintText: 'Buscar técnico...', prefixIcon: Icon(Icons.search))),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: technicians.length,
              itemBuilder: (context, index) {
                final tech = technicians[index];
                return ListTile(
                  leading: CircleAvatar(child: Text(tech.nombres[0])),
                  title: Text(tech.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(tech.perfilTecnico?.especialidad ?? 'Sin especialidad'),
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
  final Usuario technician;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TechnicianDetails({super.key, required this.technician, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final perfil = technician.perfilTecnico;

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
              _DetailRow(label: 'ID Usuario', value: technician.id),
              _DetailRow(label: 'Nombre', value: technician.nombreCompleto),
              _DetailRow(label: 'Correo', value: technician.email),
              _DetailRow(label: 'Teléfono', value: technician.telefono),
              const Divider(height: 32),
              Text("Perfil Técnico", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if(perfil != null) ...[
                _DetailRow(label: 'Especialidad', value: perfil.especialidad),
                _DetailRow(label: 'Habilidades', value: perfil.habilidades.map((h) => h.nombre).join(', ')),
              ] else
                const Text("Sin perfil técnico definido."),

              const Divider(height: 32),
              Text("Servicios Asignados", style: Theme.of(context).textTheme.titleLarge),
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text("Funcionalidad de historial pendiente."),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _TechnicianForm extends StatefulWidget {
  final Usuario? technician;
  final Function(Usuario) onSave;

  const _TechnicianForm({this.technician, required this.onSave});

  @override
  State<_TechnicianForm> createState() => _TechnicianFormState();
}

class _TechnicianFormState extends State<_TechnicianForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombresController;
  late TextEditingController _paternoController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _especialidadController;
  late TextEditingController _habilidadesController;

  @override
  void initState() {
    super.initState();
    _nombresController = TextEditingController(text: widget.technician?.nombres ?? '');
    _paternoController = TextEditingController(text: widget.technician?.apellidoPaterno ?? '');
    _correoController = TextEditingController(text: widget.technician?.email ?? '');
    _telefonoController = TextEditingController(text: widget.technician?.telefono ?? '');
    _especialidadController = TextEditingController(text: widget.technician?.perfilTecnico?.especialidad ?? '');
    _habilidadesController = TextEditingController(text: widget.technician?.perfilTecnico?.habilidades.map((e) => e.nombre).join(', ') ?? '');
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _paternoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _especialidadController.dispose();
    _habilidadesController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final habilidades = _habilidadesController.text
          .split(',')
          .where((s) => s.trim().isNotEmpty)
          .map((nombre) => Habilidad(id: '', nombre: nombre.trim()))
          .toList();

      final newTechData = Usuario(
          id: widget.technician?.id ?? '',
          empresaId: widget.technician?.empresaId ?? 'emp-1',
          nombres: _nombresController.text,
          apellidoPaterno: _paternoController.text,
          email: _correoController.text,
          telefono: _telefonoController.text,
          rol: 'Tecnico',
          perfilTecnico: TecnicoPerfil(
            especialidad: _especialidadController.text,
            habilidades: habilidades,
          )
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
              TextFormField(controller: _nombresController, decoration: const InputDecoration(labelText: 'Nombre(s)'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _paternoController, decoration: const InputDecoration(labelText: 'Apellido Paterno'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _correoController, decoration: const InputDecoration(labelText: 'Correo'), validator: (v) => v!.isEmpty || !v.contains('@') ? 'Correo inválido' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _telefonoController, decoration: const InputDecoration(labelText: 'Teléfono')),
              const Divider(height: 24),
              TextFormField(controller: _especialidadController, decoration: const InputDecoration(labelText: 'Especialidad')),
              const SizedBox(height: 16),
              TextFormField(
                  controller: _habilidadesController,
                  decoration: const InputDecoration(labelText: 'Habilidades (separadas por coma)', hintText: 'Instalación, Mantenimiento, ...')),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
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