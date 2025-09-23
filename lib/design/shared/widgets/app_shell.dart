// lib/design/shared/widgets/app_shell.dart
import 'package:flutter/material.dart';
import 'package:serviceflow/design/shared/widgets/custom_app_bar.dart';

class AppShell extends StatelessWidget {
  final Widget child;
  final String currentRoute;

  const AppShell({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(currentRoute: currentRoute),
      body: child,
    );
  }
}