import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yes_no_app/domain/entities/message.dart';

// Clave gratuita de https://developers.giphy.com (Create an App > API).
// Si se deja vacía, se usan los GIFs que devuelve yesno.wtf.
const String _giphyApiKey = '';

const Map<String, List<String>> _gifQueries = {
  'yes': ['yes', 'yes reaction', 'nod yes', 'celebrate', 'love heart'],
  'no': ['no', 'nope', 'no way', 'shake head no', 'angry no'],
  'maybe': ['maybe', 'shrug', 'not sure', 'hmm thinking', 'confused'],
};

class ChatProvider extends ChangeNotifier {
  final ScrollController chatScrollController = ScrollController();

  final List<Message> messageList = [];
  final Random _random = Random();

  Future<void> sendMessage( String text ) async {
    if (text.trim().isEmpty) return;
    final newMessage = Message(text: text, fromWho: FromWho.me);
    messageList.add(newMessage);

    notifyListeners();
    moveScrollToBottom();

    if (_random.nextInt(100) < 20) {
      messageList.add(Message(
        text: 'Tal vez',
        imageUrl: await _fetchGif('maybe',
            'https://media1.tenor.com/m/mFlSH_ZAUfsAAAAd/yes-no.gif'),
        fromWho: FromWho.her,
      ));
      notifyListeners();
      moveScrollToBottom();
      return;
    }

    try {
      final response = await http.get(Uri.https('yesno.wtf', '/api'));
      debugPrint('HTTP ${response.statusCode}: ${response.body}');
      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final apiAnswer = data['answer'] as String;
      final text = switch (apiAnswer) {
        'yes' => 'S\u00ed',
        'no' => 'No',
        'maybe' => 'Tal vez',
        _ => throw const FormatException('Respuesta desconocida de yesno.wtf'),
      };
      messageList.add(Message(
        text: text,
        imageUrl: await _fetchGif(apiAnswer, data['image'] as String?),
        fromWho: FromWho.her,
      ));
    } catch (error, stackTrace) {
      debugPrint('Error al consultar yesno.wtf: $error');
      debugPrintStack(stackTrace: stackTrace);

      messageList.add(Message(
        text: 'No pude obtener una respuesta. Int\u00e9ntalo de nuevo.',
        fromWho: FromWho.her,
      ));
    }
    notifyListeners();
    moveScrollToBottom();
  }

  /// Busca un GIF distinto en Giphy; si falla, regresa [fallback].
  Future<String?> _fetchGif(String answer, String? fallback) async {
    if (_giphyApiKey.isEmpty) return fallback;
    try {
      final queries = _gifQueries[answer] ?? _gifQueries['maybe']!;
      final uri = Uri.https('api.giphy.com', '/v1/gifs/search', {
        'api_key': _giphyApiKey,
        'q': queries[_random.nextInt(queries.length)],
        'limit': '25',
        'rating': 'g',
      });
      final response = await http.get(uri);
      if (response.statusCode != 200) return fallback;
      final results = (jsonDecode(response.body)['data'] as List);
      if (results.isEmpty) return fallback;
      final gif = results[_random.nextInt(results.length)];
      return gif['images']['original']['url'] as String? ?? fallback;
    } catch (error) {
      debugPrint('Error al consultar Giphy: $error');
      return fallback;
    }
  }

  Future<void> moveScrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));
    chatScrollController.animateTo(
      chatScrollController.position.maxScrollExtent,
      duration: const Duration( milliseconds: 300 ),
      curve: Curves.easeOut
    );
  }
}
