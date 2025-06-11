import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../models/horario.dart';
import '../models/reserva.dart';
import '../services/horario_service.dart';
import '../services/reserva_service.dart';
import '../screens/comprobar_reserva_screen.dart';
import '../widgets/reserva_step_indicator.dart';
import '../widgets/contador_reserva.dart';
import '../services/timer_service.dart';

class SeleccionarHorarioScreen extends StatefulWidget {
  final int espacioId;
  final String nombreEspacio;
  final String imagen;

  const SeleccionarHorarioScreen({
    super.key,
    required this.espacioId,
    required this.nombreEspacio,
    required this.imagen,
  });

  @override
  State<SeleccionarHorarioScreen> createState() =>
      _SeleccionarHorarioScreenState();
}

class _SeleccionarHorarioScreenState extends State<SeleccionarHorarioScreen> {
  List<Horario> horarios = [];
  List<int> horariosOcupados = [];
  List<DateTime> fechasNoDisponibles = [];
  Horario? seleccionado;
  DateTime fechaSeleccionada = DateTime.now();
  bool cargando = true;
  Reserva? reservaPendiente;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    TimerService.iniciar();
    _cargarFechasNoDisponibles();
    _cargarHorarios();
    _verificarReservaPendiente();
  }

  Future<void> _cargarFechasNoDisponibles() async {
    try {
      fechasNoDisponibles =
          await HorarioService.obtenerFechasOcupadas(widget.espacioId);
    } catch (e) {
      print("❌ Error al cargar fechas ocupadas: $e");
    }
  }

  Future<void> _cargarHorarios() async {
    try {
      print("🕒 Solicitando horarios ocupados para: $fechaSeleccionada");

      final resultado = await HorarioService.obtenerHorariosActivos();
      final ocupados = await HorarioService.obtenerHorariosOcupados(
          widget.espacioId, fechaSeleccionada);

      print("✅ Horarios activos: ${resultado.map((h) => h.id).toList()}");
      print("❌ Horarios ocupados: $ocupados");

      setState(() {
        horarios = resultado;
        horariosOcupados = ocupados;
        cargando = false;
      });
    } catch (e) {
      print("❌ Error al cargar horarios: $e");
      setState(() => cargando = false);
    }
  }

  void _verificarReservaPendiente() async {
    try {
      final reservas = await ReservaService.obtenerMisReservas();
      final pendientes =
          reservas.where((r) => r.estado == 'PENDIENTE').toList();
      if (pendientes.isNotEmpty) {
        setState(() => reservaPendiente = pendientes.first);
      }
    } catch (e) {
      print('⚠️ Error al verificar reserva pendiente: $e');
    }
  }

  Future<void> _seleccionarFecha() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final DateTime? nuevaFecha = await showDatePicker(
      context: context,
      initialDate:
          fechaSeleccionada.isBefore(today) ? today : fechaSeleccionada,
      firstDate: today,
      lastDate: today.add(const Duration(days: 30)),
      locale: const Locale('es', 'ES'),
      selectableDayPredicate: (date) => !fechasNoDisponibles
          .contains(DateTime(date.year, date.month, date.day)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF00AEEF),
            dialogBackgroundColor: Colors.grey[100],
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00AEEF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (nuevaFecha != null) {
      setState(() {
        fechaSeleccionada = nuevaFecha;
        cargando = true;
      });
      await _cargarHorarios();
    }
  }

  String formatearFecha(DateTime fecha) {
    final formatter = DateFormat.yMMMMEEEEd('es_ES');
    return formatter
        .format(fecha)
        .replaceFirstMapped(RegExp(r'^\w'), (m) => m.group(0)!.toUpperCase());
  }

  @override
  Widget build(BuildContext context) {
    final fechaFormateada = formatearFecha(fechaSeleccionada);

    return WillPopScope(
      onWillPop: () async {
        try {
          if (reservaPendiente != null) {
            await ReservaService.cancelarReservaTemporal(reservaPendiente!.id);
            debugPrint('✅ Reserva temporal cancelada');
          }
        } catch (e) {
          debugPrint('❌ Error al cancelar reserva pendiente: $e');
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
                        if (reservaPendiente != null) {
                          await ReservaService.cancelarReservaTemporal(
                              reservaPendiente!.id);
                          debugPrint(
                              '✅ Reserva temporal cancelada desde botón');
                        }
                      } catch (e) {
                        debugPrint('❌ Error desde botón: $e');
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Icon(Icons.arrow_back),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Seleccionar Horario',
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
        body: cargando
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: SizedBox(
                      height: 40.h,
                      child: Stack(
                        children: [
                          const ReservaStepIndicator(activeStep: 1),
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
                          SizedBox(height: 12.h),
                          Text('Espacio Seleccionado:',
                              style: TextStyle(fontSize: 16.sp)),
                          SizedBox(height: 8.h),
                          Container(
                              height: 160.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            widget.imagen,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return const Center(
                                                  child:
                                                      CircularProgressIndicator());
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Center(
                                                  child: Icon(
                                                      Icons.broken_image,
                                                      size: 40));
                                            },
                                          ),
                                          Container(
                                            color:
                                                Colors.black.withOpacity(0.25),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomLeft,
                                    child: Padding(
                                      padding: EdgeInsets.all(12.w),
                                      child: Text(
                                        widget.nombreEspacio,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                          shadows: const [
                                            Shadow(
                                              color: Colors.black54,
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          SizedBox(height: 24.h),
                          Text('Selecciona la fecha:',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: 8.h),
                          GestureDetector(
                            onTap: _seleccionarFecha,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 14.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.blueAccent),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_today_outlined,
                                      size: 20),
                                  SizedBox(width: 8.w),
                                  Text(fechaFormateada,
                                      style: TextStyle(fontSize: 15.sp)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Text('Selecciona el horario:',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600)),
                          SizedBox(height: 12.h),
                          if (horarios.isEmpty ||
                              horarios.length == horariosOcupados.length)
                            Text(
                              'Todos los horarios ya están reservados para esta fecha.',
                              style: TextStyle(
                                  fontSize: 14.sp, color: Colors.redAccent),
                            ),
                          GridView.count(
                            shrinkWrap: true,
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 2.8,
                            physics: const NeverScrollableScrollPhysics(),
                            children: horarios.map((h) {
                              final now = DateTime.now();
                              final hoy =
                                  DateTime(now.year, now.month, now.day);
                              final seleccionada = DateTime(
                                fechaSeleccionada.year,
                                fechaSeleccionada.month,
                                fechaSeleccionada.day,
                              );

                              final horaInicio = TimeOfDay(
                                hour: int.parse(h.horaInicio.substring(0, 2)),
                                minute: int.parse(h.horaInicio.substring(3, 5)),
                              );

                              final horaFin = TimeOfDay(
                                hour: int.parse(h.horaFin.substring(0, 2)),
                                minute: int.parse(h.horaFin.substring(3, 5)),
                              );

                              final dtInicio = DateTime(
                                fechaSeleccionada.year,
                                fechaSeleccionada.month,
                                fechaSeleccionada.day,
                                horaInicio.hour,
                                horaInicio.minute,
                              );

                              final dtFin = DateTime(
                                fechaSeleccionada.year,
                                fechaSeleccionada.month,
                                fechaSeleccionada.day,
                                horaFin.hour,
                                horaFin.minute,
                              );

                              final esPasado = now.isAfter(dtFin);

                              final enCursoYQuedaPoco = now.isAfter(dtInicio) &&
                                  now.isBefore(dtFin) &&
                                  dtFin.difference(now).inMinutes < 30;

                              final ocupado = horariosOcupados.contains(h.id) ||
                                  esPasado ||
                                  enCursoYQuedaPoco;
                              final esSeleccionado = seleccionado?.id == h.id;

                              return GestureDetector(
                                onTap: ocupado
                                    ? null
                                    : () => setState(() => seleccionado = h),
                                child: Opacity(
                                  opacity: ocupado ? 0.5 : 1,
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.h),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: esSeleccionado
                                            ? Colors.blueAccent
                                            : Colors.grey.shade300,
                                      ),
                                      color: esSeleccionado
                                          ? Colors.blueAccent.withOpacity(0.15)
                                          : Colors.white,
                                    ),
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.schedule,
                                            size: 16,
                                            color:
                                                ocupado ? Colors.grey : null),
                                        SizedBox(width: 6.w),
                                        Text(
                                          '${h.horaInicio.substring(0, 5)} - ${h.horaFin.substring(0, 5)}',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            color: ocupado
                                                ? Colors.grey
                                                : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (seleccionado != null)
                            ? () async {
                                if (_procesando) return;
                                _procesando = true;

                                try {
                                  final reserva =
                                      await ReservaService.crearReservaTemporal(
                                    espacioId: widget.espacioId,
                                    horarioId: seleccionado!.id,
                                    fecha: fechaSeleccionada,
                                  );

                                  final ttl = await ReservaService.obtenerTTL(
                                    widget.espacioId,
                                    seleccionado!.id,
                                    fechaSeleccionada,
                                  );
                                  TimerService.iniciar(desdeRedis: ttl);

                                  final confirmado = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ComprobarReservaScreen(
                                        reservaId: reserva['id'],
                                        espacio: widget.nombreEspacio,
                                        imagen: widget.imagen,
                                        horario:
                                            '${seleccionado!.horaInicio.substring(0, 5)} - ${seleccionado!.horaFin.substring(0, 5)}',
                                        fecha:
                                            formatearFecha(fechaSeleccionada),
                                      ),
                                    ),
                                  );

                                  if (confirmado == true && context.mounted) {
                                    Navigator.pop(context, true);
                                  } else {
                                    await ReservaService
                                        .cancelarReservaTemporal(reserva['id']);
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e
                                            .toString()
                                            .replaceFirst('Exception: ', ''),
                                        style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14.sp),
                                      ),
                                      backgroundColor: const Color(0xFFF7CC41),
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                } finally {
                                  _procesando = false;
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text('Continuar',
                            style: TextStyle(fontSize: 16.sp)),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
