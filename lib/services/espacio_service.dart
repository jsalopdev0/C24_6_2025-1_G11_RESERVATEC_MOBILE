import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reservatec/services/unsafe_http_client.dart'; // importa tu clase
import '../models/espacio.dart';
import 'storage.dart';

class EspacioService {
  static const String _baseUrl = 'https://reservatec-tesis-backend-8asuen-626be2-31-220-104-112.traefik.me/api/espacios/activos';

  static Future<List<Espacio>> obtenerEspaciosActivos() async {
    final session = await Storage.getUserSession();
    final token = session?['token'];
    if (token == null) throw Exception("No hay sesión activa");

    final client = UnsafeHttpClient.create(); // 👈 usa el cliente que ignora certificados

    final response = await client.get(
      Uri.parse(_baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonList.map((json) => Espacio.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener espacios: ${response.body}');
    }
  }

  static Future<int> obtenerIdPorNombre(String nombre) async {
    final espacios = await obtenerEspaciosActivos();
    final espacio = espacios.firstWhere((e) => e.nombre == nombre);
    return espacio.id;
  }
}