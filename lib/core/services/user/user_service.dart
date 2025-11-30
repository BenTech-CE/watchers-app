import 'dart:convert';

import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:http/http.dart' as http;
import 'package:watchers/core/services/auth/auth_service.dart';
import 'package:watchers/core/utils/api.dart';

class UserServiceException implements Exception {
  final String message;
  final String? code;

  UserServiceException(this.message, {this.code});

  @override
  String toString() => message;
}

class UserService {
  final AuthService authService;
  UserService({required this.authService});

  // GET

  Future<List<SerieModel>> getSeries(ListType type) async {
    try {
      if (!authService.isAuthenticated) {
        throw UserServiceException('Usuário não autenticado');
      }

      Uri serieEndpoint = type == ListType.Favorites
          ? Api.userSeriesFavoritesEnpoint
          : type == ListType.Watched
          ? Api.userSeriesWatchedEnpoint
          : type == ListType.Watchlist
          ? Api.userSeriesWatchedEnpoint
          : Api.userSeriesFavoritesEnpoint;

      final response = await http.get(
        serieEndpoint,
        headers: Headers.auth(authService),
      );

      // print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<SerieModel> series = [];
        for (var serie in jsonResponse["results"]) {
          series.add(SerieModel.fromJson(serie));
        }
        return series;
      } else {
        throw UserServiceException(
          'Erro ao buscar séries ${type.name}: ${jsonResponse['error']}',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw UserServiceException('Erro ao buscar séries ${type.name}: $e');
    }
  }

  // POST

  Future<void> addSeries(
    ListType type,
    List<String> ids,
    int? seasonNumber,
    int? episodeNumber,
  ) async {
    try {
      if (!authService.isAuthenticated) {
        throw UserServiceException('Usuário não autenticado');
      }

      Uri serieEndpoint = type == ListType.Favorites
          ? Api.userSeriesFavoritesEnpoint
          : type == ListType.Watched
          ? Api.userSeriesWatchedEnpoint
          : type == ListType.Watchlist
          ? Api.userSeriesWatchlistEnpoint
          : Api.userSeriesFavoritesEnpoint;

      final response = await http.post(
        serieEndpoint,
        headers: Headers.auth(authService),
        body: seasonNumber != null || episodeNumber != null
            ? jsonEncode({
                'ids': ids,
                'season_number': seasonNumber,
                'episode_number': episodeNumber,
              })
            : jsonEncode({'ids': ids}),
      );

      // print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        /*final List<SerieModel> series = [];
        for (var serie in jsonResponse["results"]) {
          series.add(SerieModel.fromJson(serie));
        }
        return series;*/
        return;
      } else {
        throw UserServiceException(
          'Erro ao adicionar as séries ${type.name}: ${jsonResponse['error']}',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw UserServiceException(
        'Erro ao adicionar as séries ${type.name}: $e',
      );
    }
  }

  Future<ReviewModel> saveReviewSeries(
    ReviewModel review,
    String serieId,
  ) async {
    try {
      if (!authService.isAuthenticated) {
        throw UserServiceException('Usuário não autenticado');
      }

      final response = await http.post(
        Api.userReviewsSeries(serieId),
        headers: Headers.auth(authService),
        body: jsonEncode(review.toJson()),
      );

      // print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return ReviewModel.fromJson(jsonResponse);
      } else {
        throw UserServiceException(
          'Erro ao salvar a review da série: ${jsonResponse['error']}',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw UserServiceException('Erro ao salvar a review da série: $e');
    }
  }

  // DELETE

  Future<void> deleteSeries(
    ListType type,
    List<String> ids,
    int? seasonNumber,
    int? episodeNumber,
  ) async {
    try {
      if (!authService.isAuthenticated) {
        throw UserServiceException('Usuário não autenticado');
      }

      Uri serieEndpoint = type == ListType.Favorites
          ? Api.userSeriesFavoritesEnpoint
          : type == ListType.Watched
          ? Api.userSeriesWatchedEnpoint
          : type == ListType.Watchlist
          ? Api.userSeriesWatchlistEnpoint
          : Api.userSeriesFavoritesEnpoint;

      final response = await http.delete(
        serieEndpoint,
        headers: Headers.auth(authService),
        body: seasonNumber != null || episodeNumber != null
            ? jsonEncode({
                'ids': ids,
                'season_number': seasonNumber,
                'episode_number': episodeNumber,
              })
            : jsonEncode({'ids': ids}),
      );

      // print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        /*final List<SerieModel> series = [];
        for (var serie in jsonResponse["results"]) {
          series.add(SerieModel.fromJson(serie));
        }
        return series;*/
        return;
      } else {
        throw UserServiceException(
          'Erro ao deletar as séries ${type.name}: ${jsonResponse['error']}',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw UserServiceException('Erro ao deletar as séries ${type.name}: $e');
    }
  }
}
