import 'dart:convert';

import 'package:watchers/core/models/global/home_model.dart';
import 'package:watchers/core/models/global/search_model.dart';
import 'package:watchers/core/models/global/type_filter_search.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:http/http.dart' as http;
import 'package:watchers/core/services/auth/auth_service.dart';
import 'package:watchers/core/utils/api.dart';

class AppServiceException implements Exception {
  final String message;
  final String? code;

  AppServiceException(this.message, {this.code}); 
  @override
  String toString() => message;
}

class AppService {
  final AuthService authService;
  AppService({required this.authService});

  Future<SearchModel> search(String query, TypeFilterSearch filter) async {
    try {
      if (!authService.isAuthenticated) {
        throw AppServiceException('Usuário não autenticado');
      }

      final body = jsonEncode({'query': query, 'filter': filter.name});

      // final headers = {
      //   ...Headers.auth(authService),
      //   'Content-Type': 'application/json',
      // };

      // final response = await http.get(
      //   Api.searchEndpoint,
      //   headers: headers,
      //   // body: body,
      // );
      final headers = {
        ...Headers.auth(authService),
        'Content-Type': 'application/json',
      };

      final request = http.Request('GET', Api.searchEndpoint);

      request.headers.addAll(headers);
      request.body = body;

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      // print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return SearchModel.fromJson(jsonResponse);
      } else {
        throw AppServiceException(
          jsonResponse['error'],
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw AppServiceException(
        'Erro ao fazer pesquisa de séries/listas/usuários: $e',
      );
    }
  }

  Future<HomeModel> fetchHomeData() async {
    try {
      if (!authService.isAuthenticated) {
        throw AppServiceException('Usuário não autenticado');
      }

      final headers = Headers.auth(authService);

      final response = await http.get(
        Api.homeEndpoint,
        headers: headers,
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return HomeModel.fromJson(jsonResponse);
      } else {
        throw AppServiceException(
          jsonResponse['error'],
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw AppServiceException(
        'Erro ao buscar dados iniciais: $e',
      );
    }
  }
}
