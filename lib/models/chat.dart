import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String chatId;
  final List<dynamic> participants;
  final String lastMessage;
  final DateTime lastMessageTime;
  final String lastMessageSenderId;
  final Map<String, dynamic> unreadCount;

  const Chat({
    required this.chatId,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.lastMessageSenderId,
    required this.unreadCount,
  });

  Map<String, dynamic> toJson() => {
        'chatId': chatId,
        'participants': participants,
        'lastMessage': lastMessage,
        'lastMessageTime': lastMessageTime,
        'lastMessageSenderId': lastMessageSenderId,
        'unreadCount': unreadCount,
      };

  factory Chat.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Chat(
      chatId: snapshot['chatId'] ?? '',
      participants: snapshot['participants'] ?? [],
      lastMessage: snapshot['lastMessage'] ?? '',
      lastMessageTime: (snapshot['lastMessageTime'] as Timestamp).toDate(),
      lastMessageSenderId: snapshot['lastMessageSenderId'] ?? '',
      unreadCount: snapshot['unreadCount'] ?? {},
    );
  }
}
