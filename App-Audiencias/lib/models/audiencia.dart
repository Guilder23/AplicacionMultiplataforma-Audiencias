import 'dart:convert';

class Audiencia {
  const Audiencia({
    this.id,
    required this.nurej,
    required this.demandante,
    required this.demandado,
    required this.fechaHora,
    required this.tipoProceso,
    required this.tipoAudiencia,
    required this.sala,
    required this.juez,
    required this.estado,
    required this.observaciones,
    this.motivoSuspension,
    this.historial = const [],
  });

  final int? id;
  final String nurej;
  final String demandante;
  final String demandado;
  final DateTime fechaHora;
  final String tipoProceso;
  final String tipoAudiencia;
  final String sala;
  final String juez;
  final String estado;
  final String observaciones;
  final String? motivoSuspension;
  final List<String> historial;

  Audiencia copyWith({
    int? id,
    String? nurej,
    String? demandante,
    String? demandado,
    DateTime? fechaHora,
    String? tipoProceso,
    String? tipoAudiencia,
    String? sala,
    String? juez,
    String? estado,
    String? observaciones,
    String? motivoSuspension,
    List<String>? historial,
  }) {
    return Audiencia(
      id: id ?? this.id,
      nurej: nurej ?? this.nurej,
      demandante: demandante ?? this.demandante,
      demandado: demandado ?? this.demandado,
      fechaHora: fechaHora ?? this.fechaHora,
      tipoProceso: tipoProceso ?? this.tipoProceso,
      tipoAudiencia: tipoAudiencia ?? this.tipoAudiencia,
      sala: sala ?? this.sala,
      juez: juez ?? this.juez,
      estado: estado ?? this.estado,
      observaciones: observaciones ?? this.observaciones,
      motivoSuspension: motivoSuspension ?? this.motivoSuspension,
      historial: historial ?? this.historial,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nurej': nurej,
      'demandante': demandante,
      'demandado': demandado,
      'fecha_hora': fechaHora.toIso8601String(),
      'tipo_proceso': tipoProceso,
      'tipo_audiencia': tipoAudiencia,
      'sala': sala,
      'juez': juez,
      'estado': estado,
      'observaciones': observaciones,
      'motivo_suspension': motivoSuspension,
      'historial': jsonEncode(historial),
    };
  }

  factory Audiencia.fromMap(Map<String, dynamic> map) {
    return Audiencia(
      id: map['id'] as int?,
      nurej: map['nurej'] as String? ?? '',
      demandante: map['demandante'] as String? ?? '',
      demandado: map['demandado'] as String? ?? '',
      fechaHora:
          DateTime.tryParse(map['fecha_hora'] as String? ?? '') ??
          DateTime.now(),
      tipoProceso: map['tipo_proceso'] as String? ?? '',
      tipoAudiencia: map['tipo_audiencia'] as String? ?? '',
      sala: map['sala'] as String? ?? '',
      juez: map['juez'] as String? ?? '',
      estado: map['estado'] as String? ?? 'Programada',
      observaciones: map['observaciones'] as String? ?? '',
      motivoSuspension: map['motivo_suspension'] as String?,
      historial: _decodeHistory(map['historial']),
    );
  }

  static List<String> _decodeHistory(dynamic rawHistory) {
    if (rawHistory == null || rawHistory == '') {
      return const [];
    }
    try {
      final decoded = jsonDecode(rawHistory as String) as List<dynamic>;
      return decoded.map((item) => item.toString()).toList();
    } catch (_) {
      return const [];
    }
  }
}
