import 'package:flutter/material.dart';

// Modelo para un Cliente (datos de ejemplo) - Sin cambios
class Client {
  final String id;
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String correo;
  final String telefono;
  final String celular;
  final String rfc;
  final List<ClientAddress> direcciones;
  final List<String> serviciosRealizados; // Lista de IDs de servicios

  Client({
    required this.id,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.correo,
    required this.telefono,
    required this.celular,
    required this.rfc,
    required this.direcciones,
    required this.serviciosRealizados,
  });

  String get nombreCompleto => '$nombre $apellidoPaterno $apellidoMaterno';
}

class ClientAddress {
  final String colonia;
  final String calle;
  final String numInt;
  final String numExt;
  final String codigoPostal;
  final String referencias;

  ClientAddress({
    required this.colonia,
    required this.calle,
    this.numInt = '',
    required this.numExt,
    required this.codigoPostal,
    this.referencias = '',
  });

  @override
  String toString() {
    return '$calle $numExt${numInt.isNotEmpty ? ', Int. $numInt' : ''}\n$colonia, C.P. $codigoPostal${referencias.isNotEmpty ? '\nRef: $referencias' : ''}';
  }
}

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoPaternoController = TextEditingController();
  final TextEditingController _apellidoMaternoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _celularController = TextEditingController();
  final TextEditingController _rfcController = TextEditingController();
  final TextEditingController _coloniaController = TextEditingController();
  final TextEditingController _calleController = TextEditingController();
  final TextEditingController _numIntController = TextEditingController();
  final TextEditingController _numExtController = TextEditingController();
  final TextEditingController _cpController = TextEditingController();
  final TextEditingController _referenciasController = TextEditingController();

  final List<Client> _clients = [
    Client(
      id: '1',
      nombre: 'Alondra',
      apellidoPaterno: 'Martinez',
      apellidoMaterno: 'Pino',
      correo: 'martinezpinoalondra@gmail.com',
      telefono: '555-1111',
      celular: '312-555-2222',
      rfc: 'MAPA800101XXX',
      direcciones: [
        ClientAddress(calle: 'Belisario Dominguez', numExt: '555', colonia: 'INFONAVIT', codigoPostal: '60950', referencias: 'Casa azul con portón blanco'),
        ClientAddress(calle: 'Av. Heroica Escuela Naval Militar', numExt: '39', colonia: 'Centro', codigoPostal: '60950', referencias: 'Frente al parque'),
      ],
      serviciosRealizados: ['15890', '156900', '157000'],
    ),
    Client(
      id: '2',
      nombre: 'Pedro',
      apellidoPaterno: 'Abdiel',
      apellidoMaterno: 'Villatoro',
      correo: 'pedro.v@example.com',
      telefono: '555-3333',
      celular: '443-555-4444',
      rfc: 'VIPA850202YYY',
      direcciones: [
        ClientAddress(calle: 'Reforma', numExt: '100', colonia: 'Juárez', codigoPostal: '06600'),
      ],
      serviciosRealizados: ['12345'],
    ),
    Client(
      id: '3',
      nombre: 'Luisa',
      apellidoPaterno: 'Fernandez',
      apellidoMaterno: 'García',
      correo: 'luisa.fg@example.com',
      telefono: '555-0000',
      celular: '753-555-0000',
      rfc: 'FEGL900303ZZZ',
      direcciones: [
        ClientAddress(calle: 'Insurgentes Sur', numExt: '123', colonia: 'Del Valle', codigoPostal: '03100', referencias: 'Edificio rojo'),
      ],
      serviciosRealizados: ['19988', '19990'],
    ),
  ];

  Client? _selectedClient;
  final TextEditingController _searchController = TextEditingController();
  List<Client> _filteredClients = [];

  // Colores consistentes
  final Color _primaryColor = const Color(0xFF0D47A1); // Azul oscuro principal
  final Color _accentColor = const Color(0xFF1976D2); // Azul medio para acentos
  final Color _lightGrey = Colors.grey.shade200;
  final Color _darkGreyText = Colors.grey.shade700;
  final Color _headerTextColor = Colors.white;


  @override
  void initState() {
    super.initState();
    _filteredClients = _clients;
    if (_clients.isNotEmpty) {
      _selectedClient = _clients.first;
    }
  }

  void _filterClients(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredClients = _clients;
      });
      return;
    }
    setState(() {
      _filteredClients = _clients.where((client) {
        final queryLower = query.toLowerCase();
        return client.nombreCompleto.toLowerCase().contains(queryLower) ||
            client.correo.toLowerCase().contains(queryLower) ||
            client.id.toLowerCase().contains(queryLower);
      }).toList();
    });
  }

  void _addClient() {
    if (_nombreController.text.isNotEmpty && _apellidoPaternoController.text.isNotEmpty) {
      final newClient = Client(
        id: (_clients.length + 1).toString(),
        nombre: _nombreController.text,
        apellidoPaterno: _apellidoPaternoController.text,
        apellidoMaterno: _apellidoMaternoController.text,
        correo: _correoController.text,
        telefono: _telefonoController.text,
        celular: _celularController.text,
        rfc: _rfcController.text,
        direcciones: [
          if (_calleController.text.isNotEmpty && _numExtController.text.isNotEmpty && _coloniaController.text.isNotEmpty && _cpController.text.isNotEmpty)
            ClientAddress(
              colonia: _coloniaController.text,
              calle: _calleController.text,
              numInt: _numIntController.text,
              numExt: _numExtController.text,
              codigoPostal: _cpController.text,
              referencias: _referenciasController.text,
            )
        ],
        serviciosRealizados: [],
      );

      setState(() {
        _clients.add(newClient);
        _filterClients(_searchController.text);
        _selectedClient = newClient; // Seleccionar el nuevo cliente
        _clearForm();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Cliente agregado exitosamente.'),
          backgroundColor: Colors.green.shade700,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nombre y Apellido Paterno son requeridos.'),
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
    _celularController.clear();
    _rfcController.clear();
    _coloniaController.clear();
    _calleController.clear();
    _numIntController.clear();
    _numExtController.clear();
    _cpController.clear();
    _referenciasController.clear();
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    bool isLargeScreen = screenWidth > 900;

    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Clientes', style: TextStyle(color: _headerTextColor, fontWeight: FontWeight.bold)),
        backgroundColor: _primaryColor,
        elevation: 4,
        iconTheme: IconThemeData(color: _headerTextColor), // Para el botón de regreso
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: isLargeScreen ? 3 : 2, // Ajustar flex para dar más espacio al formulario
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(right: 10), // Espacio entre las dos secciones principales
                child: _buildAddClientForm(),
              ),
            ),
            const VerticalDivider(width: 20, thickness: 1),
            Expanded(
              flex: isLargeScreen ? 4 : 3, // Ajustar flex
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildClientListSection(),
                  const SizedBox(height: 20),
                  if (_selectedClient != null)
                    Expanded(
                      child: SingleChildScrollView( // Para permitir scroll si los detalles son largos
                        child: isLargeScreen
                            ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildClientDetailsCard('Direcciones', _buildClientAddresses(_selectedClient!))),
                            const SizedBox(width: 20),
                            Expanded(child: _buildClientDetailsCard('Servicios Realizados', _buildClientServices(_selectedClient!))),
                          ],
                        )
                            : Column( // En pantallas pequeñas, apilar verticalmente
                          children: [
                            _buildClientDetailsCard('Direcciones', _buildClientAddresses(_selectedClient!)),
                            const SizedBox(height: 20),
                            _buildClientDetailsCard('Servicios Realizados', _buildClientServices(_selectedClient!)),
                          ],
                        ),
                      ),
                    ),
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

  Widget _buildAddClientForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container( // Encabezado del formulario
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
                'Agregar Nuevo Cliente',
                textAlign: TextAlign.center,
                style: TextStyle(color: _headerTextColor, fontSize: 20, fontWeight: FontWeight.bold),
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
              Expanded(child: _buildTextField(_rfcController, 'RFC', icon: Icons.badge_outlined)),
            ]),
            Row(children: [
              Expanded(child: _buildTextField(_telefonoController, 'Teléfono Fijo', icon: Icons.phone_outlined, keyboardType: TextInputType.phone)),
              const SizedBox(width: 12),
              Expanded(child: _buildTextField(_celularController, 'Celular', icon: Icons.smartphone_outlined, keyboardType: TextInputType.phone)),
            ]),

            const SizedBox(height: 24),
            _buildSectionTitle('Dirección Principal', icon: Icons.location_on_outlined),
            Row(children: [
              Expanded(flex: 3, child: _buildTextField(_calleController, 'Calle y Número Ext.*', icon: Icons.signpost_outlined)),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _buildTextField(_numIntController, 'Num. Int.', icon: Icons.door_front_door_outlined)),
            ]),
            Row(children: [
              Expanded(flex: 3, child: _buildTextField(_coloniaController, 'Colonia*', icon: Icons.holiday_village_outlined)),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _buildTextField(_cpController, 'Código Postal*', icon: Icons.markunread_mailbox_outlined, keyboardType: TextInputType.number)),
            ]),
            _buildTextField(_referenciasController, 'Referencias Adicionales', icon: Icons.comment_outlined, maxLines: 2),

            const SizedBox(height: 24),
            _buildSectionTitle('Ubicación en Mapa', icon: Icons.map_outlined),
            Container(
              height: 180,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
                borderRadius: BorderRadius.circular(8),
                color: _lightGrey,
              ),
              alignment: Alignment.center,
              child: Icon(Icons.map, size: 60, color: Colors.grey.shade400),
              // child: Text('Widget de Mapa Aquí', style: TextStyle(color: Colors.grey)),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add_alt_1),
                label: const Text('Guardar Cliente'),
                onPressed: _addClient,
                style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    foregroundColor: _headerTextColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
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

  Widget _buildClientListSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20,0,20,20), // No padding top para que el header se pegue
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container( // Encabezado de la lista
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              margin: const EdgeInsets.only(bottom:16), // Para separar del searchbar
              decoration: BoxDecoration(
                color: _accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Text(
                'Directorio de Clientes',
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
              onChanged: _filterClients,
            ),
            const SizedBox(height: 12),
            _buildClientListHeader(),
            SizedBox(
              height: 200, // Altura para la lista, puede ser más dinámica
              child: _filteredClients.isEmpty
                  ? Center(child: Text('No se encontraron clientes.', style: TextStyle(color: _darkGreyText, fontStyle: FontStyle.italic)))
                  : ListView.separated(
                itemCount: _filteredClients.length,
                separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade300),
                itemBuilder: (context, index) {
                  final client = _filteredClients[index];
                  final isSelected = _selectedClient?.id == client.id;
                  return Material(
                    color: isSelected ? _accentColor.withOpacity(0.15) : Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedClient = client;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                        child: Row(
                          children: [
                            _clientListCell(client.id, flex: 1, isSelected: isSelected),
                            _clientListCell(client.nombreCompleto, flex: 4, isSelected: isSelected),
                            _clientListCell(client.correo, flex: 4, isSelected: isSelected),
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

  Widget _buildClientListHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
      decoration: BoxDecoration(
          color: Colors.blueGrey.shade700,
          borderRadius: BorderRadius.circular(6)
      ),
      child: Row(
        children: [
          _clientListCell('ID', flex: 1, isHeader: true),
          _clientListCell('Nombre Completo', flex: 4, isHeader: true),
          _clientListCell('Correo Electrónico', flex: 4, isHeader: true),
        ],
      ),
    );
  }

  Widget _clientListCell(String text, {int flex = 1, bool isHeader = false, bool isSelected = false}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: Text(
          text,
          style: TextStyle(
            fontSize: isHeader ? 13 : 12.5,
            fontWeight: isHeader ? FontWeight.bold : (isSelected ? FontWeight.w600 : FontWeight.normal),
            color: isHeader ? _headerTextColor : (isSelected ? _primaryColor : _darkGreyText),
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildClientDetailsCard(String title, Widget content) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Para que la tarjeta se ajuste al contenido
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: _primaryColor),
            ),
            const Divider(height: 16, thickness: 0.8),
            Flexible(child: content), // Flexible para que el contenido interno se ajuste
          ],
        ),
      ),
    );
  }


  Widget _buildClientAddresses(Client client) {
    if (client.direcciones.isEmpty) {
      return Text('No hay direcciones registradas.', style: TextStyle(fontStyle: FontStyle.italic, color: _darkGreyText));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Si está dentro de otro scroll
      itemCount: client.direcciones.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final address = client.direcciones[index];
        return Container(
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              color: _lightGrey.withOpacity(0.7),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300)
          ),
          child: Text(address.toString(), style: TextStyle(fontSize: 13, color: _darkGreyText, height: 1.4)),
        );
      },
    );
  }

  Widget _buildClientServices(Client client) {
    if (client.serviciosRealizados.isEmpty) {
      return Text('No hay servicios registrados.', style: TextStyle(fontStyle: FontStyle.italic, color: _darkGreyText));
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: client.serviciosRealizados.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final serviceId = client.serviciosRealizados[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
              color: _lightGrey.withOpacity(0.7),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.shade300)
          ),
          child: Row(
            children: [
              Icon(Icons.build_circle_outlined, size: 18, color: _accentColor),
              const SizedBox(width: 8),
              Text('Servicio No. $serviceId', style: TextStyle(fontSize: 13, color: _darkGreyText)),
            ],
          ),
        );
      },
    );
  }
}
