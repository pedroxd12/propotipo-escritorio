// lib/design/screens/clients/clients_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:serviceflow/data/models/client_model.dart';
import 'package:serviceflow/design/state/client_provider.dart';
import 'package:serviceflow/core/theme/app_colors.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Consumer<ClientProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna Izquierda: Lista de Clientes y Botón de Añadir
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showClientForm(context, provider),
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text("Nuevo Cliente"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _ClientList(
                          clients: provider.filteredClients,
                          selectedClient: provider.selectedClient,
                          onSelect: (client) => provider.selectClient(client),
                          onFilter: (query) => provider.filterClients(query),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Columna Derecha: Detalles del Cliente Seleccionado
                Expanded(
                  flex: 3,
                  child: provider.selectedClient != null
                      ? _ClientDetails(
                    client: provider.selectedClient!,
                    onEdit: () => _showClientForm(context, provider, client: provider.selectedClient),
                    onDelete: () async {
                      final confirm = await _showDeleteConfirmation(context);
                      if (confirm ?? false) {
                        provider.deleteClient(provider.selectedClient!.id);
                      }
                    },
                  )
                      : const Card(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          "Seleccione un cliente de la lista para ver sus detalles o añada uno nuevo.",
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

  // Muestra el diálogo con el formulario para añadir o editar un cliente
  void _showClientForm(BuildContext context, ClientProvider provider, {Client? client}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      // CORRECCIÓN: Usamos el 'dialogContext' que provee el builder para el pop
      builder: (dialogContext) => AlertDialog(
        title: Text(client == null ? 'Registrar Nuevo Cliente' : 'Editar Cliente'),
        content: _ClientForm(
          client: client,
          onSave: (newClientData) {
            if (client == null) {
              provider.addClient(newClientData);
            } else {
              // Aseguramos que el ID se mantenga al actualizar
              final updatedClient = Client(
                id: client.id,
                nombre: newClientData.nombre,
                apellidoPaterno: newClientData.apellidoPaterno,
                apellidoMaterno: newClientData.apellidoMaterno,
                correo: newClientData.correo,
                telefono: newClientData.telefono,
                celular: newClientData.celular,
                rfc: newClientData.rfc,
                direcciones: newClientData.direcciones,
                serviciosRealizados: client.serviciosRealizados,
              );
              provider.updateClient(updatedClient);
            }
            // Usamos el 'dialogContext' para cerrar el diálogo
            Navigator.of(dialogContext).pop();
          },
        ),
        actions: [
          TextButton(
            // Usamos el 'dialogContext' para cerrar el diálogo
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
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
        content: const Text('¿Está seguro de que desea eliminar a este cliente? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Eliminar')),
        ],
      ),
    );
  }
}

// Widget para la lista filtrable de clientes
class _ClientList extends StatelessWidget {
  final List<Client> clients;
  final Client? selectedClient;
  final Function(Client) onSelect;
  final Function(String) onFilter;

  const _ClientList({required this.clients, this.selectedClient, required this.onSelect, required this.onFilter});

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
                hintText: 'Buscar por nombre, correo...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: clients.isEmpty
                ? const Center(child: Text("No se encontraron clientes."))
                : ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                final client = clients[index];
                final isSelected = selectedClient?.id == client.id;
                return ListTile(
                  title: Text(client.nombreCompleto, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(client.correo),
                  onTap: () => onSelect(client),
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

// Widget para mostrar los detalles del cliente seleccionado
class _ClientDetails extends StatelessWidget {
  final Client client;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClientDetails({required this.client, required this.onEdit, required this.onDelete});

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
                  Text("Detalles del Cliente", style: Theme.of(context).textTheme.headlineSmall),
                  Row(
                    children: [
                      IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit, tooltip: "Editar Cliente"),
                      IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.errorColor),
                          onPressed: onDelete,
                          tooltip: "Eliminar Cliente"),
                    ],
                  )
                ],
              ),
              const Divider(height: 24),
              _DetailRow(label: 'ID Cliente', value: client.id),
              _DetailRow(label: 'Nombre Completo', value: client.nombreCompleto),
              _DetailRow(label: 'Correo Electrónico', value: client.correo),
              _DetailRow(label: 'Teléfono Fijo', value: client.telefono),
              _DetailRow(label: 'Teléfono Celular', value: client.celular),
              _DetailRow(label: 'RFC', value: client.rfc),
              const Divider(height: 32),
              Text("Direcciones", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (client.direcciones.isEmpty)
                const Text("No hay direcciones registradas.")
              else
                ...client.direcciones.map((addr) => Card(
                  elevation: 0,
                  color: AppColors.surfaceVariant,
                  child: ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: AppColors.primaryColor),
                    title: Text(addr.toString()),
                  ),
                )),
              const Divider(height: 32),
              Text("Historial de Servicios", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (client.serviciosRealizados.isEmpty)
                const Text("No hay servicios en el historial.")
              else
                ...client.serviciosRealizados.map((id) => ListTile(
                  leading: const Icon(Icons.receipt_long_outlined, color: AppColors.primaryColor),
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

// Widget para el formulario de cliente
class _ClientForm extends StatefulWidget {
  final Client? client;
  final Function(Client) onSave;

  const _ClientForm({this.client, required this.onSave});

  @override
  State<_ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<_ClientForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _paternoController;
  late TextEditingController _maternoController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  late TextEditingController _celularController;
  late TextEditingController _rfcController;
  // Para la dirección, en una app real sería más complejo
  late TextEditingController _calleController;
  late TextEditingController _coloniaController;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.client?.nombre ?? '');
    _paternoController = TextEditingController(text: widget.client?.apellidoPaterno ?? '');
    _maternoController = TextEditingController(text: widget.client?.apellidoMaterno ?? '');
    _correoController = TextEditingController(text: widget.client?.correo ?? '');
    _telefonoController = TextEditingController(text: widget.client?.telefono ?? '');
    _celularController = TextEditingController(text: widget.client?.celular ?? '');
    _rfcController = TextEditingController(text: widget.client?.rfc ?? '');
    // Simplificado para un solo domicilio
    _calleController = TextEditingController(text: widget.client?.direcciones.firstOrNull?.calle ?? '');
    _coloniaController = TextEditingController(text: widget.client?.direcciones.firstOrNull?.colonia ?? '');
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _paternoController.dispose();
    _maternoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _celularController.dispose();
    _rfcController.dispose();
    _calleController.dispose();
    _coloniaController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final newClientData = Client(
        id: widget.client?.id ?? '', // ID se genera en el provider si es nuevo
        nombre: _nombreController.text,
        apellidoPaterno: _paternoController.text,
        apellidoMaterno: _maternoController.text,
        correo: _correoController.text,
        telefono: _telefonoController.text,
        celular: _celularController.text,
        rfc: _rfcController.text,
        direcciones: [
          ClientAddress(calle: _calleController.text, numExt: '0', colonia: _coloniaController.text, codigoPostal: '00000')
        ],
        serviciosRealizados: widget.client?.serviciosRealizados ?? [],
      );
      widget.onSave(newClientData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SizedBox(
        width: 500, // Ancho fijo para el diálogo
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
              TextFormField(controller: _celularController, decoration: const InputDecoration(labelText: 'Celular')),
              const SizedBox(height: 16),
              TextFormField(controller: _rfcController, decoration: const InputDecoration(labelText: 'RFC')),
              const SizedBox(height: 16),
              TextFormField(controller: _calleController, decoration: const InputDecoration(labelText: 'Calle y Número')),
              const SizedBox(height: 16),
              TextFormField(controller: _coloniaController, decoration: const InputDecoration(labelText: 'Colonia')),
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
          SizedBox(width: 140, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value.isNotEmpty ? value : "N/A")),
        ],
      ),
    );
  }
}