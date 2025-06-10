import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../screens/home_screen.dart';
import '../services/storage.dart';

class ModalCompartirReserva extends StatefulWidget {
  final String espacio;
  final String imagen;
  final String horario;
  final String fecha;

  const ModalCompartirReserva({
    super.key,
    required this.espacio,
    required this.imagen,
    required this.horario,
    required this.fecha,
  });

  @override
  State<ModalCompartirReserva> createState() => _ModalCompartirReservaState();
}

class _ModalCompartirReservaState extends State<ModalCompartirReserva> {
  final GlobalKey _capturaKey = GlobalKey();

  Future<void> _capturarYCompartir() async {
    try {
      final boundary = _capturaKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File(
              '${tempDir.path}/reserva_${DateTime.now().millisecondsSinceEpoch}.png')
          .create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path, mimeType: 'image/png')],
          subject: 'Mi reserva en ReservaTec');

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error al compartir: $e');
    }
  }

  Future<void> _salirAlHome() async {
    final userData = await Storage.getUserSession();
    final userId = await Storage.getUserId();

    if (userData != null && userId != null && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            name: userData["name"]!,
            email: userData["email"]!,
            photoUrl: userData["photo"]!,
            accessToken: userData["token"]!,
            userId: userId,
            initialTabIndex: 2,
          ),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: Colors.grey[100],
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RepaintBoundary(
              key: _capturaKey,
              child: Container(
                padding: EdgeInsets.all(16.w), 
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: widget.imagen.startsWith('http')
                          ? Image.network(
                              widget.imagen,
                              height: 120.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              widget.imagen,
                              height: 120.h,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      widget.espacio,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '${widget.horario} | ${widget.fecha}',
                      style: TextStyle(fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _capturarYCompartir,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00AEEF),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Compartir imagen',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
