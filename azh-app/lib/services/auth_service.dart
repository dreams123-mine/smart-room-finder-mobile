import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String baseUrl =
      "https://ubiquitous-space-fiesta-v6j9pxqwx5q427gw-8081.app.github.dev/api";

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _tokenKey = 'azhly_jwt_token';

  // MOBILE LOGIN
  Future<Map<String, dynamic>> mobileLogin({
    required String username,
    required String password,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/mobile-login"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "username": username,
        "password": password,
        "role": role,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200) {
      final token = data['token'];

      if (token == null || token.toString().isEmpty) {
        throw Exception("Login response did not contain an authentication token.");
      }

      await _storage.write(
        key: _tokenKey,
        value: token.toString(),
      );

      return data;
    }

    throw Exception(
      data['message'] ?? "Login failed. Please check your credentials.",
    );
  }

  // MOBILE SELF-REGISTRATION
  Future<Map<String, dynamic>> mobileRegister({
    required String universityId,
    required String email,
    required String role,
    required String claimCode,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/mobile-register"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "universityId": universityId,
        "email": email,
        "role": role,
        "claimCode": claimCode,
        "password": password,
        "confirmPassword": confirmPassword,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }

    throw Exception(
      data['message'] ?? "Registration failed. Please try again.",
    );
  }

  // RESTORE SAVED SESSION
    // RESTORE SAVED SESSION
  Future<String?> getSavedToken() {
    return _storage.read(key: _tokenKey);
  }

  // FETCH CURRENT USER USING SAVED JWT
  Future<Map<String, dynamic>?> restoreSession() async {
    final token = await getSavedToken();

    if (token == null || token.isEmpty) {
      return null;
    }

    final response = await http.get(
      Uri.parse("$baseUrl/auth/mobile-me"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    if (response.statusCode == 401 ||
        response.statusCode == 403) {
      await logout();
      return null;
    }

    throw Exception("Unable to restore session. Please try again.");
  }

  // LOGOUT
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
  }
}
