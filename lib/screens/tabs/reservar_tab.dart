import 'package:flutter/material.dart';
import '../seleccionar_espacio_screen.dart';

class ReservarTab extends StatelessWidget {
  const ReservarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const SeleccionarEspacioScreen(),
        );
      },
    );
  }
}
