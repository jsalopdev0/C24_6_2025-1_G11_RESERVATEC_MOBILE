import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notificacion.dart';
import 'unsafe_http_client.dart';
import 'storage.dart';

class NotificacionService {
  static const String _url = 'https://reservatec-tesis-backend-8asuen-626be2-31-220-104-112.traefik.me/api/notificaciones/activas';

  static Future<List<Notificacion>> obtenerNotificaciones() async {
    final client = UnsafeHttpClient.create();

    final session = await Storage.getUserSession();
    final token = session?['token'];

    if (token == null) {
      throw Exception('No hay token de sesión disponible');
    }

    final response = await client.get(
      Uri.parse(_url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((item) => Notificacion.fromJson(item)).toList();
    } else {
      throw Exception('Error al cargar notificaciones: ${response.statusCode}');
    }
  }
}
