// lib/data/models/chat_conversation_model.dart
import 'package:serviceflow/data/models/usuario_model.dart';
import 'package:serviceflow/data/models/chat_message_model.dart';

class ChatConversation {
  final String id;
  final Usuario technician;
  final List<ChatMessage> messages;
  final int unreadCount;
  final DateTime lastMessageTime;

  ChatConversation({
    required this.id,
    required this.technician,
    required this.messages,
    this.unreadCount = 0,
    required this.lastMessageTime,
  });

  String get lastMessagePreview {
    if (messages.isEmpty) {
      return "No hay mensajes";
    }
    return messages.last.text;
  }
}