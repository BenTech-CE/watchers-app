import 'dart:convert';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:watchers/core/models/auth/full_user_model.dart';
import 'package:watchers/core/models/auth/user_diary_model.dart';
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
  Future<FullUserModel> getCurrentUser() async {
    try {
      if (!authService.isAuthenticated) {
        throw UserServiceException('Usuário não autenticado');
      }

      final response = await http.get(
        Api.currentUserEndpoint,
        headers: Headers.auth(authService),
      );

      // print('Status Code: ${response.statusCode}');
       print('Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return FullUserModel.fromJson(jsonResponse);
      } else {
        throw UserServiceException(
          jsonResponse['error'],
          code: response.statusCode.toString(),
        );
      }
    } catch (e, st) {
      print('Stack Trace: $st');
      throw UserServiceException('Erro ao buscar o usuário atual: $e');
    }
  }

  Future<FullUserModel> getUserById(String id) async {
    try {
      if (!authService.isAuthenticated) {
        throw UserServiceException('Usuário não autenticado');
      }

      final response = await http.get(
        Api.userByIdEndpoint(id),
        headers: Headers.auth(authService),
      );

      // print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return FullUserModel.fromJson(jsonResponse);
      } else {
        throw UserServiceException(
          jsonResponse['error'],
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw UserServiceException('Erro ao buscar o usuário: $e');
    }
  }

  Future<List<UserDiaryModel>> getUserDiaryById(String id) async {
    try {
      if (!authService.isAuthenticated) {
        throw UserServiceException('Usuário não autenticado');
      }

      final response = await http.get(
        Api.userDiaryById(id),
        headers: Headers.auth(authService),
      );

      // print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<UserDiaryModel> diaryEntries = [];
        for (var entry in jsonResponse["results"]) {
          diaryEntries.add(UserDiaryModel.fromJson(entry));
        }
        return diaryEntries;
      } else {
        throw UserServiceException(
          jsonResponse['error'],
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw UserServiceException('Erro ao buscar o diário do usuário: $e');
    }
  }

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
          jsonResponse['error'],
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
          jsonResponse['error'],
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
          jsonResponse['error'],
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
          jsonResponse['error'],
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw UserServiceException('Erro ao deletar as séries ${type.name}: $e');
    }
  }

  Future<void> updateUserFields(Map<String, dynamic> fields) async {
    try {
      if (!authService.isAuthenticated) {
        throw UserServiceException('Usuário não autenticado');
      }

      final response = await http.patch(
        Api.currentUserEndpoint,
        headers: Headers.auth(authService),
        body: jsonEncode(fields),
      );

      // print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return;
      } else {
        throw UserServiceException(
          jsonResponse['error'],
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw UserServiceException('Erro ao atualizar os dados do usuário: $e');
    }
  }

  Future<String> uploadAvatar(
    XFile image,
  ) async {
    try {
      if (!authService.isAuthenticated) {
        throw UserServiceException('Usuário não autenticado');
      }

      final Uint8List fileBytes = await image.readAsBytes();
      final String mimeType = image.mimeType ?? 'image/jpeg';
      
      final request = http.MultipartRequest(
        'POST',
        Api.editAvatarEndpoint,
      );
      
      // Adiciona headers de autenticação
      final authHeaders = Headers.auth(authService);
      // Remove Content-Type pois o MultipartRequest define automaticamente
      authHeaders.remove('Content-Type');
      request.headers.addAll(authHeaders);

      final multipartFile = http.MultipartFile.fromBytes(
        'avatar', 
        fileBytes,
        filename: image.name,
        contentType: MediaType.parse(mimeType),
      );

      request.files.add(multipartFile);

      // Não seguir redirects automaticamente para evitar conversão POST -> GET
      final client = http.Client();
      final streamedResponse = await client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      client.close();

      //print('Status Code: ${response.statusCode}');
      //print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['avatar_url'];
      } else {
        try {
          final jsonResponse = jsonDecode(response.body);
          throw UserServiceException(
            jsonResponse['error'] ?? 'Erro desconhecido',
            code: response.statusCode.toString(),
          );
        } catch (_) {
          throw UserServiceException(
            'Erro no servidor: ${response.statusCode}',
            code: response.statusCode.toString(),
          );
        }
      }
    } catch (e) {
      if (e is UserServiceException) rethrow;
      throw UserServiceException('Erro ao fazer upload do avatar: $e');
    }
  }

  Future<void> followUser(String userId) async {
    try {
      if (!authService.isAuthenticated) {
        throw UserServiceException('Usuário não autenticado');
      }

      final response = await http.post(
        Api.userFollowsEndpoint(userId),
        headers: Headers.auth(authService),
      );

      //print('Status Code: ${response.statusCode}');
      //print('Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        final jsonResponse = jsonDecode(response.body);
        throw UserServiceException(
          jsonResponse['error'],
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw UserServiceException('Erro ao seguir o usuário: $e');
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      if (!authService.isAuthenticated) {
        throw UserServiceException('Usuário não autenticado');
      }

      final response = await http.delete(
        Api.userFollowsEndpoint(userId),
        headers: Headers.auth(authService),
      );

      //print('Status Code: ${response.statusCode}');
      //print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return;
      } else {
        final jsonResponse = jsonDecode(response.body);
        throw UserServiceException(
          jsonResponse['error'],
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw UserServiceException('Erro ao deixar de seguir o usuário: $e');
    }
  }
}
