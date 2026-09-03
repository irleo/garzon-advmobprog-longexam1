import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import '../models/user.dart';
import 'api_exception.dart';

class UserService {
  UserService({http.Client? client}) : _client = client ?? http.Client();

  static const String _loggedInKey = 'loggedIn';
  static const String _userKey = 'authenticatedUser';
  static const String _accessTokenKey = 'accessToken';

  final http.Client _client;

  Future<User> login({
    required String username,
    required String password,
  }) async {
    final trimmedUsername = username.trim();
    if (trimmedUsername.isEmpty || password.trim().isEmpty) {
      throw const ApiException('Username and password are required.');
    }
    try {
      final uri = Uri.parse('$dummyJsonHost/users/filter').replace(
        queryParameters: <String, String>{
          'key': 'username',
          'value': trimmedUsername,
          'limit': '1',
        },
      );
      final response = await _client.get(uri).timeout(apiTimeout);
      final data = _decodeObject(response.body);

      if (response.statusCode != 200) {
        throw ApiException(
          data['message']?.toString() ?? 'Unable to sign in.',
          statusCode: response.statusCode,
        );
      }

      final usersJson = data['users'];
      if (usersJson is! List) {
        throw const FormatException('Missing users list.');
      }
      final matchingUsers = usersJson
          .whereType<Map<String, dynamic>>()
          .toList();
      final user = matchingUsers.isNotEmpty
          ? User.fromJson(matchingUsers.first)
          : (await getUser(1)).copyWith(username: trimmedUsername);
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_loggedInKey, true);
      await preferences.setString(_userKey, jsonEncode(user.toJson()));
      await preferences.setString(_accessTokenKey, '');
      return user;
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('The request timed out. Please try again.');
    } on FormatException {
      throw const ApiException('The server returned invalid user data.');
    } on http.ClientException {
      throw const ApiException('Unable to connect to DummyJSON.');
    } catch (error) {
      throw ApiException('Sign in failed: $error');
    }
  }

  Future<User?> restoreUser() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      if (!(preferences.getBool(_loggedInKey) ?? false)) {
        return null;
      }
      final encodedUser = preferences.getString(_userKey);
      if (encodedUser == null || encodedUser.isEmpty) {
        await clearSession();
        return null;
      }
      return User.fromJson(_decodeObject(encodedUser));
    } on FormatException {
      await clearSession();
      return null;
    } catch (error) {
      throw ApiException('Unable to restore the saved session: $error');
    }
  }

  Future<User> getUser(int userId) async {
    try {
      final response = await _client
          .get(Uri.parse('$dummyJsonHost/users/$userId'))
          .timeout(apiTimeout);
      final data = _decodeObject(response.body);
      if (response.statusCode != 200) {
        throw ApiException(
          data['message']?.toString() ?? 'Unable to load user $userId.',
          statusCode: response.statusCode,
        );
      }
      return User.fromJson(data);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('Loading the user timed out.');
    } on FormatException {
      throw const ApiException('The server returned invalid user data.');
    } on http.ClientException {
      throw const ApiException('Unable to connect to DummyJSON.');
    } catch (error) {
      throw ApiException('Unable to load the user: $error');
    }
  }

  Future<void> clearSession() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(_loggedInKey);
      await preferences.remove(_userKey);
      await preferences.remove(_accessTokenKey);
    } catch (error) {
      throw ApiException('Unable to clear the saved session: $error');
    }
  }

  Map<String, dynamic> _decodeObject(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected a JSON object.');
    }
    return decoded;
  }

  void dispose() => _client.close();
}
