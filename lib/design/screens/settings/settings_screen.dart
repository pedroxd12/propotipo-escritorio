// lib/design/screens/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:serviceflow/core/theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos del formulario
  final _companyNameController = TextEditingController(text: 'ServiceFlow Inc.');
  final _servicesController = TextEditingController(text: 'Instalación A/C, Mantenimiento Preventivo, Paneles Solares');

  TimeOfDay _workStartTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _workEndTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _lunchStartTime = const TimeOfDay(hour: 13, minute: 0);
  TimeOfDay _lunchEndTime = const TimeOfDay(hour: 14, minute: 0);

  Future<void> _selectTime(BuildContext context, {required bool isStartTime, required bool isWorkTime}) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isWorkTime
          ? (isStartTime ? _workStartTime : _workEndTime)
          : (isStartTime ? _lunchStartTime : _lunchEndTime),
    );
    if (picked != null) {
      setState(() {
        if (isWorkTime) {
          if (isStartTime) {
            _workStartTime = picked;
          } else {
            _workEndTime = picked;
          }
        } else {
          if (isStartTime) {
            _lunchStartTime = picked;
          } else {
            _lunchEndTime = picked;
          }
        }
      });
    }
  }

  void _saveSettings() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajustes guardados correctamente.'),
          backgroundColor: AppColors.successColor,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ajustes Generales', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  const Text('Configura los detalles de tu empresa y la operación de la aplicación.', style: TextStyle(color: AppColors.textSecondaryColor)),
                  const Divider(height: 32),

                  // Sección de Información de la Empresa
                  _buildSection(
                    title: 'Información de la Empresa',
                    icon: Icons.business_rounded,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _companyNameController,
                          decoration: const InputDecoration(labelText: 'Nombre de la Empresa'),
                          validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildLogoUploader(),
                      ],
                    ),
                  ),

                  // Sección de Horario Laboral
                  _buildSection(
                    title: 'Horario Laboral',
                    icon: Icons.schedule_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Define las horas de operación estándar.'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTimePickerField('Inicio Jornada', _workStartTime, () => _selectTime(context, isStartTime: true, isWorkTime: true))),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTimePickerField('Fin Jornada', _workEndTime, () => _selectTime(context, isStartTime: false, isWorkTime: true))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildTimePickerField('Inicio Comida', _lunchStartTime, () => _selectTime(context, isStartTime: true, isWorkTime: false))),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTimePickerField('Fin Comida', _lunchEndTime, () => _selectTime(context, isStartTime: false, isWorkTime: false))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Sección de Servicios
                  _buildSection(
                    title: 'Catálogo de Servicios',
                    icon: Icons.miscellaneous_services_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ingresa los tipos de servicios que ofreces, separados por comas.'),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _servicesController,
                          decoration: const InputDecoration(
                            labelText: 'Servicios',
                            hintText: 'Servicio A, Servicio B, ...',
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _saveSettings,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Guardar Cambios'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required Widget child}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryColor),
                const SizedBox(width: 12),
                Text(title, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const Divider(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildLogoUploader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Logotipo de la Empresa", style: TextStyle(color: AppColors.textSecondaryColor)),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: const Icon(Icons.image_outlined, size: 40, color: AppColors.textTertiaryColor),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                // Lógica para subir archivo (fuera del alcance de este ejemplo)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('La funcionalidad de carga de archivos no está implementada.')),
                );
              },
              icon: const Icon(Icons.upload_file_rounded),
              label: const Text('Subir Logo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimaryColor,
                side: const BorderSide(color: AppColors.outline),
                elevation: 0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimePickerField(String label, TimeOfDay time, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.access_time_outlined),
        ),
        child: Text(
          time.format(context),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}