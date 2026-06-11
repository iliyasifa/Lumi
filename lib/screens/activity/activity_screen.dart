import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lumi/models/notification.dart';
import 'package:lumi/resources/firestore_methods.dart';
import 'package:lumi/screens/post/post_detail_screen.dart';
import 'package:lumi/screens/profile/profile_screen.dart';
import 'package:lumi/view_models/auth/auth_view_model.dart';
import 'package:lumi/view_models/notifications/notifications_view_model.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final currentUid = authState.user?.uid ?? '';
    final notificationsAsync = ref.watch(notificationsStreamProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Activity',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () async {
                if (currentUid.isNotEmpty) {
                  await FirestoreMethods().markAllNotificationsAsRead(currentUid);
                }
              },
              child: const Text(
                'Mark all as read',
                style: TextStyle(
                  color: Color(0xFF0095F6),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.favorite_border,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No activity yet',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'When someone likes, comments, or follows you,\nit will show up here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _ActivityTile(
                notification: notification,
                currentUid: currentUid,
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Colors.white24,
            strokeWidth: 2,
          ),
        ),
        error: (error, _) => Center(
          child: Text(
            'Error loading activity: $error',
            style: const TextStyle(color: Colors.white54),
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends ConsumerWidget {
  final NotificationModel notification;
  final String currentUid;

  const _ActivityTile({
    required this.notification,
    required this.currentUid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authViewModelProvider).user;
    final isFollowing = currentUser?.following.contains(notification.senderId) ?? false;

    void handleNotificationTap() {
      // Mark notification as read
      if (currentUid.isNotEmpty && !notification.isRead) {
        FirestoreMethods().markNotificationAsRead(currentUid, notification.notificationId);
      }

      // Route
      if (notification.type == 'follow') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProfileScreen(uid: notification.senderId),
          ),
        );
      } else if ((notification.type == 'like' || notification.type == 'comment') &&
          notification.postId != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PostDetailScreen(postId: notification.postId!),
          ),
        );
      }
    }

    return InkWell(
      onTap: handleNotificationTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // User profile picture with unread dot indicator
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: CachedNetworkImageProvider(
                    (notification.senderProfileUrl.isNotEmpty)
                        ? notification.senderProfileUrl
                        : 'https://i.stack.imgur.com/l60Hf.png',
                  ),
                  backgroundColor: Colors.grey.shade900,
                ),
                if (!notification.isRead)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0095F6),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Notification text content
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 13, height: 1.3),
                  children: [
                    TextSpan(
                      text: notification.senderUsername,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: _getNotificationText(notification),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    TextSpan(
                      text: ' ${_formatDate(notification.timestamp)}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Trailing action: Post thumbnail OR Follow button
            if (notification.type == 'follow')
              SizedBox(
                height: 28,
                child: isFollowing
                    ? OutlinedButton(
                        onPressed: () async {
                          if (currentUid.isNotEmpty) {
                            await FirestoreMethods().followUser(currentUid, notification.senderId);
                            ref.read(authViewModelProvider.notifier).refreshUser();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: const Text(
                          'Following',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          if (currentUid.isNotEmpty) {
                            await FirestoreMethods().followUser(currentUid, notification.senderId);
                            ref.read(authViewModelProvider.notifier).refreshUser();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0095F6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        child: const Text(
                          'Follow Back',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              )
            else if ((notification.type == 'like' || notification.type == 'comment') &&
                notification.postUrl != null &&
                notification.postUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: notification.postUrl!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 40,
                    height: 40,
                    color: Colors.grey.shade900,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getNotificationText(NotificationModel notification) {
    switch (notification.type) {
      case 'like':
        return ' liked your post.';
      case 'comment':
        final commentSnippet = (notification.commentText != null && notification.commentText!.length > 30)
            ? '${notification.commentText!.substring(0, 30)}...'
            : notification.commentText;
        return ' commented: "${commentSnippet ?? ''}"';
      case 'follow':
        return ' started following you.';
      default:
        return ' interacted with your profile.';
    }
  }

  String _formatDate(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return DateFormat('MMM d').format(dateTime);
  }
}
