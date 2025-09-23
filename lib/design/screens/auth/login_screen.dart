import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importar flutter_svg
import 'package:core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  // Controladores para los campos de texto
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Lógica de inicio de sesión (simulada)
      print('Usuario: ${_userController.text}');
      print('Contraseña: ${_passwordController.text}');
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400), // Ancho máximo para el formulario
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SvgPicture.asset( // Cambiado de Image.asset a SvgPicture.asset
                    'assets/images/service_flow_logo.svg', // Ruta al archivo SVG
                    height: 80, // Ajusta el tamaño según sea necesario
                    // colorFilter: ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn), // Descomenta si tu SVG es de un solo color y quieres teñirlo
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Iniciar sesión',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _userController,
                    decoration: const InputDecoration(
                      hintText: 'Usuario',
                      prefixIcon: Icon(Icons.person_outline, color: AppColors.textSecondaryColor),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese su usuario';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'Contraseña',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondaryColor),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppColors.textSecondaryColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingrese su contraseña';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Ingresar'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      // Lógica para "olvidé mi contraseña"
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Funcionalidad "Olvidé mi contraseña" no implementada.')),
                      );
                    },
                    child: Text(
                      '¿Has olvidado tu contraseña?',
                      style: TextStyle(color: AppColors.primaryColor, fontSize: 14),
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
}