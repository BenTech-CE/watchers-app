import 'package:flutter/foundation.dart';
import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/services/auth/auth_service.dart';
import 'package:watchers/core/services/lists/lists_service.dart';

class ListsProvider with ChangeNotifier {
  final ListsService _listsService;

  ListsProvider({required AuthService authService})
    : _listsService = ListsService(authService: authService);

  String? _errorMessage;
  bool _isLoading = false;

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<List<ListModel>> getAllLists() async {
    _setLoading(true);
    try {
      clearError();
      return await _listsService.getAllLists();
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
    return [];
  }

  Future<List<SerieModel>> getListSeries(String id) async {
    _setLoading(true);
    try {
      clearError();
      return await _listsService.getListSeries(id);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
    return [];
  }

  Future<List<SerieModel>> addSeriesToList(
    String id,
    List<int> seriesIds,
  ) async {
    _setLoading(true);
    try {
      clearError();
      return await _listsService.addSeriesToList(id, seriesIds);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
    return [];
  }

  Future<ListModel?> getListDetails(String id) async {
    _setLoading(true);
    try {
      clearError();
      return await _listsService.getListDetails(id);
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
