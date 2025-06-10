import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reservatec/services/storage.dart';
import 'package:reservatec/models/reserva.dart'; 

class ReservaService {
  static const String _baseUrl = 'https://reservatec-tesis-backend-8asuen-626be2-31-220-104-112.traefik.me/api/reservas';
static Future<Map<String, dynamic>> crearReservaTemporal({
  required int espacioId,
  required int horarioId,
  required DateTime fecha,
}) async {
  final session = await Storage.getUserSession();
  final token = session?['token'];
  if (token == null) throw Exception('Token no encontrado');

  final url = '$_baseUrl/usuario'; 
  final body = jsonEncode({
    'espacioId': espacioId,
    'horarioId': horarioId,
    'fecha': fecha.toIso8601String().split('T').first,
  });

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
    body: body,
  );

  if (response.statusCode == 200) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  } else {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));  
    final mensaje =
        decoded['message'] ?? 'Error desconocido al crear reserva';
    throw Exception(mensaje);
  }
}


  static Future<void> confirmarReserva(int reservaId) async {
    final session = await Storage.getUserSession();
    final token = session?['token'];
    if (token == null) throw Exception('Token no encontrado');

    final url = '$_baseUrl/$reservaId/confirmar';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final mensaje =
          decoded['message'] ?? 'Error desconocido al confirmar reserva';
      throw Exception(mensaje);
    }
  }

  static Future<int> obtenerTTL(
      int espacioId, int horarioId, DateTime fecha) async {
    final session = await Storage.getUserSession();
    final token = session?['token'];
    if (token == null) throw Exception('Token no encontrado');

    final String fechaISO = fecha.toIso8601String().split('T')[0];

    final response = await http.get(
      Uri.parse(
          '$_baseUrl/ttl?espacioId=$espacioId&horarioId=$horarioId&fecha=$fechaISO'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final mensaje = decoded['message'] ?? 'Error al obtener TTL';
      throw Exception(mensaje);
    }
  }

  static Future<List<Reserva>> obtenerMisReservas() async {
    final session = await Storage.getUserSession();
    final token = session?['token'];
    if (token == null) throw Exception('Token no encontrado');

    final url = Uri.parse('$_baseUrl/mis-reservas');
    print("📡 Llamando a $url");

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("📥 Código de respuesta: ${response.statusCode}");

    if (response.statusCode == 200) {
      final List data = jsonDecode(utf8.decode(response.bodyBytes));
      print("🔄 Reservas cargadas: ${data.length}");
      return data.map((item) => Reserva.fromJson(item)).toList();
    } else {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final mensaje = decoded['message'] ?? 'Error al obtener reservas';
      print("❌ Error: $mensaje");
      throw Exception(mensaje);
    }
  }

  static Future<void> cancelarReserva(int reservaId) async {
    final session = await Storage.getUserSession();
    final token = session?['token'];
    if (token == null) throw Exception('Token no encontrado');

    final url = '$_baseUrl/$reservaId/cancelar';

    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final mensaje = decoded['message'] ?? 'Error al cancelar reserva';
      throw Exception(mensaje);
    }
  }

// crono
  static Future<Map<String, dynamic>> obtenerTiempoCronometro() async {
    final session = await Storage.getUserSession();
    final token = session?['token'];

    if (token == null) throw Exception('Token no encontrado');

    final url = '$_baseUrl/cronometro';

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final mensaje = decoded['message'] ?? 'Error al obtener el cronómetro';
      throw Exception(mensaje);
    }
  }

static Future<void> cancelarReservaTemporal(int reservaId) async {
  final session = await Storage.getUserSession();
  final token = session?['token'];

  if (token == null) throw Exception('Token no encontrado');

  final url = '$_baseUrl/reservas/$reservaId/cancelar-temporal';

  final response = await http.put(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode != 200) {
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    throw Exception(decoded['message'] ?? 'No se pudo cancelar');
  }
}
  
}
