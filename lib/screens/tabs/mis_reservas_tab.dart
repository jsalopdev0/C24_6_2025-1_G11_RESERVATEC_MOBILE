import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:reservatec/widgets/app_tab_header.dart';

class MisReservasTab extends StatefulWidget {
  const MisReservasTab({super.key});

  @override
  State<MisReservasTab> createState() => _MisReservasTabState();
}

class _MisReservasTabState extends State<MisReservasTab> {
  DateTime selectedDate = DateTime.now();

  final List<Color> colores = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
  ];

  List<Map<String, String>> getReservas() {
    final formatter = DateFormat("EEEE, d MMMM yyyy", 'es_ES');
    final fecha = formatter.format(selectedDate);

    return List.generate(10, (index) {
      return {
        'espacio': 'Campo de Fútbol 1',
        'hora': '08:30 - 10:30 AM',
        'fecha': fecha,
        'color': colores[index % colores.length].value.toString(),
      };
    });
  }

  Future<void> _seleccionarFecha() async {
    DateTime? nuevaFecha = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2023),
      lastDate: DateTime(2026),
      locale: const Locale('es', 'ES'),
    );

    if (nuevaFecha != null) {
      setState(() {
        selectedDate = nuevaFecha;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservas = getReservas();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            AppTabHeaderAcciones(
              title: 'Mis Reservas',
              acciones: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Aquí puedes abrir un modal o navegación
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _seleccionarFecha,
                ),
              ],
            ),

            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: reservas.length,
                itemBuilder: (context, index) {
                  final item = reservas[index];
                  final color = Color(int.parse(item['color']!));

                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.flag, color: Colors.white),
                      title: Text(
                        item['espacio']!,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['hora']!,
                              style: TextStyle(color: Colors.white, fontSize: 14.sp)),
                          Text(item['fecha']!,
                              style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                        ],
                      ),
                      trailing: const Icon(Icons.share, color: Colors.white),
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
