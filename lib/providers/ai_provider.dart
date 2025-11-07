import 'dart:async';
import 'package:enviro_agri_manager/models/message_model.dart';
import 'package:enviro_agri_manager/repositories/ai_repository.dart';
import 'package:flutter/foundation.dart';

class AiProvider with ChangeNotifier {
  AiRepository _repository;
  final List<Message> _messages = [];
  final _messageStreamController = StreamController<List<Message>>.broadcast();

  Stream<List<Message>> get messageStream => _messageStreamController.stream;
  List<Message> get currentMessages => List.unmodifiable(_messages);

  AiProvider(this._repository);
  void update(AiRepository repo) {
    _repository = repo;
  }

  Future<void> sendMessage(String content, bool isOnline) async {
    final userMsg = Message(
      sender: 'user',
      content: content,
      timestamp: DateTime.now(),
    );
    _messages.add(userMsg);
    _messageStreamController.add(_messages);
    notifyListeners();

    final botMsg = Message(
      sender: 'bot',
      content: '...',
      timestamp: DateTime.now(),
    );
    _messages.add(botMsg);
    _messageStreamController.add(_messages);

    final index = _messages.length - 1;

    await for (final partial in _repository.getBotReplyStream(
      content,
      isOnline,
    )) {
      _messages[index] = partial;
      _messageStreamController.add(List.from(_messages));
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _messageStreamController.close();
    super.dispose();
  }
}
