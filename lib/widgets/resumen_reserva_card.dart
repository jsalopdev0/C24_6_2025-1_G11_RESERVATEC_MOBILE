// widgets/resumen_reserva_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResumenReservaCard extends StatelessWidget {
  final String espacio;
  final String horario;
  final String fecha;
  final String imagen;

  const ResumenReservaCard({
    super.key,
    required this.espacio,
    required this.horario,
    required this.fecha,
    required this.imagen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: Image.asset(imagen, height: 160.h, fit: BoxFit.cover),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(espacio, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Text('Horario: $horario', style: TextStyle(fontSize: 15.sp)),
                SizedBox(height: 4.h),
                Text('Fecha: $fecha', style: TextStyle(fontSize: 15.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
