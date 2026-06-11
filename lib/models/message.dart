import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String messageId;
  final String senderId;
  final String text;
  final String type; // 'text' or 'post'
  final Map<String, dynamic>? postData;
  final DateTime datePublished;
  final bool isRead;

  const Message({
    required this.messageId,
    required this.senderId,
    required this.text,
    required this.type,
    this.postData,
    required this.datePublished,
    required this.isRead,
  });

  Map<String, dynamic> toJson() => {
        'messageId': messageId,
        'senderId': senderId,
        'text': text,
        'type': type,
        'postData': postData,
        'datePublished': datePublished,
        'isRead': isRead,
      };

  factory Message.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Message(
      messageId: snapshot['messageId'] ?? '',
      senderId: snapshot['senderId'] ?? '',
      text: snapshot['text'] ?? '',
      type: snapshot['type'] ?? 'text',
      postData: snapshot['postData'],
      datePublished: (snapshot['datePublished'] as Timestamp).toDate(),
      isRead: snapshot['isRead'] ?? false,
    );
  }
}
