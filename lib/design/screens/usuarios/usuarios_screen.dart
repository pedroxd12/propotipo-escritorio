import 'package:flutter/material.dart';

class user {
  final String id;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String telefono;


  user({
    required this.id,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.telefono,
  });

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';
}


class userScreen extends StatefulWidget {
  const  userScreen({super.key});

  @override
  State<userScreen> createState() => _userScreenState();
}

class _userScreenState extends State<userScreen> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoPaternoController = TextEditingController();
  final TextEditingController _apellidoMaternoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  final List<user> _user = [
    user(
      id: '1',
      nombre: 'Carlos',
      apellidoPaterno: 'Sánchez',
      apellidoMaterno: 'Ramírez',
      correo: 'carlos@example.com',
      telefono: '312-000-1111',
    ),
    user(
      id: '2',
      nombre: 'María',
      apellidoPaterno: 'Gómez',
      apellidoMaterno: 'Luna',
      correo: 'maria@example.com',
      telefono: '312-000-2222',
    ),
  ];
  user? _selecteduser;
  List<user> _filtereduser = [];


  final Color _primaryColor = const Color(0xFF0D47A1);
  final Color _accentColor = const Color(0xFF1976D2);
  final Color _lightGrey = Colors.grey.shade200;
  final Color _darkGreyText = Colors.grey.shade700;
  final Color _headerTextColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _filtereduser = _user;
    if (_user.isNotEmpty) {
      _selecteduser = _user.first;
    }
  }

  void _filteruser(String query) {
    if (query.isEmpty) {
      setState(() {
        _filtereduser = _user;
      });
      return;
    }

    setState(() {
      _filtereduser = _user.where((tech) {
        final q = query.toLowerCase();
        return tech.nombreCompleto.toLowerCase().contains(q) ||
            tech.correo.toLowerCase().contains(q) ||
            tech.id.toLowerCase().contains(q);
      }).toList();
    });
  }


  void _adduser() {
    // Check if both nombre and apellidoPaterno are NOT empty
    if (_nombreController.text.isNotEmpty &&
        _apellidoPaternoController.text.isNotEmpty) {
      final nuevo = user(
        id: 'T${_user.length + 1}',
        nombre: _nombreController.text,
        apellidoPaterno: _apellidoPaternoController.text,
        apellidoMaterno: _apellidoMaternoController.text,
        correo: _correoController.text,
        telefono: _telefonoController.text,
      );

      setState(() {
        _user.add(nuevo);
        _filteruser(_searchController.text);
        _selecteduser = nuevo;
        _clearForm();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Usuario agregado exitosamente. ✅'),
          // Added an emoji for better feedback
          backgroundColor: Colors.green.shade700,
        ),
      );
    } else {
      // This block executes if nombre or apellidoPaterno is empty
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('⚠️ Nombre y Apellido Paterno son requeridos.'),
          // Added an emoji for better feedback
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _clearForm() {
    _nombreController.clear();
    _apellidoPaternoController.clear();
    _apellidoMaternoController.clear();
    _correoController.clear();
    _telefonoController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    bool isLargeScreen = screenWidth > 900;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Usuarios', style: TextStyle(
            color: _headerTextColor, fontWeight: FontWeight.bold)),
        backgroundColor: _primaryColor,
        elevation: 4,
        iconTheme: IconThemeData(color: _headerTextColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: isLargeScreen ? 3 : 2,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(right: 10),
                child: _buildAdduserForm(),
              ),
            ),
            const VerticalDivider(width: 20, thickness: 1),
            Expanded(
              flex: isLargeScreen ? 4 : 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
               children: [
                  _builduserListSection(),
                  const SizedBox(height: 20),
                        /*
                            : Column(
                          children: [
                            _buildTechnicianDetailsCard('Información Técnica',
                                _buildTechnicianDetails(_selectedTechnician!)),
                            const SizedBox(height: 20),
                            _buildTechnicianDetailsCard('Servicios Realizados',
                                _buildTechnicianServices(_selectedTechnician!)),
                          ],
                        ),
                      ),
                    ),*/
               ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          if (icon != null) Icon(icon, color: _primaryColor, size: 22),
          if (icon != null) const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _primaryColor),
          ),
        ],
      ),
    );
  }


  Widget _buildAdduserForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado del formulario
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Text(
                'Agregar Usuario',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _headerTextColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionTitle('Datos Personales', icon: Icons.person_outline),
            Row(children: [
              Expanded(child: _buildTextField(_nombreController, 'Nombre(s)*', icon: Icons.person)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(_apellidoPaternoController, 'Apellido Paterno*', icon: Icons.people_alt_outlined)),
            ]),
            _buildTextField(_apellidoMaternoController, 'Apellido Materno', icon: Icons.people_alt_outlined),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _buildTextField(_correoController, 'Correo Electrónico', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(_telefonoController, 'Teléfono', icon: Icons.phone_outlined, keyboardType: TextInputType.phone)),
            ]),

            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Guardar Usuario'),
                onPressed: _adduser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: _headerTextColor,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {IconData? icon, bool isObscure = false, TextInputType? keyboardType, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, color: _accentColor, size: 20) : null,
          filled: true,
          fillColor: _lightGrey.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _primaryColor, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: TextStyle(color: _darkGreyText, fontSize: 14),
        ),
        style: const TextStyle(fontSize: 15),
      ),
    );
  }

  Widget _builduserListSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Text(
                'Directorio de usuarios',
                textAlign: TextAlign.center,
                style: TextStyle(color: _headerTextColor, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por Id, Nombre, Correo...',
                prefixIcon: Icon(Icons.search, color: _accentColor),
                filled: true,
                fillColor: _lightGrey.withOpacity(0.5),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
              onChanged: _filteruser,
            ),

            const SizedBox(height: 12),
            _builduserListHeader(),
            /* _buildSearchBar(),
            const SizedBox(height: 12),
            _buildTechnicianListHeader(),

            */

            SizedBox(
              height: 200,
              child: _filtereduser.isEmpty
                  ? Center(child: Text('No se encontraron técnicos.',
                  style: TextStyle(
                      color: _darkGreyText, fontStyle: FontStyle.italic)))
                  : ListView.separated(
                itemCount: _filtereduser.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, color: Colors.grey.shade300),
                itemBuilder: (_, index) {
                  final tech = _filtereduser[index];
                  final isSelected = _selecteduser?.id == tech.id;
                  return Material(
                    color: isSelected ? _accentColor.withOpacity(0.15) : Colors
                        .transparent,
                    child: InkWell(
                      onTap: () => setState(() => _selecteduser= tech),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0,
                            horizontal: 8.0),
                        child: Row(
                          children: [
                            _userListCell(
                                tech.id, flex: 1, isSelected: isSelected),
                            _userListCell(tech.nombreCompleto, flex: 4,
                                isSelected: isSelected),
                            _userListCell(
                                tech.correo, flex: 4, isSelected: isSelected),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _builduserListHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade700,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          _userListCell('ID', flex: 1, isHeader: true),
          _userListCell('Nombre Completo', flex: 4, isHeader: true),
          _userListCell('Correo Electrónico', flex: 4, isHeader: true),
        ],
      ),
    );
  }

  Widget _userListCell(String text,
      {int flex = 1, bool isHeader = false, bool isSelected = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isHeader ? 13 : 12.5,
            fontWeight: isHeader ? FontWeight.bold : (isSelected ? FontWeight
                .w600 : FontWeight.normal),
            color: isHeader ? _headerTextColor : (isSelected
                ? _primaryColor
                : _darkGreyText),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
  Widget _builduserDetailsCard(String title, Widget content) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _primaryColor)),
            const Divider(height: 16, thickness: 0.8),
            content, // ← aquí quitamos Flexible
          ],
        ),
      ),
    );
  }

}