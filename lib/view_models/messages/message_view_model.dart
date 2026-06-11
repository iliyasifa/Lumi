import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_flutter_clone/models/chat.dart';
import 'package:instagram_flutter_clone/models/message.dart';
import 'package:instagram_flutter_clone/resources/message_methods.dart';
import 'package:instagram_flutter_clone/view_models/auth/auth_view_model.dart';

final messageMethodsProvider = Provider((ref) => MessageMethods());

final inboxStreamProvider = StreamProvider<List<Chat>>((ref) {
  final authState = ref.watch(authViewModelProvider);
  if (authState.user == null) return const Stream.empty();

  return ref.read(messageMethodsProvider).getInboxStream(authState.user!.uid);
});

final chatMessagesStreamProvider = StreamProvider.family<List<Message>, String>((ref, chatId) {
  return ref.read(messageMethodsProvider).getChatMessagesStream(chatId);
});
