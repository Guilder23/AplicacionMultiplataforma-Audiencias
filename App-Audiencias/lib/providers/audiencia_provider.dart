import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/audiencia.dart';
import '../services/api_service.dart';

class AudienciaProvider extends ChangeNotifier {
  AudienciaProvider(this._apiService);

  final ApiService _apiService;

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
      _audiencias = await _apiService.getAudiencias();
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

  Future<bool> saveAudiencia(Audiencia audiencia) async {
    _isLoading = true;
    notifyListeners();

    bool success;
    if (audiencia.id == null) {
      success = await _apiService.createAudiencia(audiencia);
    } else {
      success = await _apiService.updateAudiencia(audiencia);
    }

    if (success) {
      await loadAudiencias();
    } else {
      _isLoading = false;
      notifyListeners();
    }

    return success;
  }

  Future<bool> deleteAudiencia(int id) async {
    _isLoading = true;
    notifyListeners();

    final success = await _apiService.deleteAudiencia(id);

    if (success) {
      await loadAudiencias();
    } else {
      _isLoading = false;
      notifyListeners();
    }

    return success;
  }

  Future<bool> changeStatus(
    Audiencia audiencia,
    String status, {
    String? motivoSuspension,
  }) async {
    final updated = audiencia.copyWith(
      estado: status,
      motivoSuspension: status == 'Suspendida' ? motivoSuspension : null,
    );

    _isLoading = true;
    notifyListeners();

    final success = await _apiService.updateAudiencia(updated);

    if (success) {
      await loadAudiencias();
    } else {
      _isLoading = false;
      notifyListeners();
    }

    return success;
  }

  void updateSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }
}