// lib/design/screens/auth/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _buttonsController;
  late AnimationController _backgroundController;

  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _buttonsSlideAnimation;
  late Animation<double> _buttonsFadeAnimation;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();

    // Controladores de animación
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Animaciones del logo
    _logoScaleAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    // Animaciones del texto
    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeInOut,
    ));

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOutCubic,
    ));

    // Animaciones de botones
    _buttonsSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _buttonsController,
      curve: Curves.easeOutBack,
    ));

    _buttonsFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _buttonsController,
      curve: Curves.easeIn,
    ));

    // Animación de fondo
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    // Secuencia de animaciones
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // Iniciar animación de fondo inmediatamente
    _backgroundController.forward();

    // Logo aparece primero
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    // Texto aparece después del logo
    await Future.delayed(const Duration(milliseconds: 600));
    _textController.forward();

    // Botones aparecen al final
    await Future.delayed(const Duration(milliseconds: 400));
    _buttonsController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _buttonsController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  // Función para abrir la URL de registro
  Future<void> _launchURL() async {
    final Uri url = Uri.parse('http://localhost:3000');
    if (!await launchUrl(url)) {
      throw Exception('No se pudo lanzar $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          // Elementos decorativos de fondo animados
          _buildAnimatedBackgroundDecorations(),

          // Contenido principal
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Logo animado sin marco
                    _buildAnimatedLogoSection(),

                    SizedBox(height: screenHeight * 0.05),

                    // Texto animado
                    _buildAnimatedTextSection(context),

                    SizedBox(height: screenHeight * 0.07),

                    // Botones animados más pequeños
                    _buildAnimatedButtonsSection(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackgroundDecorations() {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        return Stack(
          children: [
            // Círculos decorativos animados
            Positioned(
              top: -50 + (_backgroundAnimation.value * 20),
              right: -50 - (_backgroundAnimation.value * 30),
              child: Transform.scale(
                scale: 0.8 + (_backgroundAnimation.value * 0.2),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor.withOpacity(
                      0.03 * _backgroundAnimation.value,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -100 - (_backgroundAnimation.value * 20),
              left: -100 + (_backgroundAnimation.value * 40),
              child: Transform.scale(
                scale: 0.7 + (_backgroundAnimation.value * 0.3),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor.withOpacity(
                      0.02 * _backgroundAnimation.value,
                    ),
                  ),
                ),
              ),
            ),
            // Líneas sutiles animadas
            Positioned(
              top: MediaQuery.of(context).size.height * 0.25,
              right: 20,
              child: Transform.translate(
                offset: Offset(0, -_backgroundAnimation.value * 20),
                child: Container(
                  width: 2,
                  height: 120 * _backgroundAnimation.value,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primaryColor.withOpacity(
                          0.1 * _backgroundAnimation.value,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Puntos flotantes
            ...List.generate(3, (index) {
              return Positioned(
                top: 100.0 + (index * 150),
                left: 30.0 + (index * 50),
                child: Transform.translate(
                  offset: Offset(
                    _backgroundAnimation.value * (index + 1) * 10,
                    _backgroundAnimation.value * (index + 1) * 5,
                  ),
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryColor.withOpacity(
                        0.1 * _backgroundAnimation.value,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildAnimatedLogoSection() {
    return AnimatedBuilder(
      animation: Listenable.merge([_logoScaleAnimation, _logoFadeAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _logoScaleAnimation.value,
          child: Opacity(
            opacity: _logoFadeAnimation.value,
            child: SvgPicture.asset(
              'assets/images/service_flow_logo.svg',
              height: 120, // Logo más grande
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedTextSection(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_textFadeAnimation, _textSlideAnimation]),
      builder: (context, child) {
        return SlideTransition(
          position: _textSlideAnimation,
          child: FadeTransition(
            opacity: _textFadeAnimation,
            child: Column(
              children: [
                // Título principal
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primaryDarkColor,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                      letterSpacing: -0.5,
                    ),
                    children: [
                      const TextSpan(text: 'Gestiona tus servicios con '),
                      TextSpan(
                        text: 'eficiencia',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const TextSpan(text: ' y dale '),
                      TextSpan(
                        text: 'flow',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const TextSpan(text: ' a tu negocio.'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Descripción
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'Optimiza la asignación de tareas, monitorea a tus técnicos en tiempo real y ofrece un servicio excepcional a tus clientes.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondaryColor,
                      height: 1.6,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButtonsSection(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_buttonsSlideAnimation, _buttonsFadeAnimation]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _buttonsSlideAnimation.value),
          child: Opacity(
            opacity: _buttonsFadeAnimation.value,
            child: Column(
              children: [
                // Botón principal más pequeño
                Container(
                  width: double.infinity,
                  height: 48, // Reducido de 56 a 48
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12), // Reducido de 16 a 12
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withBlue(
                          (AppColors.primaryColor.blue + 30).clamp(0, 255),
                        ),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.25),
                        blurRadius: 8, // Reducido de 12 a 8
                        offset: const Offset(0, 4), // Reducido de 6 a 4
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => context.push('/login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            fontSize: 15, // Reducido de 16 a 15
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6), // Reducido de 8 a 6
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18, // Reducido de 20 a 18
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14), // Reducido de 16 a 14

                // Botón secundario más pequeño
                Container(
                  width: double.infinity,
                  height: 48, // Reducido de 56 a 48
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: OutlinedButton(
                    onPressed: _launchURL,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                      foregroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add_outlined,
                          size: 18, // Reducido de 20 a 18
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(width: 6), // Reducido de 8 a 6
                        const Text(
                          'Crear cuenta',
                          style: TextStyle(
                            fontSize: 15, // Reducido de 16 a 15
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20), // Reducido de 24 a 20

                // Texto adicional sutil
                Text(
                  '¿Ya tienes una cuenta? Inicia sesión para continuar',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryColor.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}