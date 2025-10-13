import 'package:flutter/foundation.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/services/auth/auth_service.dart';
import 'package:watchers/core/services/series/series_service.dart';

class SeriesProvider with ChangeNotifier {
  final SeriesService _seriesService;

  SeriesProvider({required AuthService authService})
    : _seriesService = SeriesService(authService: authService);

  String? _errorMessage;
  bool _isLoading = false;

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<List<SerieModel>> getSeriesTrending() async {
    _setLoading(true);
    try {
      clearError();
      return await _seriesService.getSeriesTrending();
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
    return [];
  }

  Future<List<SerieModel>> getSeriesSearch(String query) async {
    _setLoading(true);
    try {
      clearError();
      return await _seriesService.getSeriesSearch(query);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
    return [];
  }

  Future<SerieModel?> getSerieDetails(String id) async {
    _setLoading(true);
    try {
      clearError();
      return await _seriesService.getSerieDetails(id);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
    return null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
}
