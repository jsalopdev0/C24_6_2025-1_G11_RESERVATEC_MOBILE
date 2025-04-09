import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class AuthService {
  static String getBackendUrl() {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api/usuario/validar';
    } else {
      return 'http://localhost:8080/api/usuario/validar';
    }
  }

  static Future<Map<String, dynamic>?> validarConBackend({
  required String name,
  required String email,
  required String photo,
}) async {
  final url = getBackendUrl();

  // ✅ Evitar enviar foto vacía
  final safePhoto = photo.isNotEmpty ? photo : null;

  final Map<String, dynamic> data = {
    'email': email,
    'name': name,
  };

  if (safePhoto != null) {
    data['photo'] = safePhoto;
  }

  print("📤 Enviando al backend: ${jsonEncode(data)}");

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("Login denegado: ${response.statusCode} - ${response.body}");
      return null;
    }
  } catch (e) {
    print("Error al conectarse con el backend: $e");
    return null;
  }
}


}
