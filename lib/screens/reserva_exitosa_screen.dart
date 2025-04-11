// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:reservatec/screens/home_screen.dart';
// import 'package:reservatec/services/storage.dart';

// class ReservaExitosaScreen extends StatelessWidget {
//   const ReservaExitosaScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     const String espacio = 'Campo de Fútbol 1';
//     const String imagen = 'assets/images/futbol1.jpg'; // Asegúrate de tener esta imagen en assets

//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 '¡Felicidades! la reserva ha sido un éxito.',
//                 style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 20.h),
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12.r),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 4,
//                       offset: Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
//                       child: Image.asset(imagen, height: 140.h, width: double.infinity, fit: BoxFit.cover),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.all(10.w),
//                       child: Text(
//                         espacio,
//                         style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 20.h),
//               Text(
//                 'Solo puedes cancelar tu reserva media hora antes de que empiece.',
//                 style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
//               ),
//               const Spacer(),
//               SizedBox(
//                 width: double.infinity,
//                 child: OutlinedButton(
//                   onPressed: () {
//                     // Opción decorativa por ahora
//                   },
//                   style: OutlinedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(vertical: 14.h),
//                     side: const BorderSide(color: Colors.blueAccent),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//                   ),
//                   child: Text('Compartir reserva', style: TextStyle(fontSize: 15.sp)),
//                 ),
//               ),
//               SizedBox(height: 12.h),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: () async {
//                     final session = await Storage.getUserSession(); // 👈 importante

//                     if (session != null && context.mounted) {
//                       Navigator.pushAndRemoveUntil(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => HomeScreen(
//                             name: session['name'] ?? '',
//                             email: session['email'] ?? '',
//                             photoUrl: session['photo'] ?? '',
//                             accessToken: session['token'] ?? '',
//                             initialTabIndex: 1, // 👈 "Mis reservas"
//                           ),
//                         ),
//                         (route) => false,
//                       );
//                     } else {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(content: Text('No se pudo recuperar la sesión')),
//                       );
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blueAccent,
//                     padding: EdgeInsets.symmetric(vertical: 14.h),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//                   ),
//                   child: Text('Ir a mis reservas', style: TextStyle(fontSize: 15.sp)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
