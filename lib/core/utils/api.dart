import 'package:watchers/core/services/auth/auth_service.dart';

class Api {
  static String baseUrl =
      'https://personal-watchers-api.yvovkl.easypanel.host/';

  // SERIES

  static final Uri seriesTrendingEndpoint = Uri.parse(
    '${baseUrl}series/trending',
  );
  static Uri seriesSearchEndpoint(String query) =>
      Uri.parse('${baseUrl}series/search?q=$query');
  static Uri serieDetailsEndpoint(String id) =>
      Uri.parse('${baseUrl}series/$id');

  // LIST

  static final Uri allLists = Uri.parse('${baseUrl}lists/');
  static Uri listSeries(String id) => Uri.parse('${baseUrl}lists/$id/items');
  static Uri listDetails(String id) => Uri.parse('${baseUrl}lists/$id');
}

class Headers {
  static Map<String, String> auth(AuthService authService) {
    return {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${authService.accessToken}',
    };
  }
}
