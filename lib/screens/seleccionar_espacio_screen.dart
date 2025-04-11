import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'seleccionar_horario_screen.dart';
import '../widgets/app_tab_header.dart';

class SeleccionarEspacioScreen extends StatelessWidget {
  const SeleccionarEspacioScreen({super.key});

  final List<Map<String, String>> espacios = const [
    {
      'nombre': 'Campo de Basket o Voley',
      'imagen': 'assets/images/basket_voley.jpg',
    },
    {
      'nombre': 'Campo de Fútbol 1',
      'imagen': 'assets/images/basket_voley.jpg',
    },
    {
      'nombre': 'Campo de Ping Pong',
      'imagen': 'assets/images/basket_voley.jpg',
    },
    {
      'nombre': 'Campo de Fútbol 2',
      'imagen': 'assets/images/basket_voley.jpg',
    },
    {
      'nombre': 'Campo de Frontón',
      'imagen': 'assets/images/basket_voley.jpg',
    },
    {
      'nombre': 'Tablero de Ajedrez',
      'imagen': 'assets/images/basket_voley.jpg',
    },
    {
      'nombre': 'Fútbol de Mesa',
      'imagen': 'assets/images/basket_voley.jpg',
    },
    {
      'nombre': 'Tablero de Ludo',
      'imagen': 'assets/images/basket_voley.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.h),
        child: const SafeArea(
          child: AppTabHeader(title: 'Seleccionar Espacio'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: GridView.builder(
          itemCount: espacios.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.1,
          ),
          itemBuilder: (context, index) {
            final espacio = espacios[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SeleccionarHorarioScreen(
                      nombreEspacio: espacio['nombre']!,
                      imagen: espacio['imagen']!,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  image: DecorationImage(
                    image: AssetImage(espacio['imagen']!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.25),
                      BlendMode.darken,
                    ),
                  ),
                ),
                alignment: Alignment.bottomLeft,
                padding: EdgeInsets.all(12.w),
                child: Text(
                  espacio['nombre']!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 3)
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
