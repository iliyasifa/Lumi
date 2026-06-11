import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_flutter_clone/models/message.dart';
import 'package:instagram_flutter_clone/screens/profile/profile_screen.dart';
import 'package:instagram_flutter_clone/view_models/auth/auth_view_model.dart';
import 'package:instagram_flutter_clone/view_models/messages/message_view_model.dart';

class ChatScreen extends HookConsumerWidget {
  final String targetUid;
  final Map<String, dynamic> targetUserData;

  const ChatScreen({
    super.key,
    required this.targetUid,
    required this.targetUserData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController();
    final authState = ref.watch(authViewModelProvider);
    final currentUser = authState.user;

    if (currentUser == null) return const Scaffold();

    final chatId = ref.read(messageMethodsProvider).getChatId(currentUser.uid, targetUid);
    final messagesAsyncValue = ref.watch(chatMessagesStreamProvider(chatId));

    void sendMessage() async {
      if (textController.text.trim().isEmpty) return;

      final text = textController.text;
      textController.clear();

      await ref.read(messageMethodsProvider).sendMessage(
            currentUid: currentUser.uid,
            targetUid: targetUid,
            text: text,
          );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfileScreen(uid: targetUid),
              ),
            );
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: CachedNetworkImageProvider(
                  (targetUserData['photoUrl'] != null &&
                          targetUserData['photoUrl'].toString().isNotEmpty)
                      ? targetUserData['photoUrl']
                      : 'https://i.stack.imgur.com/l60Hf.png',
                ),
                backgroundColor: Colors.grey.shade900,
              ),
              const SizedBox(width: 12),
              Text(
                targetUserData['username'] ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsyncValue.when(
              data: (messages) {
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.senderId == currentUser.uid;

                    return _MessageBubble(message: message, isMe: isMe);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error', style: const TextStyle(color: Colors.white)),
              ),
            ),
          ),

          // Input Area
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Message...',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: sendMessage,
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
  final Message message;
  final bool isMe;

  const _MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (message.type == 'post' && message.postData != null)
              _buildSharedPost(context, message.postData!),
            if (message.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isMe ? const Color(0xFF0095F6) : Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  message.text,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSharedPost(BuildContext context, Map<String, dynamic> postData) {
    return GestureDetector(
      onTap: () {
        // Could navigate to PostDetailScreen
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundImage: CachedNetworkImageProvider(
                      (postData['userProfileUrl'] != null &&
                              postData['userProfileUrl'].toString().isNotEmpty)
                          ? postData['userProfileUrl']
                          : 'https://i.stack.imgur.com/l60Hf.png',
                    ),
                    backgroundColor: Colors.grey.shade900,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    postData['username'] ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: CachedNetworkImage(
                imageUrl: postData['postUrl'] ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade900),
              ),
            ),
            if ((postData['description'] ?? '').isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  postData['description'],
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
