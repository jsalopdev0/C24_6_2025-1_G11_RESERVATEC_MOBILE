import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reservatec/services/reserva_service.dart';
import '../widgets/reserva_step_indicator.dart';
import '../widgets/contador_reserva.dart';
import '../services/timer_service.dart';
import '../widgets/modal_compartir_reserva.dart';

class ComprobarReservaScreen extends StatefulWidget {
  final int reservaId;
  final String espacio;
  final String imagen;
  final String horario;
  final String fecha;

  const ComprobarReservaScreen({
    super.key,
    required this.reservaId,
    required this.espacio,
    required this.imagen,
    required this.horario,
    required this.fecha,
  });

  @override
  State<ComprobarReservaScreen> createState() => _ComprobarReservaScreenState();
}

class _ComprobarReservaScreenState extends State<ComprobarReservaScreen> {
  final GlobalKey _capturaKey = GlobalKey();

  void _mostrarTerminosUso(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 20.h,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Términos de uso',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12.h),
            Text(
              'Al usar esta aplicación, aceptas seguir las normas de convivencia establecidas por la institución.\n\n'
              '• No está permitido reservar múltiples espacios en el mismo horario ni transferir reservas a otros usuarios.\n'
              '• Solo puedes cancelar una reserva con al menos 30 min de anticipación.\n'
              '• Debes confirmar tu asistencia antes de usar el campo.\n'
              '• Tienes 10 min de tolerancia. Si incumples, tu reserva será cancelada automáticamente.\n\n'
              'El uso indebido puede conllevar sanciones, incluyendo la suspensión temporal para nuevas reservas.',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[800],
                height: 1.5,
              ),
              textAlign: TextAlign.justify,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AEEF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text('Aceptar', style: TextStyle(fontSize: 15.sp)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          await ReservaService.cancelarReservaTemporal(widget.reservaId);
          debugPrint(
              'Reserva cancelada automáticamente al volver desde comprobar');
        } catch (e) {
          debugPrint('Error al cancelar reserva temporal: $e');
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(80.h),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      try {
                        await ReservaService.cancelarReservaTemporal(
                            widget.reservaId);
                        debugPrint('Reserva cancelada desde botón ←');
                      } catch (e) {
                        debugPrint('Error al cancelar desde botón: $e');
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Comprobar Reserva',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: SizedBox(
                height: 40.h,
                child: Stack(
                  children: [
                    const ReservaStepIndicator(activeStep: 2),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: EdgeInsets.only(right: 4.w),
                        child: const ContadorReserva(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Por favor, verifica los datos antes de confirmar tu reserva.',
                        style: TextStyle(
                            fontSize: 15.sp, color: Colors.grey[700])),
                    SizedBox(height: 16.h),
                    Container(
                      height: 160.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Transform.rotate(
                              angle: Theme.of(context).platform ==
                                      TargetPlatform.android
                                  ? 3.1416
                                  : 0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16.r),
                                child: widget.imagen.startsWith('http')
                                    ? Image.network(
                                        widget.imagen,
                                        fit: BoxFit.cover,
                                        color: Colors.black.withOpacity(0.25),
                                        colorBlendMode: BlendMode.darken,
                                      )
                                    : Image.asset(
                                        widget.imagen,
                                        fit: BoxFit.cover,
                                        color: Colors.black.withOpacity(0.25),
                                        colorBlendMode: BlendMode.darken,
                                      ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: Padding(
                              padding: EdgeInsets.all(12.w),
                              child: Text(
                                widget.espacio,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  shadows: const [
                                    Shadow(
                                        color: Colors.black54, blurRadius: 3),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 20),
                        SizedBox(width: 8.w),
                        Text(widget.fecha, style: TextStyle(fontSize: 16.sp)),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 20),
                        SizedBox(width: 8.w),
                        Text(widget.horario, style: TextStyle(fontSize: 16.sp)),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    GestureDetector(
                      onTap: () => _mostrarTerminosUso(context),
                      child: Padding(
                        padding: EdgeInsets.only(top: 12.h),
                        child: RichText(
                          text: TextSpan(
                            text:
                                'Al confirmar esta reserva, estás aceptando los ',
                            style: TextStyle(
                                fontSize: 13.sp, color: Colors.grey[600]),
                            children: [
                              TextSpan(
                                text:
                                    'términos de uso de los espacios deportivos.',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.blueAccent,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: Colors.orangeAccent),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              '• Solo puedes cancelar con 30 min de anticipación.\n'
                              '• Debes confirmar tu asistencia antes de usar el campo.\n'
                              '• Tienes 10 min de tolerancia. Si incumples, tu reserva será cancelada automáticamente y deberás esperar 1 semana para reservar.',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.orange[900],
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await ReservaService.confirmarReserva(
                                widget.reservaId);
                            await ReservaService.obtenerMisReservas();
                            TimerService.detener();

                            await showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (_) => ModalCompartirReserva(
                                espacio: widget.espacio,
                                imagen: widget.imagen,
                                horario: widget.horario,
                                fecha: widget.fecha,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  e.toString().replaceFirst('Exception: ', ''),
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                backgroundColor: Color(0xFFF7CC41),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text('Finalizar reserva',
                            style: TextStyle(fontSize: 16.sp)),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
