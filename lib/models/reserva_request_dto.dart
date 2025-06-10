class ReservaRequestDTO {
  final int espacioId;
  final int horarioId;
  final String fecha;

  ReservaRequestDTO({
    required this.espacioId,
    required this.horarioId,
    required this.fecha,
  });

  Map<String, dynamic> toJson() {
    return {
      'espacioId': espacioId,
      'horarioId': horarioId,
      'fecha': fecha,
    };
  }
}
