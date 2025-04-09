import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reservatec/screens/user_profile_screen.dart'; // o el path correcto de tu archivo

class GoogleSignIN extends StatefulWidget {
  const GoogleSignIN({super.key});

  @override
  State<GoogleSignIN> createState() => _GoogleSignINState();
}

class _GoogleSignINState extends State<GoogleSignIN> {
  final GoogleSignIn signIn = GoogleSignIn();

  Future<void> handleGoogleSignIn() async {
  try {
    final GoogleSignInAccount? user = await signIn.signIn();
    if (user == null) return; // Canceló el login

    final GoogleSignInAuthentication auth = await user.authentication;

    // Navegar a la pantalla de perfil
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserProfileScreen(
          name: user.displayName ?? "Sin nombre",
          email: user.email,
          photoUrl: user.photoUrl ?? "",
          accessToken: auth.accessToken ?? "",
        ),
      ),
    );
  } catch (e) {
    print("Error en login: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google sign in"),
      ),
      body: Center(
        child: TextButton(
          onPressed: handleGoogleSignIn,
          child: const Text("Google signin"),
        ),
      ),
    );
  }
}

