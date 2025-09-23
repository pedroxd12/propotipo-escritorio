// lib/design/screens/usuarios/usuarios_screen.dart
import 'package:flutter/material.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:serviceflow/data/models/app_user_model.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  // Datos de ejemplo
  final List<AppUser> _users = [
    AppUser(id: '1', nombre: 'Carlos', apellidoPaterno: 'Sánchez', apellidoMaterno: 'Ramírez', correo: 'carlos@example.com', telefono: '312-000-1111'),
    AppUser(id: '2', nombre: 'María', apellidoPaterno: 'Gómez', apellidoMaterno: 'Luna', correo: 'maria@example.com', telefono: '312-000-2222'),
  ];
  AppUser? _selectedUser;
  List<AppUser> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _filteredUsers = _users;
    if (_users.isNotEmpty) {
      _selectedUser = _users.first;
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _filteredUsers = _users.where((user) {
        final q = query.toLowerCase();
        return user.nombreCompleto.toLowerCase().contains(q) || user.correo.toLowerCase().contains(q);
      }).toList();
      if (_filteredUsers.isNotEmpty) {
        _selectedUser = _filteredUsers.first;
      } else {
        _selectedUser = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 1100;

    return Scaffold(
      // appBar: AppBar( // <--- LÍNEA ELIMINADA
      //   title: const Text('Gestión de Usuarios'),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Columna de Formulario
            Expanded(
              flex: isLargeScreen ? 3 : 4,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Añadir / Editar Usuario', style: Theme.of(context).textTheme.titleLarge),
                        const Divider(height: 24),
                        TextFormField(decoration: const InputDecoration(labelText: 'Nombre(s)')),
                        const SizedBox(height: 16),
                        TextFormField(decoration: const InputDecoration(labelText: 'Apellido Paterno')),
                        const SizedBox(height: 16),
                        TextFormField(decoration: const InputDecoration(labelText: 'Apellido Materno')),
                        const SizedBox(height: 16),
                        TextFormField(decoration: const InputDecoration(labelText: 'Correo Electrónico')),
                        const SizedBox(height: 16),
                        TextFormField(decoration: const InputDecoration(labelText: 'Teléfono')),
                        const SizedBox(height: 24),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.save),
                            label: const Text('Guardar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            // Columna de Lista y Detalles
            Expanded(
              flex: isLargeScreen ? 5 : 6,
              child: Column(
                children: [
                  _buildUserList(),
                  const SizedBox(height: 24),
                  if (_selectedUser != null)
                    Expanded(child: _buildUserDetails(_selectedUser!))
                  else
                    const Expanded(
                        child: Center(child: Text("Seleccione un usuario para ver sus detalles."))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _filterUsers,
              decoration: const InputDecoration(
                hintText: 'Buscar usuario...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          SizedBox(
            height: 300,
            child: ListView.builder(
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                final user = _filteredUsers[index];
                return Material(
                  color: _selectedUser?.id == user.id ? AppColors.hoverColor : Colors.transparent,
                  child: ListTile(
                    title: Text(user.nombreCompleto),
                    subtitle: Text(user.correo),
                    onTap: () => setState(() => _selectedUser = user),
                    selected: _selectedUser?.id == user.id,
                    selectedTileColor: AppColors.hoverColor,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserDetails(AppUser user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Detalles del Usuario", style: Theme.of(context).textTheme.titleLarge),
              const Divider(height: 24),
              _DetailRow(label: 'ID:', value: user.id),
              _DetailRow(label: 'Nombre:', value: user.nombreCompleto),
              _DetailRow(label: 'Correo:', value: user.correo),
              _DetailRow(label: 'Teléfono:', value: user.telefono),
            ],
          ),
        ),
      ),
    );
  }
}

// Widget de ayuda para mostrar detalles
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
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}