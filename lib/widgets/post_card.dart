import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_flutter_clone/resources/firestore_methods.dart';
import 'package:instagram_flutter_clone/resources/message_methods.dart';
import 'package:instagram_flutter_clone/screens/post/comment_screen.dart';
import 'package:instagram_flutter_clone/screens/profile/profile_screen.dart';
import 'package:instagram_flutter_clone/utils/utils.dart';
import 'package:instagram_flutter_clone/widgets/like_animation.dart';
import 'package:intl/intl.dart';

class PostCard extends HookConsumerWidget {
  final Map<String, dynamic> snap;

  const PostCard({super.key, required this.snap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLikeAnimating = useState(false);
    final commentLen = useState(0);
    final isBookmarked = useState(false);

    final currentUser = FirebaseAuth.instance.currentUser!;
    final List likes = snap['likes'] ?? [];
    final bool isLiked = likes.contains(currentUser.uid);

    // Fetch comment count on first build
    useEffect(() {
      Future<void> fetchCommentCount() async {
        try {
          final commentsSnap = await FirebaseFirestore.instance
              .collection('posts')
              .doc(snap['postId'])
              .collection('comments')
              .get();
          commentLen.value = commentsSnap.docs.length;
        } catch (_) {}
      }

      fetchCommentCount();
      return null;
    }, [snap['postId']]);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── POST HEADER ─────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProfileScreen(uid: snap['uid']),
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundImage: CachedNetworkImageProvider(
                      (snap['userProfileUrl'] != null &&
                              snap['userProfileUrl'].toString().isNotEmpty)
                          ? snap['userProfileUrl']
                          : 'https://i.stack.imgur.com/l60Hf.png',
                    ),
                    backgroundColor: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileScreen(uid: snap['uid']),
                          ),
                        ),
                        child: Text(
                          snap['username'] ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if ((snap['location'] ?? '').isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            snap['location'],
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                  onPressed: () => _showPostOptions(context, snap),
                ),
              ],
            ),
          ),

          // ─── POST IMAGE ──────────────────────────
          GestureDetector(
            onDoubleTap: () async {
              await FirestoreMethods().likePost(
                snap['postId'],
                currentUser.uid,
                likes,
              );
              isLikeAnimating.value = true;
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.width,
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: (snap['postUrl'] != null && snap['postUrl'].toString().isNotEmpty)
                        ? snap['postUrl']
                        : 'https://i.stack.imgur.com/l60Hf.png',
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade900,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white24,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade900,
                      child: const Icon(Icons.error, color: Colors.white24, size: 40),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating.value ? 1 : 0,
                  child: LikeAnimation(
                    isAnimating: isLikeAnimating.value,
                    duration: const Duration(milliseconds: 400),
                    onEnd: () {
                      isLikeAnimating.value = false;
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 100,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ─── ACTION BUTTONS ──────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                LikeAnimation(
                  isAnimating: isLiked,
                  smallLike: true,
                  child: IconButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.white,
                    ),
                    onPressed: () async {
                      await FirestoreMethods().likePost(
                        snap['postId'],
                        currentUser.uid,
                        likes,
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CommentScreen(postId: snap['postId']),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_outlined, color: Colors.white),
                  onPressed: () => _showSendDialog(context, snap, currentUser.uid),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isBookmarked.value ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked.value ? const Color(0xFF0095F6) : Colors.white,
                  ),
                  onPressed: () {
                    isBookmarked.value = !isBookmarked.value;
                  },
                ),
              ],
            ),
          ),

          // ─── LIKES, CAPTION, COMMENTS ────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${likes.length} ${likes.length == 1 ? 'like' : 'likes'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    children: [
                      TextSpan(
                        text: '${snap['username']} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: snap['description'] ?? ''),
                    ],
                  ),
                ),
                if (commentLen.value > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CommentScreen(postId: snap['postId']),
                        ),
                      ),
                      child: Text(
                        'View all ${commentLen.value} comments',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(snap['datePublished']),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    DateTime dateTime;
    if (date is Timestamp) {
      dateTime = date.toDate();
    } else if (date is DateTime) {
      dateTime = date;
    } else {
      return '';
    }

    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  void _showPostOptions(BuildContext context, Map<String, dynamic> snap) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final isOwner = snap['uid'] == currentUser.uid;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF262626),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (isOwner)
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Delete Post', style: TextStyle(color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    await FirestoreMethods().deletePost(snap['postId']);
                    if (context.mounted) {
                      showSnackBar(
                        content: 'Post deleted',
                        ctx: context,
                        isError: false,
                      );
                    }
                  },
                ),
              ListTile(
                leading: const Icon(Icons.link, color: Colors.white),
                title: const Text('Copy Link', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined, color: Colors.white),
                title: const Text('Share', style: TextStyle(color: Colors.white)),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSendDialog(BuildContext context, Map<String, dynamic> snap, String currentUid) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF262626),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Send to',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                      prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.5)),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: FirebaseFirestore.instance.collection('users').get(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }

                      final docs = (snapshot.data! as QuerySnapshot).docs;
                      final users = docs.where((doc) => doc.id != currentUid).toList();

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          final user = users[index].data() as Map<String, dynamic>;
                          final targetUid = users[index].id;

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                (user['photoUrl'] != null && user['photoUrl'].toString().isNotEmpty)
                                    ? user['photoUrl']
                                    : 'https://i.stack.imgur.com/l60Hf.png',
                              ),
                              backgroundColor: Colors.grey.shade900,
                            ),
                            title: Text(
                              user['username'],
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              user['username'],
                              style: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
                            ),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                await MessageMethods().sendMessage(
                                  currentUid: currentUid,
                                  targetUid: targetUid,
                                  text: '',
                                  type: 'post',
                                  postData: snap,
                                );
                                if (context.mounted) {
                                  Navigator.pop(context);
                                  showSnackBar(
                                    content: 'Sent',
                                    ctx: context,
                                    isError: false,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0095F6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Send'),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
