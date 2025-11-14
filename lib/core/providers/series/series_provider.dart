import 'package:flutter/foundation.dart';
import 'package:watchers/core/models/series/full_season_model.dart';
import 'package:watchers/core/models/series/full_serie_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/services/auth/auth_service.dart';
import 'package:watchers/core/services/series/series_service.dart';

class SeriesProvider with ChangeNotifier {
  final SeriesService _seriesService;

  SeriesProvider({required AuthService authService})
    : _seriesService = SeriesService(authService: authService);

  String? _errorMessage;
  bool _isLoadingTrending = false;
  bool _isLoadingRecents = false;
  bool _isLoadingSearch = false;
  bool _isLoadingDetails = false;
  

  String? get errorMessage => _errorMessage;
  bool get isLoadingTrending => _isLoadingTrending;
  bool get isLoadingRecents => _isLoadingRecents;
  bool get isLoadingSearch => _isLoadingSearch;
  bool get isLoadingDetails => _isLoadingDetails;

  List<SerieModel> _trendingSeries = [];
  List<SerieModel> get trendingSeries => _trendingSeries;

  List<SerieModel> _recentsSeries = [];
  List<SerieModel> get recentsSeries => _recentsSeries;

  Future<void> getSeriesTrending() async {
    _setLoadingTrending(true);
    try {
      clearError();
      _trendingSeries = await _seriesService.getSeriesTrending();
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingTrending(false);
    }
    return;
  }

  Future<void> getSeriesRecents() async {
    _setLoadingRecents(true);
    try {
      clearError();
      _recentsSeries = await _seriesService.getSeriesRecents();      
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingRecents(false);
    }
    return;
  }

  Future<List<SerieModel>> getSeriesSearch(String query) async {
    _setLoadingSearch(true);
    try {
      clearError();
      return await _seriesService.getSeriesSearch(query);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingSearch(false);
    }
    return [];
  }

  Future<FullSeriesModel?> getSerieDetails(String id) async {
    _setLoadingDetails(true);
    try {
      clearError();
      return await _seriesService.getSerieDetails(id);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingDetails(false);
    }
    return null;
  }

  Future<FullSeasonModel?> getSeasonDetails(String seriesId, String seasonNumber) async {
    _setLoadingDetails(true);
    try {
      clearError();
      return await _seriesService.getSeasonDetails(seriesId, seasonNumber);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingDetails(false);
    }
    return null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoadingTrending(bool loading) {
    _isLoadingTrending = loading;
    notifyListeners();
  }

  void _setLoadingRecents(bool loading) {
    _isLoadingRecents = loading;
    notifyListeners();
  }

  void _setLoadingDetails(bool loading) {
    _isLoadingDetails = loading;
    notifyListeners();
  }

  void _setLoadingSearch(bool loading) {
    _isLoadingSearch = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }
}
