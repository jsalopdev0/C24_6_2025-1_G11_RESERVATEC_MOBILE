import 'package:flutter/material.dart';
import 'package:reservatec/services/timer_service.dart';
import '../screens/seleccionar_espacio_screen.dart';

class ContadorReserva extends StatefulWidget {
  const ContadorReserva({super.key});

  @override
  State<ContadorReserva> createState() => _ContadorReservaState();
}

class _ContadorReservaState extends State<ContadorReserva> {
  bool redirigido = false; 

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: TimerService.stream,
      initialData: TimerService.segundosRestantes,
      builder: (context, snapshot) {
        final segundos = snapshot.data ?? 0;

        if (segundos <= 0 && !redirigido) {
          redirigido = true;
          Future.microtask(() {
            if (context.mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const SeleccionarEspacioScreen()),
                (route) => false,
              );
            }
          });
        }

        final minutos = (segundos ~/ 60).toString().padLeft(2, '0');
        final segs = (segundos % 60).toString().padLeft(2, '0');

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.timer_outlined, size: 18, color: Color(0xFF00AEEF)),
            const SizedBox(width: 4),
            Text(
              '$minutos:$segs',
              style: TextStyle(
                color: segundos <= 30 ? Colors.red : const Color(0xFF00AEEF),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        );
      },
    );
  }
}
