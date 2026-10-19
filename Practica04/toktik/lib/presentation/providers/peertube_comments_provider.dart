import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/youtube_comment.dart';

class PeerTubeCommentsProvider extends ChangeNotifier {
  final http.Client client;
  final Map<String, List<YouTubeComment>> _cache = {};

  PeerTubeCommentsProvider(this.client);

  List<YouTubeComment> comments = const [];
  String? selectedVideoId;
  String? error;
  bool loading = false;
  int _request = 0;

  Future<void> load(String videoReference) async {
    final request = ++_request;
    selectedVideoId = videoReference;
    final cached = _cache[videoReference];
    comments = cached ?? const [];
    error = null;
    if (cached != null) {
      loading = false;
      notifyListeners();
      return;
    }
    loading = true;
    notifyListeners();
    try {
      final split = videoReference.lastIndexOf('/');
      if (split <= 0 || split == videoReference.length - 1) {
        throw const FormatException('Referencia PeerTube no válida.');
      }
      final host = videoReference.substring(0, split);
      final videoId = videoReference.substring(split + 1);
      final uri = Uri.https(
        host,
        '/api/v1/videos/${Uri.encodeComponent(videoId)}/comment-threads',
        {'count': '20', 'sort': '-createdAt'},
      );
      final response = await client.get(uri).timeout(
        const Duration(seconds: 15),
      );
      if (request != _request) return;
      if (response.statusCode != 200) {
        throw StateError('PeerTube respondió HTTP ${response.statusCode}.');
      }
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final result = <YouTubeComment>[];
      for (final item in payload['data'] as List? ?? const []) {
        if (item is Map<String, dynamic>) _appendThread(item, result);
      }
      comments = result;
      _cache[videoReference] = result;
    } catch (exception) {
      if (request == _request) error = exception.toString();
    } finally {
      if (request == _request) {
        loading = false;
        notifyListeners();
      }
    }
  }

  void _appendThread(Map<String, dynamic> thread, List<YouTubeComment> into) {
    final comment = thread['comment'] is Map<String, dynamic>
        ? thread['comment'] as Map<String, dynamic>
        : thread;
    if (comment['isDeleted'] != true) {
      final text = '${comment['text'] ?? ''}'.trim();
      if (text.isNotEmpty) {
        final account = comment['account'] as Map<String, dynamic>? ?? const {};
        into.add(
          YouTubeComment(
            author:
                '${account['displayName'] ?? account['name'] ?? 'Usuario PeerTube'}',
            text: text,
            likeCount: int.tryParse('${comment['likes'] ?? 0}') ?? 0,
          ),
        );
      }
    }
    for (final child in thread['children'] as List? ?? const []) {
      if (child is Map<String, dynamic>) _appendThread(child, into);
    }
  }
}
