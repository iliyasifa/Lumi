import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_flutter_clone/models/chat.dart';
import 'package:instagram_flutter_clone/screens/messages/chat_screen.dart';
import 'package:instagram_flutter_clone/view_models/auth/auth_view_model.dart';
import 'package:instagram_flutter_clone/view_models/messages/message_view_model.dart';
import 'package:intl/intl.dart';

class InboxScreen extends HookConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxAsyncValue = ref.watch(inboxStreamProvider);
    final authState = ref.watch(authViewModelProvider);
    final currentUser = authState.user;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          currentUser?.username ?? 'Messages',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              // TODO: Implement new message user picker
            },
          ),
        ],
      ),
      body: inboxAsyncValue.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const Center(
              child: Text(
                'No messages yet.',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _ChatTile(chat: chat, currentUid: currentUser!.uid);
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
    );
  }
}

class _ChatTile extends HookConsumerWidget {
  final Chat chat;
  final String currentUid;

  const _ChatTile({required this.chat, required this.currentUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find target user id
    final targetUid = chat.participants.firstWhere(
      (id) => id != currentUid,
      orElse: () => currentUid,
    );

    // Fetch target user data
    final targetUserFuture = FirebaseFirestore.instance.collection('users').doc(targetUid).get();

    return FutureBuilder<DocumentSnapshot>(
      future: targetUserFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final userData = snapshot.data!.data() as Map<String, dynamic>?;
        if (userData == null) return const SizedBox.shrink();

        final bool isUnread = (chat.unreadCount[currentUid] ?? 0) > 0;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: CircleAvatar(
            radius: 24,
            backgroundImage: CachedNetworkImageProvider(
              (userData['photoUrl'] != null && userData['photoUrl'].toString().isNotEmpty)
                  ? userData['photoUrl']
                  : 'https://i.stack.imgur.com/l60Hf.png',
            ),
            backgroundColor: Colors.grey.shade900,
          ),
          title: Text(
            userData['username'] ?? '',
            style: TextStyle(
              color: Colors.white,
              fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          subtitle: Row(
            children: [
              Expanded(
                child: Text(
                  chat.lastMessage.isEmpty ? 'Say hi!' : chat.lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isUnread ? Colors.white : Colors.white.withValues(alpha: 0.6),
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(chat.lastMessageTime),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          trailing: isUnread
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () {
            ref.read(messageMethodsProvider).markChatAsRead(chat.chatId, currentUid);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  targetUid: targetUid,
                  targetUserData: userData,
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) {
      if (diff.inDays < 7) {
        return '${diff.inDays}d';
      }
      return DateFormat('MMM d').format(dateTime);
    }
    if (diff.inHours > 0) {
      return '${diff.inHours}h';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m';
    }
    return 'now';
  }
}
