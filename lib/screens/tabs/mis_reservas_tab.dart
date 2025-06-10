import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:reservatec/models/reserva.dart';
import 'package:reservatec/services/reserva_service.dart';
import 'package:reservatec/services/storage.dart'; // 👈 Asegúrate de importar Storage
import 'package:reservatec/widgets/app_tab_header.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:reservatec/widgets/confirmar_cancelar_reserva_modal.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/rendering.dart';

class MisReservasTab extends StatefulWidget {
  final int usuarioId;

  const MisReservasTab({super.key, required this.usuarioId});

  @override
  State<MisReservasTab> createState() => _MisReservasTabState();
}

class _MisReservasTabState extends State<MisReservasTab> {
  late Future<List<Reserva>> _futureReservas = Future.value([]);
  List<Reserva> _reservasActuales = [];
  DateTime? filtroFecha;
  List<String> filtroEstados = [];
  StompClient? stompClient;
  bool _cargando = true;
  @override
  void initState() {
    super.initState();
    _inicializar();
    Storage.getUserId().then((usuarioId) {
      if (usuarioId != null) {
        _conectarWebSocket(usuarioId);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Future.delayed(const Duration(milliseconds: 300), _cargarReservas);
  }

  Future<void> _inicializar() async {
    await _cargarReservas();
    final usuarioId = await Storage.getUserId();
    if (usuarioId != null) {
      _conectarWebSocket(usuarioId);
    }
  }

  void _conectarWebSocket(int usuarioId) {
    Storage.getUserSession().then((session) {
      final token = session?['token'];

      stompClient = StompClient(
        config: StompConfig.SockJS(
          url:
              'hhttps://reservatec-tesis-backend-8asuen-626be2-31-220-104-112.traefik.me/ws',

          onConnect: (StompFrame frame) {
            stompClient!.subscribe(
              destination: '/topic/reservas/$usuarioId',
              callback: (StompFrame frame) {
                if (!mounted) return;

                if (frame.body == 'actualizar') {
                  print("📥 WebSocket: recargando reservas");
                  _cargarReservas();
                }
              },
            );
          },
          webSocketConnectHeaders: {
            'Authorization': 'Bearer $token',
          },
          onWebSocketError: (dynamic error) => print('Error WS: $error'),
        ),
      );

      stompClient!.activate();
    });
  }

  @override
  void dispose() {
    stompClient?.deactivate();
    super.dispose();
  }

  Future<void> _cargarReservas() async {
    setState(() => _cargando = true);
    final nuevasReservas = await ReservaService.obtenerMisReservas();
    nuevasReservas.sort((a, b) => b.fecha.compareTo(a.fecha));

    if (!mounted) return;

    final diferentes = nuevasReservas.length != _reservasActuales.length ||
        !nuevasReservas.asMap().entries.every((entry) {
          final index = entry.key;
          final nueva = entry.value;
          final actual = _reservasActuales.length > index
              ? _reservasActuales[index]
              : null;
          return actual != null &&
              nueva.id == actual.id &&
              nueva.estado == actual.estado;
        });

    if (diferentes) {
      setState(() {
        _reservasActuales = nuevasReservas;
        _futureReservas = Future.value(nuevasReservas);
      });
    }
    setState(() => _cargando = false);
  }

  Future<Map<String, String>> _obtenerHeaders() async {
    final session = await Storage.getUserSession();
    final token = session?['token'];
    return {
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> _seleccionarFecha() async {
    final nuevaFecha = await showDatePicker(
      context: context,
      initialDate: filtroFecha ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF00AEEF),
            dialogBackgroundColor: Colors.white,
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
        filtroFecha = nuevaFecha;
      });
    }
  }

  void _mostrarFiltroEstado() {
    final estadosDisponibles = {
      'ACTIVA': 'Activa',
      'COMPLETADA': 'Completada',
      'CANCELADA': 'Cancelada',
      'CURSO': 'En curso',
    };

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Filtrar por estados',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF00AEEF),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...estadosDisponibles.entries.map((entry) {
                    final isSelected = filtroEstados.contains(entry.key);
                    return CheckboxListTile(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      title: Text(entry.value),
                      activeColor: const Color(0xFF00AEEF),
                      value: isSelected,
                      onChanged: (bool? selected) {
                        setStateModal(() {
                          setState(() {
                            if (selected == true) {
                              filtroEstados.add(entry.key);
                            } else {
                              filtroEstados.remove(entry.key);
                            }
                          });
                        });
                      },
                    );
                  }),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () {
                          setState(() => filtroEstados.clear());
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.clear),
                        label: const Text("Quitar todo"),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00AEEF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.done),
                        label: const Text("Aplicar"),
                      )
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color getColorEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'ACTIVA':
        return Colors.blue;
      case 'COMPLETADA':
        return Colors.green;
      case 'CANCELADA':
        return Colors.red;
      case 'CURSO':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String getNombreVisualEstado(String estado) {
    switch (estado.toUpperCase()) {
      case 'ACTIVA':
        return 'Activa';
      case 'COMPLETADA':
        return 'Completada';
      case 'CANCELADA':
        return 'Cancelada';
      case 'CURSO':
        return 'En curso';
      default:
        return estado;
    }
  }

  String formatFecha(String fechaISO) {
    final fecha = DateTime.parse(fechaISO);
    return DateFormat("EEEE, d MMMM yyyy", 'es_ES').format(fecha);
  }

  List<Reserva> aplicarFiltros(List<Reserva> reservas) {
    return reservas.where((r) {
      final matchEstado = filtroEstados.isEmpty ||
          filtroEstados.contains(r.estado.toUpperCase());
      final matchFecha = filtroFecha == null ||
          DateTime.parse(r.fecha).year == filtroFecha!.year &&
              DateTime.parse(r.fecha).month == filtroFecha!.month &&
              DateTime.parse(r.fecha).day == filtroFecha!.day;
      return matchEstado && matchFecha;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final reservasFiltradas = aplicarFiltros(_reservasActuales);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            AppTabHeaderAcciones(
              title: 'Mis Reservas',
              acciones: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Actualizar reservas',
                  onPressed: _cargarReservas,
                ),
                if (filtroEstados.isNotEmpty || filtroFecha != null)
                  IconButton(
                    icon: const Icon(Icons.clear_all),
                    tooltip: 'Limpiar filtros',
                    onPressed: () {
                      setState(() {
                        filtroEstados.clear();
                        filtroFecha = null;
                      });
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filtrar por estado',
                  onPressed: _mostrarFiltroEstado,
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  tooltip: 'Filtrar por fecha',
                  onPressed: _seleccionarFecha,
                ),
              ],
            ),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (_cargando) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (reservasFiltradas.isEmpty) {
                    return const Center(
                        child: Text('No se encontraron reservas'));
                  } else {
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      itemCount: reservasFiltradas.length,
                      itemBuilder: (context, index) {
                        final r = reservasFiltradas[index];
                        final color = getColorEstado(r.estado);
                        final GlobalKey capturaKey = GlobalKey();

                        return RepaintBoundary(
                          key: capturaKey,
                          child: Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: color,
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12.r)),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 8.h),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.flag,
                                          color: Colors.white, size: 18),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              r.espacio,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16.sp,
                                              ),
                                            ),
                                            SizedBox(height: 2.h),
                                            Text(
                                              'Código: ${r.codigoReserva}',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (r.estado.toUpperCase() == 'ACTIVA')
                                        GestureDetector(
                                          onTap: () async {
                                            showGeneralDialog(
                                              context: context,
                                              barrierDismissible: true,
                                              barrierLabel: 'cancelar_reserva',
                                              pageBuilder: (_, __, ___) {
                                                return ConfirmarCancelarReservaModal(
                                                  onConfirmar: () async {
                                                    try {
                                                      await ReservaService
                                                          .cancelarReserva(
                                                              r.id);

                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                            'Reserva cancelada correctamente',
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                          backgroundColor:
                                                              Colors.green,
                                                        ),
                                                      );

                                                      _cargarReservas();
                                                    } catch (e) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                            e
                                                                .toString()
                                                                .replaceFirst(
                                                                    'Exception: ',
                                                                    ''),
                                                            style: const TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .black87),
                                                          ),
                                                          backgroundColor:
                                                              const Color(
                                                                  0xFFFFF3CD),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          child: const Icon(Icons.cancel,
                                              color: Colors.white, size: 18),
                                        ),
                                      const SizedBox(width: 8),
                                      GestureDetector(
                                        onTap: () async {
                                          try {
                                            final boundary = capturaKey
                                                    .currentContext
                                                    ?.findRenderObject()
                                                as RenderRepaintBoundary?;
                                            if (boundary == null) return;

                                            final image = await boundary
                                                .toImage(pixelRatio: 3.0);
                                            final byteData =
                                                await image.toByteData(
                                                    format:
                                                        ui.ImageByteFormat.png);
                                            final pngBytes =
                                                byteData!.buffer.asUint8List();

                                            final tempDir =
                                                await getTemporaryDirectory();
                                            final file = await File(
                                                    '${tempDir.path}/reserva_${DateTime.now().millisecondsSinceEpoch}.png')
                                                .create();
                                            await file.writeAsBytes(pngBytes);

                                            await Share.shareXFiles(
                                              [
                                                XFile(file.path,
                                                    mimeType: 'image/png')
                                              ],
                                              subject:
                                                  'Mira mi reserva en ReservaTec',
                                            );
                                          } catch (e) {
                                            debugPrint(
                                                'Error al compartir reserva: $e');
                                          }
                                        },
                                        child: const Icon(Icons.share,
                                            color: Colors.white, size: 18),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12.w, vertical: 8.h),
                                  child: Row(
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time,
                                              size: 16),
                                          SizedBox(width: 4.w),
                                          Text('${r.horaInicio} - ${r.horaFin}',
                                              style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 14.sp)),
                                        ],
                                      ),
                                      const Spacer(),
                                      Text(formatFecha(r.fecha),
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 14.sp)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
