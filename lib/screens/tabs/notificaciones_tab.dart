import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reservatec/widgets/app_tab_header.dart';
import 'package:reservatec/services/notificacion_service.dart';
import 'package:reservatec/models/notificacion.dart';
import 'package:intl/intl.dart';

class NotificacionesTab extends StatefulWidget {
  const NotificacionesTab({super.key});

  @override
  State<NotificacionesTab> createState() => _NotificacionesTabState();
}

class _NotificacionesTabState extends State<NotificacionesTab> {
  late Future<List<Notificacion>> _futureNotificaciones;

  @override
  void initState() {
    super.initState();
    _loadNotificaciones();
  }

  void _loadNotificaciones() {
    _futureNotificaciones = NotificacionService.obtenerNotificaciones();
  }

  Future<void> _onRefresh() async {
    setState(() {
      _loadNotificaciones();
    });
    await _futureNotificaciones;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppTabHeader(title: 'Alertas'),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'Hoy, ${DateFormat('d MMMM', 'es_PE').format(DateTime.now())}',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: const Color(0xFF00AEEF),
                child: FutureBuilder<List<Notificacion>>(
                  future: _futureNotificaciones,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final notificaciones = snapshot.data ?? [];

                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                      children: notificaciones.isEmpty
                          ? [
                              Padding(
                                padding: EdgeInsets.only(top: 40.h),
                                child: Center(
                                  child: Text(
                                    'No hay notificaciones activas',
                                    style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey[600]),
                                  ),
                                ),
                              )
                            ]
                          : List.generate(notificaciones.length, (index) {
                              final noti = notificaciones[index];
                              final fecha = DateFormat('dd/MM/yyyy')
                                  .format(noti.fechaCreacion);

                              return Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                child: Card(
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          noti.contenido,
                                          style: TextStyle(fontSize: 14.sp),
                                        ),
                                        SizedBox(height: 8.h),
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            fecha,
                                            style: TextStyle(
                                                fontSize: 12.sp,
                                                color: Colors.grey[500]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
