import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/horario.dart';
import 'storage.dart';

const String apiBaseUrl = 'https://reservatec-tesis-backend-8asuen-626be2-31-220-104-112.traefik.me/api';

class HorarioService {
  static Future<List<Horario>> obtenerHorariosActivos() async {
    final session = await Storage.getUserSession();
    final token = session?["token"];
    if (token == null) throw Exception("Sesión no iniciada");

    final response = await http.get(
      Uri.parse('$apiBaseUrl/horarios/activos'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => Horario.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener horarios: ${response.body}');
    }
  }

  static Future<List<int>> obtenerHorariosOcupados(
      int espacioId, DateTime fecha) async {
    final session = await Storage.getUserSession();
    final token = session?["token"];
    if (token == null) throw Exception("Sesión no iniciada");

    final formattedFecha = fecha.toIso8601String().split('T').first;

    final response = await http.get(
      Uri.parse(
          '$apiBaseUrl/reservas/horarios-ocupados?espacioId=$espacioId&fecha=$formattedFecha'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.cast<int>();
    } else {
      throw Exception('Error al obtener horarios ocupados: ${response.body}');
    }
  }

  static Future<List<DateTime>> obtenerFechasOcupadas(int espacioId) async {
    final session = await Storage.getUserSession();
    final token = session?["token"];
    if (token == null) throw Exception("Sesión no iniciada");

    final response = await http.get(
      Uri.parse('$apiBaseUrl/reservas/fechas-completas?espacioId=$espacioId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      return data.map((e) => DateTime.parse(e)).toList();
    } else {
      throw Exception('Error al obtener fechas ocupadas: ${response.body}');
    }
  }
}
