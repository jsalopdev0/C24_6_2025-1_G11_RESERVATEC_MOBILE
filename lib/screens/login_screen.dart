import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reservatec/services/storage.dart';
import 'package:reservatec/screens/user_profile_screen.dart';
import 'package:reservatec/services/auth_service.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GoogleSignIn getSignInInstance() {
  return GoogleSignIn(
    scopes: ['email', 'profile'],
    // optional: hostedDomain, clientId si lo necesitas
  );
}


Future<void> handleGoogleSignIn() async {
  final signIn = getSignInInstance(); // 👈 importante
  try {
    final user = await signIn.signIn();
    if (user == null) return;

    final auth = await user.authentication;
    final name = user.displayName ?? "Sin nombre";
    final email = user.email;
    final photo = user.photoUrl ?? "";

    // print("📸 Foto enviada: $photo");

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
          builder: (_) => UserProfileScreen(
            name: backendResponse['name'],
            email: backendResponse['email'],
            photoUrl: backendResponse['foto'] ?? '',
            accessToken: backendResponse['token'],
          ),
        ),
      );
    } else {
      // 🧹 Limpieza fuerte
      await signIn.disconnect();
      await Storage.clearSession();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario no autorizado")),
      );
    }
  } catch (e) {
    print("Error en login: $e");
  }
}




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Iniciar Sesión")),
      body: Center(
        child: ElevatedButton(
          onPressed: handleGoogleSignIn,
          child: const Text("Iniciar sesión con Google"),
        ),
      ),
    );
  }
}
