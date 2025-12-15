import 'dart:convert';

import 'package:watchers/core/models/global/comment_model.dart';
import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/models/reviews/full_review_model.dart';
import 'package:watchers/core/models/reviews/review_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:http/http.dart' as http;
import 'package:watchers/core/services/auth/auth_service.dart';
import 'package:watchers/core/utils/api.dart';

class ReviewsServiceException implements Exception {
  final String message;
  final String? code;

  ReviewsServiceException(this.message, {this.code});
  @override
  String toString() => message;
}

class ReviewsService {
  final AuthService authService;
  ReviewsService({required this.authService});

  Future<List<ReviewModel>> getTrendingReviews() async {
    try {
      if (!authService.isAuthenticated) {
        throw ReviewsServiceException('Usuário não autenticado');
      }

      final response = await http.get(
        Api.reviewsTrendingEndpoint,
        headers: Headers.auth(authService),
      );

      // print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<ReviewModel> reviews = [];
        for (var review in jsonResponse["results"]) {
          reviews.add(ReviewModel.fromJson(review));
        }
        return reviews;
      } else {
        throw ReviewsServiceException(
          jsonResponse['error'],
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ReviewsServiceException('Erro ao buscar todas as resenhas: $e');
    }
  }

  Future<FullReviewModel> getReviewById(String reviewId) async {
    try {
      if (!authService.isAuthenticated) {
        throw ReviewsServiceException('Usuário não autenticado');
      }

      final response = await http.get(
        Api.reviewByIdEndpoint(reviewId),
        headers: Headers.auth(authService),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return FullReviewModel.fromJson(jsonResponse);
      } else {
        throw ReviewsServiceException(
          jsonResponse['error'],
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ReviewsServiceException('Erro ao buscar a resenha: $e');
    }
  }

  Future<void> likeReview(String reviewId) async {
    try {
      if (!authService.isAuthenticated) {
        throw ReviewsServiceException('Usuário não autenticado');
      }

      final response = await http.post(
        Api.reviewLikes(reviewId),
        headers: Headers.auth(authService),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw ReviewsServiceException(
          jsonResponse['error'],
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ReviewsServiceException('Erro ao curtir a resenha: $e');
    }
  }

  Future<void> unlikeReview(String reviewId) async {
    try {
      if (!authService.isAuthenticated) {
        throw ReviewsServiceException('Usuário não autenticado');
      }

      final response = await http.delete(
        Api.reviewLikes(reviewId),
        headers: Headers.auth(authService),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw ReviewsServiceException(
          jsonResponse['error'],
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ReviewsServiceException('Erro ao descurtir a resenha: $e');
    }
  }

  Future<void> deleteComment(String reviewId, String commentId) async {
    try {
      if (!authService.isAuthenticated) {
        throw ReviewsServiceException('Usuário não autenticado');
      }

      final response = await http.delete(
        Api.reviewSingleComment(reviewId, commentId),
        headers: Headers.auth(authService),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode != 200) {
        throw ReviewsServiceException(
          jsonResponse['error'],
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ReviewsServiceException('Erro ao deletar o comentário: $e');
    }
  }

  Future<CommentModel> addComment(String reviewId, String content) async {
    try {
      if (!authService.isAuthenticated) {
        throw ReviewsServiceException('Usuário não autenticado');
      }

      final response = await http.post(
        Api.reviewComments(reviewId),
        headers: Headers.auth(authService),
        body: jsonEncode({'content': content}),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return CommentModel.fromJson(jsonResponse);
      } else {
        throw ReviewsServiceException(
          jsonResponse['error'],
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ReviewsServiceException('Erro ao adicionar o comentário: $e');
    }
  }
}
