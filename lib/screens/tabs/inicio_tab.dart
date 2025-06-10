import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:reservatec/models/reserva.dart';
import 'package:reservatec/services/reserva_service.dart';
import 'package:reservatec/services/storage.dart';

class InicioTab extends StatefulWidget {
  final VoidCallback? onReservarAhora;

  const InicioTab({super.key, this.onReservarAhora});

  @override
  State<InicioTab> createState() => _InicioTabState();
}

class _InicioTabState extends State<InicioTab> {
  String userName = '';
  List<Reserva> reservasRecientes = [];
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadReservas();
  }

  Future<void> _loadUser() async {
    final session = await Storage.getUserSession();
    if (session != null && session["name"] != null) {
      setState(() {
        userName = session["name"]!.split(' ').first;
      });
    }
  }

  Future<void> _loadReservas() async {
    setState(() => _cargando = true);
    try {
      final reservas = await ReservaService.obtenerMisReservas();
      reservas.sort((a, b) => b.fecha.compareTo(a.fecha));
      setState(() {
        reservasRecientes = reservas.take(5).toList();
      });
    } catch (e) {
      debugPrint('❌ Error cargando reservas: $e');
    }
    setState(() => _cargando = false);
  }

  String formatearFecha(String fechaISO) {
    final fecha = DateTime.parse(fechaISO);
    return DateFormat("EEEE, d 'de' MMMM 'de' y", 'es_ES').format(fecha);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadReservas,
        color: const Color(0xFF00AEEF),
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            Text(
              "Hola, $userName 👋",
              style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: const Color(0xFF0066FF),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Porque tu bienestar empieza aquí:\nreserva, juega y gana',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: widget.onReservarAhora,
                    icon: const Icon(Icons.calendar_today),
                    label: const Text("Reservar Ahora"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                '👉 Recuerda confirmar tu asistencia apenas llegues. ¡Es rápido y ayuda a mantener tu historial limpio!',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Text(
                'Haz de cada reserva una victoria personal 💪',
                style: GoogleFonts.poppins(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              "Tus reservas recientes:",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12.h),
            if (_cargando)
              const Center(child: CircularProgressIndicator())
            else if (reservasRecientes.isEmpty)
              Text("No hay reservas recientes.",
                  style: TextStyle(fontSize: 14.sp, color: Colors.black54))
            else
              ...reservasRecientes.map((r) => ListTile(
                    leading: Icon(Icons.calendar_month, color: Colors.blue),
                    title: Text("Espacio: ${r.espacio}"),
                    subtitle: Text(
                      "${formatearFecha(r.fecha)} | ${r.horaInicio} a ${r.horaFin}",
                    ),
                  )),
          ],
        ),
      ),
    );
  }
}
