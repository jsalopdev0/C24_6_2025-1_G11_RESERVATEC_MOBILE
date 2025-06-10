class Espacio {
  final int id;
  final String nombre;
  final int aforo;
  final String foto;

  Espacio({
    required this.id,
    required this.nombre,
    required this.aforo,
    required this.foto,
  });

  factory Espacio.fromJson(Map<String, dynamic> json) {
    return Espacio(
      id: json['id'],
      nombre: json['nombre'],
      aforo: json['aforo'],
      foto: json['foto'] ?? '', 
    );
  }
}
