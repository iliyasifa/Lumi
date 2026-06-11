import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lumi/models/notification.dart';
import 'package:lumi/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── POSTS ───────────────────────────────────────────────

  /// Upload a new post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String userProfileUrl, {
    String location = '',
  }) async {
    String res = 'Some error occurred';
    try {
      String postUrl = await StorageMethods().uploadImageToStorage(
        childName: 'posts',
        file: file,
        isPost: true,
      );

      String postId = const Uuid().v1();

      Map<String, dynamic> postData = {
        'postId': postId,
        'uid': uid,
        'username': username,
        'userProfileUrl': userProfileUrl,
        'description': description,
        'postUrl': postUrl,
        'datePublished': DateTime.now(),
        'likes': [],
        'location': location,
      };

      await _firestore.collection('posts').doc(postId).set(postData);
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  /// Like or unlike a post
  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });

        // Remove like notification
        DocumentSnapshot postSnap = await _firestore.collection('posts').doc(postId).get();
        if (postSnap.exists) {
          String postOwnerUid = (postSnap.data() as Map<String, dynamic>)['uid'];
          await deleteNotification(
            receiverId: postOwnerUid,
            senderId: uid,
            type: 'like',
            postId: postId,
          );
        }
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });

        // Add like notification
        DocumentSnapshot postSnap = await _firestore.collection('posts').doc(postId).get();
        if (postSnap.exists) {
          final postData = postSnap.data() as Map<String, dynamic>;
          String postOwnerUid = postData['uid'];
          String postUrl = postData['postUrl'] ?? '';
          await addNotification(
            receiverId: postOwnerUid,
            senderId: uid,
            type: 'like',
            postId: postId,
            postUrl: postUrl,
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a post
  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // ─── COMMENTS ────────────────────────────────────────────

  /// Add a comment to a post
  Future<String> postComment(
    String postId,
    String text,
    String uid,
    String username,
    String userProfileUrl,
  ) async {
    String res = 'Some error occurred';
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();

        await _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).set({
          'commentId': commentId,
          'uid': uid,
          'username': username,
          'userProfileUrl': userProfileUrl,
          'text': text,
          'datePublished': DateTime.now(),
          'likes': [],
        });

        // Add comment notification
        DocumentSnapshot postSnap = await _firestore.collection('posts').doc(postId).get();
        if (postSnap.exists) {
          final postData = postSnap.data() as Map<String, dynamic>;
          String postOwnerUid = postData['uid'];
          String postUrl = postData['postUrl'] ?? '';
          await addNotification(
            receiverId: postOwnerUid,
            senderId: uid,
            type: 'comment',
            postId: postId,
            postUrl: postUrl,
            commentText: text,
          );
        }

        res = 'success';
      } else {
        res = 'Please enter a comment';
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  /// Like or unlike a comment
  Future<void> likeComment(
    String postId,
    String commentId,
    String uid,
    List likes,
  ) async {
    try {
      if (likes.contains(uid)) {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      rethrow;
    }
  }

  // ─── FOLLOW / UNFOLLOW ──────────────────────────────────

  /// Follow or unfollow a user
  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as Map<String, dynamic>)['following'];

      if (following.contains(followId)) {
        // Unfollow
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid]),
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId]),
        });

        // Remove follow notification
        await deleteNotification(
          receiverId: followId,
          senderId: uid,
          type: 'follow',
        );
      } else {
        // Follow
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid]),
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId]),
        });

        // Add follow notification
        await addNotification(
          receiverId: followId,
          senderId: uid,
          type: 'follow',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // ─── STORIES ─────────────────────────────────────────────

  /// Upload a story
  Future<String> uploadStory(
    Uint8List file,
    String uid,
    String username,
    String userProfileUrl,
  ) async {
    String res = 'Some error occurred';
    try {
      String mediaUrl = await StorageMethods().uploadImageToStorage(
        childName: 'stories',
        file: file,
        isPost: true,
      );

      String storyId = const Uuid().v1();

      await _firestore.collection('stories').doc(storyId).set({
        'storyId': storyId,
        'uid': uid,
        'username': username,
        'userProfileUrl': userProfileUrl,
        'mediaUrl': mediaUrl,
        'datePublished': DateTime.now(),
        'viewers': [],
      });

      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  /// Mark a story as viewed
  Future<void> viewStory(String storyId, String uid) async {
    try {
      await _firestore.collection('stories').doc(storyId).update({
        'viewers': FieldValue.arrayUnion([uid]),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Delete expired stories (older than 24 hours)
  Future<void> deleteExpiredStories() async {
    try {
      final cutoff = DateTime.now().subtract(const Duration(hours: 24));
      final snap =
          await _firestore.collection('stories').where('datePublished', isLessThan: cutoff).get();

      for (var doc in snap.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      rethrow;
    }
  }

  // ─── USER PROFILE ────────────────────────────────────────

  /// Update user profile
  Future<String> updateProfile({
    required String uid,
    String? username,
    String? bio,
    Uint8List? profileImage,
  }) async {
    String res = 'Some error occurred';
    try {
      Map<String, dynamic> updateData = {};

      if (username != null && username.isNotEmpty) {
        updateData['username'] = username;
      }
      if (bio != null) {
        updateData['bio'] = bio;
      }
      if (profileImage != null) {
        String photoUrl = await StorageMethods().uploadImageToStorage(
          childName: 'profilePics',
          file: profileImage,
          isPost: false,
        );
        updateData['photoUrl'] = photoUrl;
      }

      if (updateData.isNotEmpty) {
        await _firestore.collection('users').doc(uid).update(updateData);

        // Also update username/photo in existing posts if changed
        if (updateData.containsKey('username') || updateData.containsKey('photoUrl')) {
          final postSnap = await _firestore.collection('posts').where('uid', isEqualTo: uid).get();

          for (var doc in postSnap.docs) {
            Map<String, dynamic> postUpdate = {};
            if (updateData.containsKey('username')) {
              postUpdate['username'] = updateData['username'];
            }
            if (updateData.containsKey('photoUrl')) {
              postUpdate['userProfileUrl'] = updateData['photoUrl'];
            }
            await doc.reference.update(postUpdate);
          }
        }
      }

      res = 'success';
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // ─── ACTIVITY / NOTIFICATIONS ───────────────────────────

  /// Get activity stream (notifications list)
  Stream<QuerySnapshot> getActivityStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  /// Add a notification
  Future<void> addNotification({
    required String receiverId,
    required String senderId,
    required String type,
    String? postId,
    String? postUrl,
    String? commentText,
  }) async {
    try {
      // Don't notify if action is on own content
      if (receiverId == senderId) return;

      // Get sender user info
      DocumentSnapshot senderSnap =
          await _firestore.collection('users').doc(senderId).get();
      if (!senderSnap.exists) return;
      final senderData = senderSnap.data() as Map<String, dynamic>;

      String notificationId = const Uuid().v1();
      NotificationModel notification = NotificationModel(
        notificationId: notificationId,
        senderId: senderId,
        senderUsername: senderData['username'] ?? '',
        senderProfileUrl: senderData['photoUrl'] ?? '',
        type: type,
        postId: postId,
        postUrl: postUrl,
        commentText: commentText,
        timestamp: DateTime.now(),
        isRead: false,
      );

      await _firestore
          .collection('users')
          .doc(receiverId)
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toJson());
    } catch (e) {
      debugPrint('Error adding notification: $e');
    }
  }

  /// Remove a notification (like unlike, unfollow)
  Future<void> deleteNotification({
    required String receiverId,
    required String senderId,
    required String type,
    String? postId,
  }) async {
    try {
      QuerySnapshot query;
      if (postId != null) {
        query = await _firestore
            .collection('users')
            .doc(receiverId)
            .collection('notifications')
            .where('senderId', isEqualTo: senderId)
            .where('type', isEqualTo: type)
            .where('postId', isEqualTo: postId)
            .get();
      } else {
        query = await _firestore
            .collection('users')
            .doc(receiverId)
            .collection('notifications')
            .where('senderId', isEqualTo: senderId)
            .where('type', isEqualTo: type)
            .get();
      }

      for (var doc in query.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  /// Mark notification as read
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in query.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }
}
