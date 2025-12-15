import 'package:flutter/foundation.dart';
import 'package:watchers/core/models/global/comment_model.dart';
import 'package:watchers/core/models/lists/full_list_model.dart';
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
  bool _isLoadingAction = false;
  bool _isLoadingTrending = false;

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isLoadingTrending => _isLoadingTrending;
  bool get isLoadingAction => _isLoadingAction;

  List<ListModel> _trendingLists = [];
  List<ListModel> get trendingLists => _trendingLists;

  List<SerieModel> _listSeriesAdd = [];
  List<SerieModel> get listSeriesAdd => _listSeriesAdd;

  FullListModel? _currentListDetails;
  FullListModel? get currentListDetails => _currentListDetails;

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

  Future<void> getTrendingLists() async {
    _setLoadingTrending(true);
    try {
      clearError();
      _trendingLists = await _listsService.getTrendingLists();
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingTrending(false);
    }
    return;
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

  Future<void> addSeriesToList(
    String id,
    List<int> seriesIds,
  ) async {
    _setLoading(true);
    try {
      clearError();
      await _listsService.addSeriesToList(id, seriesIds);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
    return;
  }

  Future<void> removeSeriesFromList(
    String id,
    List<int> seriesIds,
  ) async {
    _setLoading(true);
    try {
      clearError();
      await _listsService.removeSeriesFromList(id, seriesIds);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
    return;
  }

  Future<void> getListDetails(String id) async {
    _setCurrentListDetails(null);
    _setLoading(true);
    try {
      clearError();
      _setCurrentListDetails(await _listsService.getListDetails(id));
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
    return;
  }

  Future<ListModel?> createList(
    String name,
    bool isPrivate,
    String? description,
    List<SerieModel> series,
  ) async {
    _setLoading(true);
    try {
      clearError();
      return await _listsService.createList(
        name,
        isPrivate,
        description,
        series,
      );
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
    return null;
  }

  Future<ListModel?> editList(
    String id,
    String name,
    bool isPrivate,
    String? description,
    List<String> addedSeries,
    List<String> removedSeries,
  ) async {
    _setLoading(true);
    try {
      clearError();
      return await _listsService.editList(
        id,
        name,
        isPrivate,
        description,
        addedSeries,
        removedSeries,
      );
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

  void setListSeriesAdd(List<SerieModel> series) {
    _listSeriesAdd = series;
    notifyListeners();
  }

  void addToListSeriesAdd(SerieModel series) {
    _listSeriesAdd.add(series);
    notifyListeners();
  }

  void removeFromListSeriesAdd(SerieModel series) {
    _listSeriesAdd.removeWhere((s) => s.id == series.id);
    notifyListeners();
  }

  void clearListSeriesAdd() {
    _listSeriesAdd.clear();
    notifyListeners();
  }

  void setNewDataForListDetails(String name, bool isPrivate, String? description, List<ListAdditionalDataSeries> addedSeries, List<ListAdditionalDataSeries> removedSeries) {
    if (_currentListDetails != null) {
      _currentListDetails!.listData.name = name;
      _currentListDetails!.listData.isPrivate = isPrivate;
      _currentListDetails!.listData.description = description;
      for (var series in addedSeries) {
        _currentListDetails!.additionalData.series.add(series);
      }
      for (var series in removedSeries) {
        _currentListDetails!.additionalData.series.removeWhere((s) => s.id == series.id);
      }
      notifyListeners();
    }
  }

  Future<void> like(String id) async {
    _setLoadingAction(true);
    try {
      clearError();
      await _listsService.likeList(id);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingAction(false);
    }
    return;
  }

  Future<void> unlike(String id) async {
    _setLoadingAction(true);
    try {
      clearError();
      await _listsService.unlikeList(id);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingAction(false);
    }
    return;
  }

  Future<void> deleteComment(String id, String commentId) async {
    _setLoadingAction(true);
    try {
      clearError();
      await _listsService.deleteComment(id, commentId);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingAction(false);
    }
    return;
  }

  Future<CommentModel?> addComment(String id, String content) async {
    _setLoadingAction(true);
    try {
      clearError();
      final comment = await _listsService.addComment(id, content);
      return comment;
    } catch (e) {
      print(e);
      _setError(e.toString());
      return null;
    } finally {
      _setLoadingAction(false);
    }
  }

  Future<void> deleteList(String id) async {
    _setLoading(true);
    try {
      clearError();
      await _listsService.deleteList(id);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
    return;
  }

  void _setCurrentListDetails(FullListModel? listDetails) {
    _currentListDetails = listDetails;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingTrending(bool loading) {
    _isLoadingTrending = loading;
    notifyListeners();
  }

  void _setLoadingAction(bool loading) {
    _isLoadingAction = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
}
