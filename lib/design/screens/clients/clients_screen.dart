// lib/design/screens/clients/clients_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serviceflow/data/models/client_model.dart';
import 'package:serviceflow/design/state/client_provider.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:serviceflow/design/screens/clients/address_form_dialog.dart';

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
                Expanded(
                  flex: 3,
                  child: provider.selectedClient != null
                      ? _ClientDetails(
                    client: provider.selectedClient!,
                    onEdit: () => _showClientForm(context, provider, client: provider.selectedClient),
                    onDelete: () async {
                      final confirm = await _showDeleteConfirmation(context);
                      if (confirm == true) {
                        provider.deleteClient(provider.selectedClient!.id);
                      }
                    },
                  )
                      : const Card(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          "Seleccione un cliente para ver sus detalles o añada uno nuevo.",
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

  void _showClientForm(BuildContext context, ClientProvider provider, {Cliente? client}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(client == null ? 'Registrar Nuevo Cliente' : 'Editar Cliente'),
        content: _ClientForm(
          client: client,
          onSave: (newClientData) {
            if (client == null) {
              provider.addClient(newClientData);
            } else {
              final updatedClient = client.copyWith(
                nombreCuenta: newClientData.nombreCuenta,
                telefonoPrincipal: newClientData.telefonoPrincipal,
                emailFacturacion: newClientData.emailFacturacion,
              );
              provider.updateClient(updatedClient);
            }
            Navigator.of(dialogContext).pop();
          },
        ),
        actions: [
          TextButton(
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

class _ClientList extends StatelessWidget {
  final List<Cliente> clients;
  final Cliente? selectedClient;
  final Function(Cliente) onSelect;
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
                  title: Text(client.nombreCuenta, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(client.emailFacturacion),
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

class _ClientDetails extends StatelessWidget {
  final Cliente client;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ClientDetails({required this.client, required this.onEdit, required this.onDelete});

  Future<void> _launchMap(Direccion address) async {
    final Uri googleMapsUrl = Uri.parse('http://maps.google.com/maps?q=${address.latitud},${address.longitud}');
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl);
    } else {
      throw 'No se pudo abrir el mapa para ${address.latitud},${address.longitud}';
    }
  }

  void _showAddAddressForm(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return ChangeNotifierProvider.value(
          value: context.read<ClientProvider>(),
          child: AddressFormDialog(clientId: client.id),
        );
      },
    );
  }

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
              _DetailRow(label: 'Nombre de Cuenta', value: client.nombreCuenta),
              _DetailRow(label: 'Correo de Facturación', value: client.emailFacturacion),
              _DetailRow(label: 'Teléfono Principal', value: client.telefonoPrincipal),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Direcciones", style: Theme.of(context).textTheme.titleLarge),
                  IconButton(
                    onPressed: () => _showAddAddressForm(context),
                    icon: const Icon(Icons.add_location_alt_outlined),
                    tooltip: "Añadir Dirección",
                  )
                ],
              ),
              const SizedBox(height: 8),
              if (client.direcciones.isEmpty)
                const Text("No hay direcciones registradas.")
              else
                ...client.direcciones.map((addr) => Card(
                  elevation: 0,
                  color: AppColors.surfaceVariant,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.location_on_outlined, color: AppColors.primaryColor),
                    title: Text(addr.calleYNumero),
                    subtitle: Text(addr.toString()),
                    trailing: IconButton(
                      icon: const Icon(Icons.map_outlined),
                      onPressed: () => _launchMap(addr),
                      tooltip: "Ver en mapa",
                    ),
                  ),
                )),
              const Divider(height: 32),
              Text("Historial de Servicios", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text("No hay servicios en el historial (funcionalidad pendiente).")
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientForm extends StatefulWidget {
  final Cliente? client;
  final Function(Cliente) onSave;

  const _ClientForm({this.client, required this.onSave});

  @override
  State<_ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<_ClientForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCuentaController;
  late TextEditingController _emailController;
  late TextEditingController _telefonoController;

  @override
  void initState() {
    super.initState();
    _nombreCuentaController = TextEditingController(text: widget.client?.nombreCuenta ?? '');
    _emailController = TextEditingController(text: widget.client?.emailFacturacion ?? '');
    _telefonoController = TextEditingController(text: widget.client?.telefonoPrincipal ?? '');
  }

  @override
  void dispose() {
    _nombreCuentaController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final newClientData = Cliente(
        id: widget.client?.id ?? '',
        empresaId: widget.client?.empresaId ?? 'emp-1',
        nombreCuenta: _nombreCuentaController.text,
        emailFacturacion: _emailController.text,
        telefonoPrincipal: _telefonoController.text,
        direcciones: widget.client?.direcciones ?? [],
      );
      widget.onSave(newClientData);
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(controller: _nombreCuentaController, decoration: const InputDecoration(labelText: 'Nombre de la cuenta o Empresa'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _emailController, decoration: const InputDecoration(labelText: 'Correo de Facturación'), validator: (v) => v!.isEmpty || !v.contains('@') ? 'Correo inválido' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _telefonoController, decoration: const InputDecoration(labelText: 'Teléfono Principal')),
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
          SizedBox(width: 150, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(value.isNotEmpty ? value : "N/A")),
        ],
      ),
    );
  }
}