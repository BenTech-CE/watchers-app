import 'package:flutter/foundation.dart';
import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/models/reviews/full_review_model.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:watchers/core/services/auth/auth_service.dart';
import 'package:watchers/core/services/lists/lists_service.dart';
import 'package:watchers/core/services/reviews/reviews_service.dart';

class ReviewsProvider with ChangeNotifier {
  final ReviewsService _reviewsService;

  ReviewsProvider({required AuthService authService})
    : _reviewsService = ReviewsService(authService: authService);

  String? _errorMessage;
  bool _isLoading = false;
  bool _isLoadingTrending = false;

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isLoadingTrending => _isLoadingTrending;

  List<ReviewModel> _trendingReviews = [];
  List<ReviewModel> get trendingReviews => _trendingReviews;

  Future<void> getTrendingReviews() async {
    _setLoadingTrending(true);
    try {
      clearError();
      _trendingReviews = await _reviewsService.getTrendingReviews();
    } catch (e) {
      print(e);
      _setError(e.toString());
    } finally {
      _setLoadingTrending(false);
    }
    return;
  }

  Future<FullReviewModel?> getReviewById(String reviewId) async {
    _setLoading(true);
    try {
      clearError();
      final review = await _reviewsService.getReviewById(reviewId);
      return review;
    } catch (e) {
      print(e);
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _errorMessage = null;
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

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }
}
