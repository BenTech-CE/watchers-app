import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:watchers/core/models/auth/full_user_model.dart';
import 'package:watchers/core/models/auth/profile_model.dart';
import 'package:watchers/core/models/auth/user_diary_model.dart';
import 'package:watchers/core/models/global/user_interaction_model.dart';
import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/services/auth/auth_service.dart';
import 'package:watchers/core/services/user/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService;

  UserProvider({required AuthService authService})
    : _userService = UserService(authService: authService);

  UserInteractionData _currSeriesUID = UserInteractionData.empty();
  UserInteractionData currentUserInteractionData(String scope) =>
      scope == 'series' ? _currSeriesUID : scope == 'season' ? _currSeasonUID : scope == 'episode' ? _currEpisodeUID : UserInteractionData.empty();

  UserInteractionData _currSeasonUID = UserInteractionData.empty();
  UserInteractionData _currEpisodeUID = UserInteractionData.empty();

  List<String> _currSeriesInLists = [];
  List<String> get currentSeriesInLists => _currSeriesInLists;

  String? _errorMessage;
  bool _isLoadingGetFavorites = false;
  bool _isLoadingGetWatched = false;
  bool _isLoadingGetWatchlist = false;
  bool _isLoadingGetDiary = false;

  bool _isLoadingAddFavorites = false;
  bool _isLoadingAddWatched = false;
  bool _isLoadingAddWatchlist = false;

  bool _isLoadingDeleteFavorites = false;
  bool _isLoadingDeleteWatched = false;
  bool _isLoadingDeleteWatchlist = false;

  bool _isLoadingFollowers = false;
  bool _isLoadingFollowing = false;

  bool _isLoadingUser = false;
  bool get isLoadingUser => _isLoadingUser;

  bool _isLoadingChangeField = false;
  bool get isLoadingChangeField => _isLoadingChangeField;

  String? get errorMessage => _errorMessage;

  bool get isLoadingGetFavorites => _isLoadingGetFavorites;
  bool get isLoadingGetWatched => _isLoadingGetWatched;
  bool get isLoadingGetWatchlist => _isLoadingGetWatchlist;
  bool get isLoadingGetDiary => _isLoadingGetDiary;

  bool get isLoadingAddFavorites => _isLoadingAddFavorites;
  bool get isLoadingAddWatched => _isLoadingAddWatched;
  bool get isLoadingAddWatchlist => _isLoadingAddWatchlist;

  bool get isLoadingDeleteFavorites => _isLoadingDeleteFavorites;
  bool get isLoadingDeleteWatched => _isLoadingDeleteWatched;
  bool get isLoadingDeleteWatchlist => _isLoadingDeleteWatchlist;

  bool get isLoadingFollowers => _isLoadingFollowers;
  bool get isLoadingFollowing => _isLoadingFollowing;

  List<SerieModel> _seriesFavorites = [];
  List<SerieModel> get seriesFavorites => _seriesFavorites;
  List<SerieModel> _seriesWatched = [];
  List<SerieModel> get seriesWatched => _seriesWatched;
  List<SerieModel> _seriesWatchlist = [];
  List<SerieModel> get seriesWatchlist => _seriesWatchlist;

  FullUserModel? _currentUser;
  FullUserModel? get currentUser => _currentUser;

  FullUserModel? _selUser;
  FullUserModel? get selectedUser => _selUser;  

  // GET

  Future<void> getCurrentUser() async {
    _setLoadingUser(true);
    try {
      clearError();
      _currentUser = await _userService.getCurrentUser();
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingUser(false);
    }
    return;
  }

  Future<void> getUserById(String id) async {
    _setLoadingUser(true);
    try {
      clearError();
      _selUser = await _userService.getUserById(id);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingUser(false);
    }
  }

  Future<List<UserDiaryModel>> getUserDiaryById(String id) async {
    _setLoadingGetDiary(true);
    try {
      clearError();
      return await _userService.getUserDiaryById(id);
    } catch (e) {
      print(e);
      _setError(e.toString());
      return [];
    } finally {
      _setLoadingGetDiary(false);
    }
  }

  Future<void> getSeriesFavorites() async {
    _setLoadingGetFavorites(true);
    try {
      clearError();
      _seriesFavorites = await _userService.getSeries(ListType.Favorites);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingGetFavorites(false);
    }
    return;
  }

  Future<void> getSeriesWatched() async {
    _setLoadingGetWatched(true);
    try {
      clearError();
      _seriesWatched = await _userService.getSeries(ListType.Watched);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingGetWatched(false);
    }
    return;
  }

  Future<void> getSeriesWatchlist() async {
    _setLoadingGetWatchlist(true);
    try {
      clearError();
      _seriesWatchlist = await _userService.getSeries(ListType.Watchlist);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingGetWatchlist(false);
    }
    return;
  }

  // POST

  Future<void> addSeriesFavorites(List<String> ids) async {
    _setLoadingAddFavorites(true);
    try {
      clearError();
      await _userService.addSeries(ListType.Favorites, ids, null, null);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingAddFavorites(false);
    }
    return;
  }

  Future<void> addSeriesWatched(
    List<String> ids,
    int? seasonNumber,
    int? episodeNumber,
  ) async {
    _setLoadingAddWatched(true);
    try {
      clearError();
      await _userService.addSeries(
        ListType.Watched,
        ids,
        seasonNumber,
        episodeNumber,
      );
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingAddWatched(false);
    }
    return;
  }

  Future<void> addSeriesWatchlist(
    List<String> ids,
    int? seasonNumber,
    int? episodeNumber,
  ) async {
    _setLoadingAddWatchlist(true);
    try {
      clearError();
      await _userService.addSeries(
        ListType.Watchlist,
        ids,
        seasonNumber,
        episodeNumber,
      );
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingAddWatchlist(false);
    }
    return;
  }

  // DELETE

  Future<void> deleteSeriesFavorites(List<String> ids) async {
    _setLoadingDeleteFavorites(true);
    try {
      clearError();
      await _userService.deleteSeries(ListType.Favorites, ids, null, null);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingDeleteFavorites(false);
    }
    return;
  }

  Future<void> deleteSeriesWatched(
    List<String> ids,
    int? seasonNumber,
    int? episodeNumber,
  ) async {
    _setLoadingDeleteWatched(true);
    try {
      clearError();
      await _userService.deleteSeries(
        ListType.Watched,
        ids,
        seasonNumber,
        episodeNumber,
      );
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingDeleteWatched(false);
    }
    return;
  }

  Future<void> deleteSeriesWatchlist(
    List<String> ids,
    int? seasonNumber,
    int? episodeNumber,
  ) async {
    _setLoadingDeleteWatchlist(true);
    try {
      clearError();
      await _userService.deleteSeries(
        ListType.Watchlist,
        ids,
        seasonNumber,
        episodeNumber,
      );
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingDeleteWatchlist(false);
    }
    return;
  }

  Future<ReviewModel> saveReviewSeries(ReviewModel review, String serieId) async {
    _setLoadingUser(true);
    try {
      clearError();
      return await _userService.saveReviewSeries(review, serieId);
    } catch (e) {
      print(e);
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoadingUser(false);
    }
  }

  Future<void> updateUserFields(Map<String, dynamic> fields) async {
    _setLoadingChangeField(true);
    try {
      clearError();
      await _userService.updateUserFields(fields);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingChangeField(false);
    }
    return;
  }

  Future<void> updateUserAvatar(XFile image) async {
    _setLoadingChangeField(true);
    try {
      clearError();
      final url = await _userService.uploadAvatar(image);
      if (_currentUser != null) {
        _currentUser!.avatarUrl = url;
        notifyListeners();
      }
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingChangeField(false);
    }
  }

  Future<void> followUser(String userId) async {
    _setLoadingChangeField(true);
    try {
      clearError();
      await _userService.followUser(userId);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingChangeField(false);
    }
  }

  Future<void> unfollowUser(String userId) async {
    _setLoadingChangeField(true);
    try {
      clearError();
      await _userService.unfollowUser(userId);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingChangeField(false);
    }
  }

  Future<List<ProfileModel>?> getUserFollowers(String userId) async {
    _setLoadingFollowers(true);
    try {
      clearError();
      return await _userService.getUserFollowers(userId);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingFollowers(false);
    }

    return null;
  }

  Future<List<ProfileModel>?> getUserFollowing(String userId) async {
    _setLoadingFollowing(true);
    try {
      clearError();
      return await _userService.getUserFollowing(userId);
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingFollowing(false);
    }

    return null;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setLoadingGetFavorites(bool loading) {
    _isLoadingGetFavorites = loading;
    notifyListeners();
  }

  void _setLoadingGetWatched(bool loading) {
    _isLoadingGetWatched = loading;
    notifyListeners();
  }

  void _setLoadingGetWatchlist(bool loading) {
    _isLoadingGetWatchlist = loading;
    notifyListeners();
  }

  void _setLoadingGetDiary(bool loading) {
    _isLoadingGetDiary = loading;
    notifyListeners();
  }

  void _setLoadingAddFavorites(bool loading) {
    _isLoadingAddFavorites = loading;
    notifyListeners();
  }

  void _setLoadingAddWatched(bool loading) {
    _isLoadingAddWatched = loading;
    notifyListeners();
  }

  void _setLoadingAddWatchlist(bool loading) {
    _isLoadingAddWatchlist = loading;
    notifyListeners();
  }

  void _setLoadingDeleteFavorites(bool loading) {
    _isLoadingDeleteFavorites = loading;
    notifyListeners();
  }

  void _setLoadingDeleteWatched(bool loading) {
    _isLoadingDeleteWatched = loading;
    notifyListeners();
  }

  void _setLoadingDeleteWatchlist(bool loading) {
    _isLoadingDeleteWatchlist = loading;
    notifyListeners();
  }

  void _setLoadingUser(bool loading) {
    _isLoadingUser = loading;
    notifyListeners();
  }

  void _setLoadingChangeField(bool loading) {
    _isLoadingChangeField = loading;
    notifyListeners();
  }

  void _setLoadingFollowers(bool loading) {
    _isLoadingFollowers = loading;
    notifyListeners();
  }

  void _setLoadingFollowing(bool loading) {
    _isLoadingFollowing = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void setCurrentSeriesInLists(List<String> listsIds) {
    _currSeriesInLists = listsIds;
    notifyListeners();
  }

  void setCurrentUserInteractionData(String scope, UserInteractionData data) {
    if (scope == 'series') {
      _currSeriesUID = data;
    } else if (scope == 'season') {
      _currSeasonUID = data;
    } else if (scope == 'episode') {
      _currEpisodeUID = data;
    }
    notifyListeners();
  }

  void clearCurrentUserInteractionData(String scope) {
    if (scope == 'series') {
      _currSeriesUID = UserInteractionData.empty();
    } else if (scope == 'season') {
      _currSeasonUID = UserInteractionData.empty();
    } else if (scope == 'episode') {
      _currEpisodeUID = UserInteractionData.empty();
    }
    notifyListeners();
  }
}
