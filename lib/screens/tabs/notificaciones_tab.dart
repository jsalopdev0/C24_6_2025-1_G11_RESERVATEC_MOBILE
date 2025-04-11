import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:reservatec/widgets/app_tab_header.dart';

class NotificacionesTab extends StatelessWidget {
  const NotificacionesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> notificaciones = List.generate(5, (index) {
      return {
        'mensaje': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis fringilla diam et turpis semper viverra.',
        'hora': '10:30 AM'
      };
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppTabHeader(title: 'Notificaciones'),

            // Fecha
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                'Hoy, 19 Noviembre',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
            ),

            SizedBox(height: 12.h),

            // Lista de notificaciones
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: notificaciones.length,
                itemBuilder: (context, index) {
                  final noti = notificaciones[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                noti['mensaje']!,
                                style: TextStyle(fontSize: 14.sp),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Text(
                              noti['hora']!,
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
