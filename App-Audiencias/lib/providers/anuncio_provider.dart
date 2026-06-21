import 'package:flutter/foundation.dart';

import '../models/anuncio.dart';
import '../services/api_service.dart';

class AnuncioProvider extends ChangeNotifier {
  AnuncioProvider(this._apiService);

  final ApiService _apiService;
  List<Anuncio> _anuncios = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Anuncio> get anuncios => List.unmodifiable(_anuncios);

  Future<void> loadAnuncios() async {
    _isLoading = true;
    notifyListeners();

    try {
      _anuncios = await _apiService.getAnuncios();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
