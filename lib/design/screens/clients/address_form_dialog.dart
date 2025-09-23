// lib/design/screens/clients/address_form_dialog.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:serviceflow/data/models/client_model.dart';
import 'package:serviceflow/design/state/client_provider.dart';

class AddressFormDialog extends StatefulWidget {
  final String clientId;
  const AddressFormDialog({super.key, required this.clientId});

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _calleController = TextEditingController();
  final _coloniaController = TextEditingController();
  final _cpController = TextEditingController();
  final _municipioController = TextEditingController();
  final _estadoController = TextEditingController();
  final _referenciasController = TextEditingController();

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newAddress = Direccion(
        id: 'dir-${Random().nextInt(9000) + 1000}', // ID temporal
        calleYNumero: _calleController.text,
        colonia: _coloniaController.text,
        codigoPostal: _cpController.text,
        municipio: _municipioController.text,
        estado: _estadoController.text,
        referencias: _referenciasController.text,
        // Coordenadas de ejemplo. La selección en mapa es compleja en desktop.
        latitud: 17.9625,
        longitud: -102.2033,
      );

      context.read<ClientProvider>().addAddressToClient(widget.clientId, newAddress);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _calleController.dispose();
    _coloniaController.dispose();
    _cpController.dispose();
    _municipioController.dispose();
    _estadoController.dispose();
    _referenciasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Añadir Nueva Dirección'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(controller: _calleController, decoration: const InputDecoration(labelText: 'Calle y Número'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _coloniaController, decoration: const InputDecoration(labelText: 'Colonia')),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: TextFormField(controller: _cpController, decoration: const InputDecoration(labelText: 'C.P.'))),
                    const SizedBox(width: 16),
                    Expanded(child: TextFormField(controller: _municipioController, decoration: const InputDecoration(labelText: 'Municipio'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null)),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(controller: _estadoController, decoration: const InputDecoration(labelText: 'Estado'), validator: (v) => v!.isEmpty ? 'Campo requerido' : null),
                const SizedBox(height: 16),
                TextFormField(controller: _referenciasController, decoration: const InputDecoration(labelText: 'Referencias'), maxLines: 2),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () {
                    // Lógica para abrir un selector de mapa (complejo en desktop)
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Funcionalidad de mapa interactivo no disponible en desktop.')));
                  },
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Seleccionar en Mapa'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        FilledButton.icon(onPressed: _saveForm, icon: const Icon(Icons.add_location_alt), label: const Text('Guardar Dirección')),
      ],
    );
  }
}