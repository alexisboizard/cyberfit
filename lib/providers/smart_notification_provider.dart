import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../services/smart_notification_service.dart';
import 'user_provider.dart';

final smartNotificationProvider = FutureProvider<void>((ref) async {
  final user = await ref.watch(userStreamProvider.future);
  if (user == null) return;

  final storage = ref.read(storageServiceProvider);
  await SmartNotificationService.checkAndNotify(
    user: user,
    storage: storage,
  );
});
