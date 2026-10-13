import 'dart:async';

import '../network/network_info.dart';
import 'sync_queue.dart';
import 'sync_status.dart';

class SyncService {
  SyncService({required SyncQueue queue, required NetworkInfo network})
      : _queue = queue,
        _network = network;

  final SyncQueue _queue;
  final NetworkInfo _network;
  final StreamController<SyncStatus> _status =
      StreamController<SyncStatus>.broadcast();

  SyncStatus _current = SyncStatus.idle;

  SyncStatus get status => _current;

  Stream<SyncStatus> get statusChanges => _status.stream;

  Future<void> drain() async {
    if (!await _network.hasConnection) {
      _emit(SyncStatus.offline);
      return;
    }
    _emit(SyncStatus.syncing);
    final batch = await _queue.nextBatch();
    var failed = false;
    for (final operation in batch) {
      try {
        await _queue.markDone(operation.operationId);
      } catch (error) {
        failed = true;
        await _queue.markFailed(operation.operationId, error.toString());
      }
    }
    _emit(failed ? SyncStatus.error : SyncStatus.idle);
  }

  void _emit(SyncStatus next) {
    _current = next;
    if (!_status.isClosed) {
      _status.add(next);
    }
  }

  Future<void> dispose() => _status.close();
}
