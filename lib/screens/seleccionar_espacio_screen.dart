import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/espacio.dart';
import '../services/espacio_service.dart';
import 'seleccionar_horario_screen.dart';
import '../widgets/app_tab_header.dart';
import '../widgets/reserva_step_indicator.dart';
import '../services/timer_service.dart';

class SeleccionarEspacioScreen extends StatefulWidget {
  const SeleccionarEspacioScreen({super.key});

  @override
  State<SeleccionarEspacioScreen> createState() =>
      _SeleccionarEspacioScreenState();
}

class _SeleccionarEspacioScreenState extends State<SeleccionarEspacioScreen>
    with AutomaticKeepAliveClientMixin {
  List<Espacio> espacios = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    TimerService.detener();
    TimerService.iniciar();
    _cargarEspacios();
  }

  Future<void> _cargarEspacios() async {
    try {
      final resultado = await EspacioService.obtenerEspaciosActivos();
      setState(() {
        espacios = resultado;
        cargando = false;
      });
    } catch (e) {
      print("Error al cargar espacios: $e");
      setState(() => cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.h),
        child: const SafeArea(
          child: AppTabHeader(title: 'Seleccionar Espacio'),
        ),
      ),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ReservaStepIndicator(activeStep: 0),
                  SizedBox(height: 16.h),
                  Expanded(
                    child: GridView.builder(
                      itemCount: espacios.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 1.1,
                      ),
                      itemBuilder: (context, index) {
                        final espacio = espacios[index];
                        return GestureDetector(
                          onTap: () async {
                            TimerService.iniciar();
                            final confirmado = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SeleccionarHorarioScreen(
                                  espacioId: espacio.id,
                                  nombreEspacio: espacio.nombre,
                                  imagen: espacio.foto, // ya Cloudinary
                                ),
                              ),
                            );
                            if (confirmado == true && context.mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                          child: Container(
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
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16.r),
                                          child: Image.network(
                                            espacio.foto,
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
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.25),
                                            borderRadius:
                                                BorderRadius.circular(16.r),
                                          ),
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
                                      espacio.nombre,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        shadows: const [
                                          Shadow(
                                            color: Colors.black54,
                                            blurRadius: 3,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
