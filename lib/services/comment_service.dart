import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/comment.dart';
import '../models/user.dart';
import 'api_exception.dart';

class CommentService {
  CommentService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Comment>> getCommentsForPost(int postId) async {
    if (postId < 1) {
      throw const ApiException('Invalid post ID.');
    }
    try {
      final response = await _client
          .get(Uri.parse('$dummyJsonHost/comments/post/$postId?limit=50'))
          .timeout(apiTimeout);
      final decoded = _decodeObject(response.body);
      if (response.statusCode != 200) {
        throw ApiException(
          decoded['message']?.toString() ?? 'Unable to load comments.',
          statusCode: response.statusCode,
        );
      }
      final commentsJson = decoded['comments'];
      if (commentsJson is! List) {
        throw const FormatException('Missing comments list.');
      }
      return commentsJson
          .whereType<Map<String, dynamic>>()
          .map(Comment.fromJson)
          .toList(growable: true);
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('Loading comments timed out.');
    } on FormatException {
      throw const ApiException('The server returned invalid comment data.');
    } on http.ClientException {
      throw const ApiException('Unable to connect to DummyJSON.');
    } catch (error) {
      throw ApiException('Unable to load comments: $error');
    }
  }

  Future<Comment> addComment({
    required int postId,
    required User user,
    required String body,
  }) async {
    final trimmedBody = body.trim();
    if (postId < 1 || user.id < 1 || trimmedBody.isEmpty) {
      throw const ApiException('A valid comment is required.');
    }
    try {
      final response = await _client
          .post(
            Uri.parse('$dummyJsonHost/comments/add'),
            headers: const <String, String>{
              'Content-Type': 'application/json',
            },
            body: jsonEncode(<String, Object>{
              'body': trimmedBody,
              'postId': postId,
              'userId': user.id,
            }),
          )
          .timeout(apiTimeout);
      final decoded = _decodeObject(response.body);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ApiException(
          decoded['message']?.toString() ?? 'Unable to add the comment.',
          statusCode: response.statusCode,
        );
      }
      return Comment(
        id: (decoded['id'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
        body: decoded['body']?.toString() ?? trimmedBody,
        postId: (decoded['postId'] as num?)?.toInt() ?? postId,
        likes: (decoded['likes'] as num?)?.toInt() ?? 0,
        user: CommentAuthor(
          id: user.id,
          username: user.username,
          fullName: user.fullName,
        ),
      );
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('Adding the comment timed out.');
    } on FormatException {
      throw const ApiException('The server returned invalid comment data.');
    } on http.ClientException {
      throw const ApiException('Unable to connect to DummyJSON.');
    } catch (error) {
      throw ApiException('Unable to add the comment: $error');
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
