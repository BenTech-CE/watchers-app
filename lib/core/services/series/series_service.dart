import 'dart:convert';

import 'package:watchers/core/models/series/serie_model.dart';
import 'package:http/http.dart' as http;
import 'package:watchers/core/services/auth/auth_service.dart';
import 'package:watchers/core/utils/api.dart';

class SeriesServiceException implements Exception {
  final String message;
  final String? code;

  SeriesServiceException(this.message, {this.code});

  @override
  String toString() => message;
}

class SeriesService {
  final AuthService authService;
  SeriesService({required this.authService});

  Future<List<SerieModel>> getSeriesTrending() async {
    try {
      if (!authService.isAuthenticated) {
        throw SeriesServiceException('Usuário não autenticado');
      }

      final response = await http.get(
        Api.seriesTrendingEndpoint,
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
        throw SeriesServiceException(
          'Erro ao buscar séries: ${jsonResponse['error']}',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw SeriesServiceException('Erro ao buscar séries: $e');
    }
  }

  Future<List<SerieModel>> getSeriesSearch(String query) async {
    try {
      if (!authService.isAuthenticated) {
        throw SeriesServiceException('Usuário não autenticado');
      }

      final response = await http.get(
        Api.seriesSearchEndpoint(query),
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
        throw SeriesServiceException(
          'Erro ao buscar séries: ${jsonResponse['error']}',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw SeriesServiceException('Erro ao buscar séries: $e');
    }
  }

  Future<SerieModel?> getSerieDetails(String id) async {
    try {
      if (!authService.isAuthenticated) {
        throw SeriesServiceException('Usuário não autenticado');
      }

      final response = await http.get(
        Api.serieDetailsEndpoint(id),
        headers: Headers.auth(authService),
      );

      // print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return SerieModel.fromJson(jsonResponse);
      } else {
        throw SeriesServiceException(
          'Erro ao buscar os detalhes da série: ${jsonResponse['error']}',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw SeriesServiceException('Erro ao buscar os detalhes da série: $e');
    }
  }
}
