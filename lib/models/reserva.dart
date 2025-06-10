class Reserva {
  final int id; 
  final String codigoReserva;
  final String espacio;
  final String fecha;
  final String horaInicio;
  final String horaFin;
  final String estado;

  Reserva({
    required this.id, 
    required this.codigoReserva,
    required this.espacio,
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'],
      codigoReserva: json['codigoReserva'],
      espacio: json['espacioNombre'],
      fecha: json['fecha'],
      horaInicio: json['horarioInicio'],
      horaFin: json['horarioFin'],
      estado: json['estado'],
    );
  }
}
