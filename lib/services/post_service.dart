import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/post.dart';
import 'api_exception.dart';

class PostService {
  PostService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Post>> getPosts({int limit = 30, int skip = 0}) async {
    if (limit < 1 || limit > 50 || skip < 0) {
      throw const ApiException('Invalid post pagination values.');
    }
    return _getPostList(
      Uri.parse('$dummyJsonHost/posts?limit=$limit&skip=$skip'),
    );
  }

  Future<List<Post>> getPostsByUser(int userId, {int limit = 30}) async {
    if (userId < 1 || limit < 1 || limit > 50) {
      throw const ApiException('Invalid user post request.');
    }
    return _getPostList(
      Uri.parse('$dummyJsonHost/posts/user/$userId?limit=$limit'),
    );
  }

  Future<List<Post>> _getPostList(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(apiTimeout);
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object.');
      }
      if (response.statusCode != 200) {
        throw ApiException(
          decoded['message']?.toString() ?? 'Unable to load posts.',
          statusCode: response.statusCode,
        );
      }
      final postsJson = decoded['posts'];
      if (postsJson is! List) {
        throw const FormatException('Missing posts list.');
      }
      return postsJson
          .whereType<Map<String, dynamic>>()
          .map(Post.fromJson)
          .toList(growable: false);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('Loading posts timed out.');
    } on FormatException {
      throw const ApiException('The server returned invalid post data.');
    } on http.ClientException {
      throw const ApiException('Unable to connect to DummyJSON.');
    } catch (error) {
      throw ApiException('Unable to load posts: $error');
    }
  }

  void dispose() => _client.close();
}
