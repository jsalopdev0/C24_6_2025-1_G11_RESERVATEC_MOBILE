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
          userId: backendResponse['id'],
          name: backendResponse['name'],
          email: backendResponse['email'],
          photo: backendResponse['foto'] ?? '',
          token: backendResponse['token'],
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              userId: backendResponse['id'],
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
          // Imagen de fondo cancha
          Image.asset(
            'assets/images/cancha.jpg',
            fit: BoxFit.cover,
          ),

          // Degradado azul con transparencia encima
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00B2E2).withOpacity(0.85),
                  const Color(0xFF00B2E2).withOpacity(0.85),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Contenido
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo ampliado x2.5
                Image.asset(
                  'assets/images/logoreservatec.png',
                  height: 250.h, // Aumentado
                ),
                SizedBox(height: 80.h),

                // Botón Google
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: handleGoogleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32.r),
                      ),
                      elevation: 4,
                      shadowColor: Colors.black26,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icons/google.png',
                          height: 32.h,
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          'Ingresa con tu correo de Tecsup',
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
