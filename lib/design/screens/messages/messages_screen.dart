// lib/design/screens/messages/messages_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:serviceflow/core/theme/app_colors.dart';
import 'package:serviceflow/data/models/chat_conversation_model.dart';
import 'package:serviceflow/data/models/chat_message_model.dart';
import 'package:serviceflow/design/state/chat_provider.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _ConversationList(
                    conversations: provider.conversations,
                    selectedConversation: provider.selectedConversation,
                    onSelect: (conversation) => provider.selectConversation(conversation),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 4,
                  // >>> MEJORA DE FLUIDEZ: AnimatedSwitcher para el panel de chat
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 0.99, end: 1.0).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: provider.selectedConversation != null
                        ? _ChatView(
                      key: ValueKey(provider.selectedConversation!.id), // Clave para la animación
                      conversation: provider.selectedConversation!,
                    )
                        : const Card(
                      key: ValueKey('empty_chat'), // Clave para el estado vacío
                      child: Center(
                        child: Text("Selecciona una conversación para empezar a chatear."),
                      ),
                    ),
                  ),
                  // <<< FIN DE MEJORA
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ConversationList extends StatelessWidget {
  final List<ChatConversation> conversations;
  final ChatConversation? selectedConversation;
  final Function(ChatConversation) onSelect;

  const _ConversationList({
    required this.conversations,
    this.selectedConversation,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar técnico...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final conversation = conversations[index];
                final isSelected = selectedConversation?.id == conversation.id;
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(conversation.technician.nombres[0]),
                  ),
                  title: Text(
                    conversation.technician.nombreCompleto,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    conversation.lastMessagePreview,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.Hm().format(conversation.lastMessageTime),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (conversation.unreadCount > 0) ...[
                        const SizedBox(height: 4),
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.primaryColor,
                          child: Text(
                            conversation.unreadCount.toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                  onTap: () => onSelect(conversation),
                  selected: isSelected,
                  selectedTileColor: AppColors.navItemActive,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatView extends StatelessWidget {
  final ChatConversation conversation;
  const _ChatView({required this.conversation, required ValueKey<String> key});

  @override
  Widget build(BuildContext context) {
    final messageController = TextEditingController();

    return Card(
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.outline)),
            ),
            child: Row(
              children: [
                CircleAvatar(child: Text(conversation.technician.nombres[0])),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    conversation.technician.nombreCompleto,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
              ],
            ),
          ),
          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              reverse: true, // Para mostrar los últimos mensajes abajo
              itemCount: conversation.messages.length,
              itemBuilder: (context, index) {
                final message = conversation.messages[conversation.messages.length - 1 - index];
                final bool isMe = message.senderId == 'admin'; // Asumiendo que el admin es el usuario actual
                return _MessageBubble(message: message, isMe: isMe);
              },
            ),
          ),
          // Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.outline)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      fillColor: Colors.transparent, // Asegura que no tenga fondo extra
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primaryColor),
                  onPressed: () {
                    // Lógica para enviar mensaje
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5), // Limitamos el ancho para mejor lectura
        decoration: BoxDecoration(
          color: isMe ? AppColors.primaryColor : AppColors.surfaceVariant,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isMe ? 20 : 4),
            topRight: Radius.circular(isMe ? 4 : 20),
            bottomLeft: const Radius.circular(20),
            bottomRight: const Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimaryColor),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat.Hm().format(message.timestamp),
              style: TextStyle(
                color: isMe ? Colors.white70 : AppColors.textSecondaryColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}