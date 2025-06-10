import 'dart:convert';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:reservatec/services/unsafe_http_client.dart';

class AuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static GoogleSignIn get googleSignInInstance => _googleSignIn;

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  static String getBackendUrl() {
    return 'https://reservatec-tesis-backend-8asuen-626be2-31-220-104-112.traefik.me/api/usuario/validar';
  }

  static Future<Map<String, dynamic>?> validarConBackend({
    required String name,
    required String email,
    required String photo,
  }) async {
    final url = getBackendUrl();
    final safePhoto = photo.isNotEmpty ? photo : null;
    final client = UnsafeHttpClient.create();

    final Map<String, dynamic> data = {
      'email': email,
      'name': name,
    };

    if (safePhoto != null) {
      data['photo'] = safePhoto;
    }

    print("📤 Enviando al backend: ${jsonEncode(data)}");

    try {
      final response = await client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        print("🔐 Token recibido: ${decoded['token']}");
        return decoded;
      } else {
        print("Login denegado: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("❌ Error al conectarse con el backend: $e");
      return null;
    }
  }
}
