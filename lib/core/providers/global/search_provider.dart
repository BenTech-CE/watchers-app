import 'package:flutter/foundation.dart';
import 'package:watchers/core/models/global/home_model.dart';
import 'package:watchers/core/models/global/search_model.dart';
import 'package:watchers/core/models/global/type_filter_search.dart';
import 'package:watchers/core/services/auth/auth_service.dart';
import 'package:watchers/core/services/global/search_service.dart';

class AppProvider with ChangeNotifier {
  final AppService _appService;

  AppProvider({required AuthService authService})
    : _appService = AppService(authService: authService);

  String? _errorMessage;
  bool _isLoadingSearch = false;

  String? get errorMessage => _errorMessage;
  bool get isLoadingSearch => _isLoadingSearch;

  SearchModel _searchResults = const SearchModel(
    series: [],
    lists: [],
    users: [],
    reviews: [],
  );

  SearchModel get searchResults => _searchResults;

  Future<SearchModel?> getSearch(String query, TypeFilterSearch filter) async {
    _setLoadingSearch(true);
    try {
      clearError();
      _searchResults = await _appService.search(query, filter);
      return _searchResults;
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingSearch(false);
    }
    return null;
  }

  Future<HomeModel?> getHomeData() async {
    _setLoadingSearch(true);
    try {
      clearError();
      final homeData = await _appService.fetchHomeData();

      return homeData;
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingSearch(false);
    }
    return null;
  }

  void clearError() {
    _errorMessage = null;
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
