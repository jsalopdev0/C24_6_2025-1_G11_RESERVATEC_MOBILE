import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reservatec/services/storage.dart';
import 'package:reservatec/services/auth_service.dart';
import 'package:reservatec/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GoogleSignIn getSignInInstance() {
    return GoogleSignIn(scopes: ['email', 'profile']);
  }

  Future<void> handleGoogleSignIn() async {
    final signIn = getSignInInstance();
    try {
      final user = await signIn.signIn();
      if (user == null) return;

      final auth = await user.authentication;
      final name = user.displayName ?? "Sin nombre";
      final email = user.email;
      final photo = user.photoUrl ?? "";

      final backendResponse = await AuthService.validarConBackend(
        name: name,
        email: email,
        photo: photo,
      );

      if (backendResponse != null) {
        await Storage.saveUserSession(
          name: backendResponse['name'],
          email: backendResponse['email'],
          photo: backendResponse['foto'] ?? '',
          token: backendResponse['token'],
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              name: backendResponse['name'],
              email: backendResponse['email'],
              photoUrl: backendResponse['foto'] ?? '',
              accessToken: backendResponse['token'],
            ),
          ),
        );
      } else {
        await signIn.disconnect();
        await Storage.clearSession();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Usuario no autorizado")),
          );
        }
      }
    } catch (e) {
      print("Error en login: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/cancha.jpg', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.3)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'ReservaTec',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42.sp,
                    fontWeight: FontWeight.bold,
                    shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Organiza, reserva y disfruta\nde tus espacios deportivos\nde manera simple y rápida.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18.sp, height: 1.5),
                ),
                SizedBox(height: 60.h),
                ElevatedButton.icon(
                  icon: Image.asset('assets/icons/google.png', height: 24.h),
                  label: Text(
                    'Ingresa con tu correo de Tecsup',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                  ),
                  onPressed: handleGoogleSignIn,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
