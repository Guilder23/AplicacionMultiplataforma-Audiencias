class Anuncio {
  const Anuncio({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.prioridad,
    required this.fechaPublicacion,
    this.publicadoPor,
  });

  final int id;
  final String titulo;
  final String mensaje;
  final String prioridad;
  final DateTime fechaPublicacion;
  final String? publicadoPor;

  factory Anuncio.fromMap(Map<String, dynamic> map) {
    return Anuncio(
      id: map['id'] as int? ?? 0,
      titulo: map['titulo'] as String? ?? '',
      mensaje: map['mensaje'] as String? ?? '',
      prioridad: map['prioridad'] as String? ?? 'normal',
      fechaPublicacion:
          DateTime.tryParse(map['fecha_publicacion'] as String? ?? '') ??
              DateTime.now(),
      publicadoPor: map['publicado_por'] as String?,
    );
  }
}
