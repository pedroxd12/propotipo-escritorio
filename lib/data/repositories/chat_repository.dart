// lib/data/repositories/chat_repository.dart
import 'package:serviceflow/data/models/chat_conversation_model.dart';
import 'package:serviceflow/data/models/chat_message_model.dart';
import 'package:serviceflow/data/models/usuario_model.dart';

class ChatRepository {
  // Datos de ejemplo
  static final _tecnico1 = Usuario(
      id: 'user-2', empresaId: 'emp-1', nombres: 'Carlos', apellidoPaterno: 'Sánchez', email: 'carlos@example.com', telefono: '312-000-1111', rol: 'Tecnico'
  );
  static final _tecnico2 = Usuario(
      id: 'user-3', empresaId: 'emp-1', nombres: 'María', apellidoPaterno: 'Gómez', email: 'maria@example.com', telefono: '312-000-2222', rol: 'Tecnico'
  );

  final List<ChatConversation> _conversations = [
    ChatConversation(
      id: 'conv-1',
      technician: _tecnico1,
      lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
      unreadCount: 2,
      messages: [
        ChatMessage(id: 'msg-1', conversationId: 'conv-1', senderId: 'user-2', text: 'Hola, ¿en qué puedo ayudarte?', timestamp: DateTime.now().subtract(const Duration(minutes: 6))),
        ChatMessage(id: 'msg-2', conversationId: 'conv-1', senderId: 'admin', text: 'Necesito el estatus de la orden OS-2024-002.', timestamp: DateTime.now().subtract(const Duration(minutes: 5))),
      ],
    ),
    ChatConversation(
      id: 'conv-2',
      technician: _tecnico2,
      lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
      messages: [
        ChatMessage(id: 'msg-3', conversationId: 'conv-2', senderId: 'user-3', text: 'El cliente no se encuentra en el domicilio.', timestamp: DateTime.now().subtract(const Duration(hours: 1))),
      ],
    ),
  ];

  Future<List<ChatConversation>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
    return _conversations;
  }
}