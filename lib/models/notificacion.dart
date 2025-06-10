class Notificacion {
  final String contenido;
  final DateTime fechaCreacion;

  Notificacion({
    required this.contenido,
    required this.fechaCreacion,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      contenido: json['contenido'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }
}
