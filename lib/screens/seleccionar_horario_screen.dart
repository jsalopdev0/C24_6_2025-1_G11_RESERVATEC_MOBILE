import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../screens/comprobar_reserva_screen.dart';
import '../widgets/reserva_step_indicator.dart';
import '../widgets/app_tab_header.dart';

class SeleccionarHorarioScreen extends StatefulWidget {
  final String nombreEspacio;
  final String imagen;

  const SeleccionarHorarioScreen({
    super.key,
    required this.nombreEspacio,
    required this.imagen,
  });

  @override
  State<SeleccionarHorarioScreen> createState() =>
      _SeleccionarHorarioScreenState();
}

class _SeleccionarHorarioScreenState extends State<SeleccionarHorarioScreen> {
  final List<String> horarios = [
    '08:00 AM',
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
  ];

  String? horaInicio;
  String? horaFin;

  void seleccionarHora(String hora) {
    if (horaInicio == null) {
      setState(() => horaInicio = hora);
    } else if (horaFin == null && hora != horaInicio) {
      setState(() => horaFin = hora);
    } else {
      setState(() {
        horaInicio = hora;
        horaFin = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const fecha = 'Viernes, 10 de abril';

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
                  'Seleccionar Horario', // Cambia según el screen
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
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
            const ReservaStepIndicator(activeStep: 1),
            SizedBox(height: 16.h),
            Text('Espacio Seleccionado:', style: TextStyle(fontSize: 16.sp)),
            SizedBox(height: 8.h),
            Container(
              height: 160.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                image: DecorationImage(
                  image: AssetImage(widget
                      .imagen), // Usa AssetImage o NetworkImage según corresponda
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.25), BlendMode.darken),
                ),
              ),
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.all(12.w),
              child: Text(
                widget.nombreEspacio,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp),
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 20),
                SizedBox(width: 8.w),
                Text(fecha, style: TextStyle(fontSize: 16.sp)),
              ],
            ),
            SizedBox(height: 16.h),
            Wrap(
              spacing: 10.w,
              runSpacing: 10.h,
              children: horarios.map((hora) {
                final seleccionado = hora == horaInicio || hora == horaFin;
                return GestureDetector(
                  onTap: () => seleccionarHora(hora),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: seleccionado
                            ? Colors.blueAccent
                            : Colors.grey.shade300,
                      ),
                      color: seleccionado
                          ? Colors.blueAccent.withOpacity(0.15)
                          : Colors.white,
                    ),
                    child: Text(
                      hora,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color:
                            seleccionado ? Colors.blueAccent : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24.h),
            Text(
              'Recuerda: Solo puedes separar máximo 2 horas seguidas y una vez por semana.',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: horaInicio != null
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ComprobarReservaScreen(
                              espacio: widget.nombreEspacio,
                              imagen: widget.imagen,
                              horario:
                                  '$horaInicio${horaFin != null ? ' - $horaFin' : ''}',
                              fecha: fecha,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text('Continuar', style: TextStyle(fontSize: 16.sp)),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
