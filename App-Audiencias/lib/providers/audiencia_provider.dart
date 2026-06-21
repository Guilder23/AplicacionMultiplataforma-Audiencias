import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/audiencia.dart';
import '../services/local_storage_service.dart';

class AudienciaProvider extends ChangeNotifier {
  AudienciaProvider(this._storageService);

  final LocalStorageService _storageService;

  List<Audiencia> _audiencias = [];
  String _searchQuery = '';
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  List<Audiencia> get audiencias => List.unmodifiable(_audiencias);

  Future<void> loadAudiencias() async {
    _isLoading = true;
    notifyListeners();

    try {
      _audiencias = await _storageService.getAudiencias();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Audiencia> filteredByStatus(String? status) {
    return _audiencias.where((audiencia) {
        final matchesStatus = status == null || audiencia.estado == status;
        final query = _searchQuery.trim().toLowerCase();
        if (query.isEmpty) {
          return matchesStatus;
        }

        final formattedDate = DateFormat(
          'dd/MM/yyyy',
        ).format(audiencia.fechaHora);
        return matchesStatus &&
            [
              audiencia.nurej,
              audiencia.demandante,
              audiencia.demandado,
              formattedDate,
            ].any((value) => value.toLowerCase().contains(query));
      }).toList()
      ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
  }

  List<Audiencia> audienciasByDate(DateTime date) {
    return _audiencias.where((audiencia) {
        final itemDate = audiencia.fechaHora;
        return itemDate.year == date.year &&
            itemDate.month == date.month &&
            itemDate.day == date.day;
      }).toList()
      ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
  }

  List<Audiencia> get upcomingAudiencias {
    final now = DateTime.now();
    return _audiencias
        .where(
          (item) =>
              item.fechaHora.isAfter(now.subtract(const Duration(hours: 2))),
        )
        .toList()
      ..sort((a, b) => a.fechaHora.compareTo(b.fechaHora));
  }

  Map<String, int> get statusSummary {
    final summary = {
      'Total': _audiencias.length,
      'Programada': 0,
      'En curso': 0,
      'Concluida': 0,
      'Suspendida': 0,
      'Reprogramada': 0,
    };

    for (final item in _audiencias) {
      summary[item.estado] = (summary[item.estado] ?? 0) + 1;
    }

    return summary;
  }

  Map<String, int> get processSummary {
    final summary = <String, int>{};
    for (final item in _audiencias) {
      summary[item.tipoProceso] = (summary[item.tipoProceso] ?? 0) + 1;
    }
    return summary;
  }

  Future<void> saveAudiencia(Audiencia audiencia) async {
    if (audiencia.id == null) {
      final created = audiencia.copyWith(
        historial: [
          ...audiencia.historial,
          _historyEntry('Audiencia registrada con estado ${audiencia.estado}'),
        ],
      );
      await _storageService.insertAudiencia(created);
    } else {
      final previous = _audiencias.firstWhere(
        (item) => item.id == audiencia.id,
      );
      final updated = audiencia.copyWith(
        historial: [
          ...previous.historial,
          _historyEntry('Se actualizo la informacion de la audiencia'),
        ],
      );
      await _storageService.updateAudiencia(updated);
    }
    await loadAudiencias();
  }

  Future<void> deleteAudiencia(int id) async {
    await _storageService.deleteAudiencia(id);
    await loadAudiencias();
  }

  Future<void> changeStatus(
    Audiencia audiencia,
    String status, {
    String? motivoSuspension,
  }) async {
    final updated = audiencia.copyWith(
      estado: status,
      motivoSuspension: status == 'Suspendida' ? motivoSuspension : null,
      historial: [
        ...audiencia.historial,
        _historyEntry(
          status == 'Suspendida'
              ? 'Estado cambiado a Suspendida. Motivo: ${motivoSuspension ?? 'Sin detalle'}'
              : 'Estado cambiado de ${audiencia.estado} a $status',
        ),
      ],
    );

    await _storageService.updateAudiencia(updated);
    await loadAudiencias();
  }

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  String _historyEntry(String description) {
    final timestamp = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    return '$timestamp - $description';
  }
}
