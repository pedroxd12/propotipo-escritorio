// lib/design/state/chat_provider.dart
import 'package:flutter/material.dart';
import 'package:serviceflow/data/models/chat_conversation_model.dart';
import 'package:serviceflow/data/repositories/chat_repository.dart';

class ChatProvider with ChangeNotifier {
  final ChatRepository _repository = ChatRepository();
  List<ChatConversation> _conversations = [];
  ChatConversation? _selectedConversation;
  bool _isLoading = false;

  List<ChatConversation> get conversations => _conversations;
  ChatConversation? get selectedConversation => _selectedConversation;
  bool get isLoading => _isLoading;

  ChatProvider() {
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    _isLoading = true;
    notifyListeners();
    _conversations = await _repository.getConversations();
    if (_conversations.isNotEmpty) {
      _selectedConversation = _conversations.first;
    }
    _isLoading = false;
    notifyListeners();
  }

  void selectConversation(ChatConversation conversation) {
    _selectedConversation = conversation;
    notifyListeners();
  }
}