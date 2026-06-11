import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String notificationId;
  final String senderId;
  final String senderUsername;
  final String senderProfileUrl;
  final String type; // 'like', 'comment', 'follow'
  final String? postId;
  final String? postUrl;
  final String? commentText;
  final DateTime timestamp;
  final bool isRead;

  const NotificationModel({
    required this.notificationId,
    required this.senderId,
    required this.senderUsername,
    required this.senderProfileUrl,
    required this.type,
    this.postId,
    this.postUrl,
    this.commentText,
    required this.timestamp,
    required this.isRead,
  });

  Map<String, dynamic> toJson() => {
        "notificationId": notificationId,
        "senderId": senderId,
        "senderUsername": senderUsername,
        "senderProfileUrl": senderProfileUrl,
        "type": type,
        "postId": postId,
        "postUrl": postUrl,
        "commentText": commentText,
        "timestamp": timestamp,
        "isRead": isRead,
      };

  static NotificationModel fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return NotificationModel(
      notificationId: snapshot["notificationId"] ?? '',
      senderId: snapshot["senderId"] ?? '',
      senderUsername: snapshot["senderUsername"] ?? '',
      senderProfileUrl: snapshot["senderProfileUrl"] ?? '',
      type: snapshot["type"] ?? '',
      postId: snapshot["postId"],
      postUrl: snapshot["postUrl"],
      commentText: snapshot["commentText"],
      timestamp: (snapshot["timestamp"] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: snapshot["isRead"] ?? false,
    );
  }
}
