import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'services/purchase_service.dart';
import 'services/seed_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Seed Firestore with initial content if collections are empty
  // Non-blocking: don't prevent app startup if Firestore is unreachable
  try {
    await SeedService().seedIfEmpty();
  } catch (_) {
    // Seed will retry on next launch
  }

  // Local notifications
  await NotificationService.init();
  try {
    await NotificationService.requestPermissions();
  } catch (_) {}

  // Shared preferences
  final storageService = StorageService();
  await storageService.init();

  // RevenueCat
  try {
    await PurchaseService.init();
  } catch (_) {}

  // Schedule daily reminder if enabled
  if (storageService.notificationsEnabled) {
    try {
      await NotificationService.scheduleDailyReminder(
        hour: storageService.reminderHour,
        minute: storageService.reminderMinute,
      );
    } catch (_) {}
  }

  runApp(
    ProviderScope(
      overrides: [storageServiceProvider.overrideWithValue(storageService)],
      child: const CyberFitApp(),
    ),
  );
}

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('StorageService must be initialized in main()');
});
