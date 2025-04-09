import 'package:flutter/material.dart';
import 'package:reservatec/screens/login_screen.dart';
import 'package:reservatec/screens/user_profile_screen.dart';
import 'package:reservatec/services/storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // 👈 Asegúrate de tener esto en tu pubspec.yaml

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final session = await Storage.getUserSession();

    if (session != null) {
      final token = session["token"]!;
      final isExpired = JwtDecoder.isExpired(token);

      if (!isExpired) {
        return UserProfileScreen(
          name: session["name"]!,
          email: session["email"]!,
          photoUrl: session["photo"]!,
          accessToken: token,
        );
      } else {
        // Token vencido: borra sesión
        await Storage.clearSession();
      }
    }

    return const LoginScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reservatec',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return snapshot.data!;
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
