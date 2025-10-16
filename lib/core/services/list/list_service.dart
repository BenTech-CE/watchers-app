import 'dart:convert';

import 'package:watchers/core/models/series/serie_model.dart';
import 'package:http/http.dart' as http;
import 'package:watchers/core/services/auth/auth_service.dart';
import 'package:watchers/core/utils/api.dart';

class ListServiceException implements Exception {
  final String message;
  final String? code;

  ListServiceException(this.message, {this.code});

  @override
  String toString() => message;
}

class ListService {
  final AuthService authService;
  ListService({required this.authService});

  Future<List<SerieModel>> getAllLists() async {
    try {
      if (!authService.isAuthenticated) {
        throw ListServiceException('Usuário não autenticado');
      }

      final response = await http.get(
        Api.allLists,
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
        throw ListServiceException(
          'Erro ao buscar todas as listas: ${jsonResponse['error']}',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ListServiceException('Erro ao buscar todas as listas: $e');
    }
  }
}
