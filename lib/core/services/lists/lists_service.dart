import 'dart:convert';

import 'package:watchers/core/models/lists/full_list_model.dart';
import 'package:watchers/core/models/lists/list_model.dart';
import 'package:watchers/core/models/series/serie_model.dart';
import 'package:http/http.dart' as http;
import 'package:watchers/core/services/auth/auth_service.dart';
import 'package:watchers/core/utils/api.dart';

class ListsServiceException implements Exception {
  final String message;
  final String? code;

  ListsServiceException(this.message, {this.code});

  @override
  String toString() => message;
}

class ListsService {
  final AuthService authService;
  ListsService({required this.authService});

  Future<List<ListModel>> getAllLists() async {
    try {
      if (!authService.isAuthenticated) {
        throw ListsServiceException('Usuário não autenticado');
      }

      final response = await http.get(
        Api.allLists,
        headers: Headers.auth(authService),
      );

      // print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<ListModel> lists = [];
        for (var list in jsonResponse["results"]) {
          lists.add(ListModel.fromJson(list));
        }
        return lists;
      } else {
        throw ListsServiceException(
          'Erro ao buscar todas as listas: ${jsonResponse['error']}',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ListsServiceException('Erro ao buscar todas as listas: $e');
    }
  }

  Future<List<ListModel>> getTrendingLists() async {
    try {
      if (!authService.isAuthenticated) {
        throw ListsServiceException('Usuário não autenticado');
      }

      final response = await http.get(
        Api.trendingLists,
        headers: Headers.auth(authService),
      );

      // print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<ListModel> lists = [];
        for (var list in jsonResponse["results"]) {
          lists.add(ListModel.fromJson(list));
        }
        return lists;
      } else {
        throw ListsServiceException(
          'Erro ao buscar todas as listas: ${jsonResponse['error']}',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ListsServiceException('Erro ao buscar todas as listas: $e');
    }
  }

  Future<List<SerieModel>> getListSeries(String id) async {
    try {
      if (!authService.isAuthenticated) {
        throw ListsServiceException('Usuário não autenticado');
      }

      final response = await http.get(
        Api.listSeries(id),
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
        throw ListsServiceException(
          'Erro ao buscar as séries da lista: ${jsonResponse['error']}',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ListsServiceException('Erro ao buscar as séries da lista: $e');
    }
  }

  Future<bool> addSeriesToList(
    String id,
    List<int> seriesIds,
  ) async {
    try {
      if (!authService.isAuthenticated) {
        throw ListsServiceException('Usuário não autenticado');
      }

      final response = await http.post(
        Api.listSeries(id),
        headers: Headers.auth(authService),
        body: jsonEncode({'ids': seriesIds}),
      );

      // print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ListsServiceException(
          'Erro ao adicionar as séries na lista: ${jsonResponse['error']}',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ListsServiceException('Erro ao adicionar as séries na lista: $e');
    }
  }

  Future<bool> removeSeriesFromList(
    String id,
    List<int> seriesIds,
  ) async {
    try {
      if (!authService.isAuthenticated) {
        throw ListsServiceException('Usuário não autenticado');
      }

      final response = await http.delete(
        Api.listSeries(id),
        headers: Headers.auth(authService),
        body: jsonEncode({'ids': seriesIds}),
      );

      // print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw ListsServiceException(
          'Erro ao adicionar as séries na lista: ${jsonResponse['error']}',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ListsServiceException('Erro ao adicionar as séries na lista: $e');
    }
  }

  Future<FullListModel> getListDetails(String id) async {
    try {
      if (!authService.isAuthenticated) {
        throw ListsServiceException('Usuário não autenticado');
      }

      final response = await http.get(
        Api.listDetails(id),
        headers: Headers.auth(authService),
      );

      // print('Status Code: ${response.statusCode}');
      // print('Response Body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final FullListModel list = FullListModel.fromJson(jsonResponse);
        return list;
      } else {
        throw ListsServiceException(
          'Erro ao buscar os detalhes da lista: ${jsonResponse['error']}',
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      throw ListsServiceException('Erro ao buscar os detalhes da lista: $e');
    }
  }
}
