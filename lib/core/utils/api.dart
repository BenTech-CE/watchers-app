import 'package:watchers/core/services/auth/auth_service.dart';

class Api {
  static String baseUrl =
      'https://personal-watchers-api.yvovkl.easypanel.host/';

  // SERIES

  static final Uri seriesTrendingEndpoint = Uri.parse(
    '${baseUrl}series/trending',
  );
  static final Uri seriesTopRatedEndpoint = Uri.parse(
    '${baseUrl}series/toprated',
  );
  static final Uri seriesRecentsEndpoint = Uri.parse(
    '${baseUrl}series/recents',
  );
  static Uri seriesSearchEndpoint(String query) =>
      Uri.parse('${baseUrl}series/search?q=$query');
  static Uri serieDetailsEndpoint(String id) =>
      Uri.parse('${baseUrl}series/$id');
  static Uri seasonDetailsEndpoint(String seriesId, String seasonNumber) =>
      Uri.parse('${baseUrl}series/$seriesId/season/$seasonNumber');
  static Uri episodeDetailsEndpoint(
          String seriesId, String seasonNumber, String episodeNumber) =>
      Uri.parse('${baseUrl}series/$seriesId/season/$seasonNumber/episode/$episodeNumber'); 
  static Uri genreEndpoint(int genre) =>
      Uri.parse('${baseUrl}series/genre/$genre');

  // LIST

  static final Uri allLists = Uri.parse('${baseUrl}lists/');
  static final Uri createList = Uri.parse('${baseUrl}lists/');
  static final Uri trendingLists = Uri.parse('${baseUrl}lists/trending');
  static Uri listSeries(String id) => Uri.parse('${baseUrl}lists/$id/items');
  static Uri listDetails(String id) => Uri.parse('${baseUrl}lists/$id');

  // GLOBAL
  static final Uri searchEndpoint = Uri.parse('${baseUrl}app/search');

  // USER
  static final Uri userSeriesFavoritesEnpoint = Uri.parse(
    '${baseUrl}user/favorites',
  );
  static final Uri userSeriesWatchedEnpoint = Uri.parse(
    '${baseUrl}user/watched',
  );
  static final Uri userSeriesWatchlistEnpoint = Uri.parse(
    '${baseUrl}user/watchlist',
  );
  static final Uri currentUserEndpoint = Uri.parse(
    '${baseUrl}user/me',
  );
  static final Uri editAvatarEndpoint = Uri.parse(
    '${baseUrl}user/me/avatar',
  );

  static Uri userByIdEndpoint(String id) =>
      Uri.parse('${baseUrl}user/$id');
  static Uri userDiaryById(String id) =>
      Uri.parse('${baseUrl}user/$id/diary');

  // REVIEWS
  static Uri userReviewsSeries(String seriesId) =>
      Uri.parse('${baseUrl}reviews/$seriesId');
  static Uri reviewByIdEndpoint(String reviewId) =>
      Uri.parse('${baseUrl}reviews/$reviewId');
  static final Uri reviewsTrendingEndpoint = Uri.parse(
    '${baseUrl}reviews/trending',
  );
}

class Headers {
  static Map<String, String> auth(AuthService authService) {
    return {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${authService.accessToken}',
    };
  }
}
