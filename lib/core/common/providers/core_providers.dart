import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../database/app_database.dart';
import '../../network/network_info.dart';
import '../../services/clock.dart';
import '../../services/storage_service.dart';
import '../../services/supabase_bootstrap.dart';
import '../../services/uuid_gen.dart';
import '../../sync/sync_queue.dart';
import '../../sync/sync_service.dart';
import '../../sync/sync_status.dart';

final storageProvider = Provider<StorageService>((ref) => StorageService());

final supabaseEnabledProvider = Provider<bool>(
  (ref) => SupabaseBootstrap.isReady,
);

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  if (!SupabaseBootstrap.isReady) {
    throw StateError(
      'Supabase is not configured. Provide SUPABASE_URL and SUPABASE_ANON_KEY.',
    );
  }
  return Supabase.instance.client;
});

final uuidProvider = Provider<UuidGen>((ref) => const UuidGen());

final clockProvider = Provider<Now>((ref) => systemNow);

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final networkInfoProvider = Provider<NetworkInfo>(
  (ref) => NetworkInfo(Connectivity()),
);

final syncQueueProvider = Provider<SyncQueue>((ref) {
  return SyncQueue(
    ref.watch(appDatabaseProvider),
    uuid: ref.watch(uuidProvider),
    now: ref.watch(clockProvider),
  );
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    queue: ref.watch(syncQueueProvider),
    network: ref.watch(networkInfoProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

final syncStatusProvider = StreamProvider<SyncStatus>(
  (ref) => ref.watch(syncServiceProvider).statusChanges,
);
