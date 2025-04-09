import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reservatec/screens/login_screen.dart';
import 'package:reservatec/services/storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserProfileScreen extends StatefulWidget {
  final String name;
  final String email;
  final String photoUrl;
  final String accessToken;

  const UserProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.accessToken,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  void initState() {
    super.initState();
    _verificarToken();
  }

  void _verificarToken() async {
    bool isExpired = JwtDecoder.isExpired(widget.accessToken);
    if (isExpired) {
      // Limpieza
      await GoogleSignIn().signOut();
      await Storage.clearSession();

      // Redirección
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Perfil de Usuario")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.photoUrl.isNotEmpty)
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(widget.photoUrl),
              ),
            const SizedBox(height: 20),
            Text("Nombre: ${widget.name}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Email: ${widget.email}", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Access Token:", style: TextStyle(fontSize: 18)),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: "Copiar token",
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.accessToken));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Token copiado al portapapeles")),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 5),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  widget.accessToken,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await GoogleSignIn().signOut();
                await Storage.clearSession();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text("Cerrar sesión"),
            ),
          ],
        ),
      ),
    );
  }
}
