import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/sync/sync_service.dart';

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService();
});
