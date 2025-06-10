// lib/models/horario.dart
class Horario {
  final int id;
  final String horaInicio;
  final String horaFin;

  Horario({
    required this.id,
    required this.horaInicio,
    required this.horaFin,
  });

  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      id: json['id'],
      horaInicio: json['horaInicio'],
      horaFin: json['horaFin'],
    );
  }
}
