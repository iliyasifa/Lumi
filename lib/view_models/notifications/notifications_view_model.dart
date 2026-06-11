import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lumi/models/notification.dart';
import 'package:lumi/resources/firestore_methods.dart';
import 'package:lumi/view_models/auth/auth_view_model.dart';

final firestoreMethodsProvider = Provider((ref) => FirestoreMethods());

final notificationsStreamProvider = StreamProvider<List<NotificationModel>>((ref) {
  final authState = ref.watch(authViewModelProvider);
  if (authState.user == null) return const Stream.empty();

  final firestoreMethods = ref.read(firestoreMethodsProvider);
  return firestoreMethods.getActivityStream(authState.user!.uid).map((snapshot) {
    return snapshot.docs.map((doc) => NotificationModel.fromSnap(doc)).toList();
  });
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsAsync = ref.watch(notificationsStreamProvider);
  return notificationsAsync.maybeWhen(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    orElse: () => 0,
  );
});
