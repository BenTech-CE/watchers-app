import 'package:watchers/core/services/auth/auth_service.dart';

class Api {
  static String baseUrl =
      'https://personal-watchers-api.yvovkl.easypanel.host/';
  static final Uri seriesTrendingEndpoint = Uri.parse(
    '${baseUrl}series/trending',
  );
  static Uri seriesSearchEndpoint(String query) =>
      Uri.parse('${baseUrl}series/search?q=$query');
  static Uri serieDetailsEndpoint(String id) =>
      Uri.parse('${baseUrl}series/$id');
}

class Headers {
  static Map<String, String> auth(AuthService authService) {
    return {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${authService.accessToken}',
    };
  }
}
