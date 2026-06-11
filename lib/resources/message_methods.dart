import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:lumi/models/chat.dart';
import 'package:lumi/models/message.dart';
import 'package:uuid/uuid.dart';

class MessageMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Generate deterministic chat ID
  String getChatId(String uid1, String uid2) {
    List<String> uids = [uid1, uid2];
    uids.sort();
    return uids.join('_');
  }

  // Get or Create Chat
  Future<String> getOrCreateChat(String currentUid, String targetUid) async {
    String chatId = getChatId(currentUid, targetUid);
    
    DocumentSnapshot doc = await _firestore.collection('chats').doc(chatId).get();
    
    if (!doc.exists) {
      Chat chat = Chat(
        chatId: chatId,
        participants: [currentUid, targetUid],
        lastMessage: '',
        lastMessageTime: DateTime.now(),
        lastMessageSenderId: '',
        unreadCount: {
          currentUid: 0,
          targetUid: 0,
        },
      );
      
      await _firestore.collection('chats').doc(chatId).set(chat.toJson());
    }
    
    return chatId;
  }

  // Send Message
  Future<void> sendMessage({
    required String currentUid,
    required String targetUid,
    required String text,
    String type = 'text',
    Map<String, dynamic>? postData,
  }) async {
    try {
      String chatId = getChatId(currentUid, targetUid);
      String messageId = const Uuid().v1();
      
      // Ensure chat exists
      await getOrCreateChat(currentUid, targetUid);
      
      Message message = Message(
        messageId: messageId,
        senderId: currentUid,
        text: text,
        type: type,
        postData: postData,
        datePublished: DateTime.now(),
        isRead: false,
      );

      // Add to messages subcollection
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .set(message.toJson());
          
      // Update chat last message
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': type == 'post' ? 'Sent a post' : text,
        'lastMessageTime': DateTime.now(),
        'lastMessageSenderId': currentUid,
        'unreadCount.$targetUid': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Mark chat as read
  Future<void> markChatAsRead(String chatId, String currentUid) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'unreadCount.$currentUid': 0,
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Stream Inbox
  Stream<List<Chat>> getInboxStream(String uid) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Chat.fromSnap(doc))
            .toList());
  }

  // Stream Messages
  Stream<List<Message>> getChatMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('datePublished', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromSnap(doc))
            .toList());
  }
}
