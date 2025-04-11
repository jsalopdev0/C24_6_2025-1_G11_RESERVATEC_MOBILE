import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/reserva_step_indicator.dart';

class ComprobarReservaScreen extends StatelessWidget {
  final String espacio;
  final String imagen;
  final String horario;
  final String fecha;

  const ComprobarReservaScreen({
    super.key,
    required this.espacio,
    required this.imagen,
    required this.horario,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.h),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Comprobar Reserva',
                  style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ReservaStepIndicator(activeStep: 2),
            SizedBox(height: 24.h),
            Text(
              'Por favor, verifica los datos antes de confirmar tu reserva.',
              style: TextStyle(fontSize: 15.sp, color: Colors.grey[700]),
            ),
            SizedBox(height: 16.h),
            Container(
              height: 160.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                image: DecorationImage(
                  image: imagen.startsWith('http')
                      ? NetworkImage(imagen)
                      : AssetImage(imagen) as ImageProvider,
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
                espacio,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  shadows: const [Shadow(color: Colors.black54, blurRadius: 3)],
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 20),
                SizedBox(width: 8.w),
                Text(fecha, style: TextStyle(fontSize: 16.sp)),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                const Icon(Icons.schedule, size: 20),
                SizedBox(width: 8.w),
                Text(horario, style: TextStyle(fontSize: 16.sp)),
              ],
            ),
            SizedBox(height: 24.h),
            Text(
              'Al confirmar esta reserva, estás aceptando los términos de uso de los espacios deportivos.',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Imagen
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: imagen.startsWith('http')
                                    ? Image.network(
                                        imagen,
                                        height: 140,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        imagen,
                                        height: 140,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              const SizedBox(height: 8),

                              // Nombre del espacio
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  espacio,
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Hora
                              Row(
                                children: [
                                  const Icon(Icons.schedule, size: 18, color: Colors.black54),
                                  const SizedBox(width: 6),
                                  Text(horario, style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 4),

                              // Fecha
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      size: 18, color: Colors.black54),
                                  const SizedBox(width: 6),
                                  Text(fecha, style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // Mensaje
                              const Text(
                                'Puedes visualizar tus reservas en la sección “Mis reservas”.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, color: Colors.black87),
                              ),
                              const SizedBox(height: 24),

                              // Botón Compartir
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  icon: const Icon(Icons.share, size: 20),
                                  label: const Text('Compartir reserva'),
                                  onPressed: () {
                                    Navigator.pop(context); // Cierra el modal
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    side: const BorderSide(color: Colors.blueAccent),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );

                  // Al cerrar el modal, volver a inicio del flujo
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Finalizar reserva', style: TextStyle(fontSize: 16.sp)),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
