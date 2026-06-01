import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xolo/domain/entities/history_entry_entity.dart';
import 'package:xolo/presentation/providers/database_providers.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';

final recentHistoryStreamProvider =
    StreamProvider.autoDispose<List<HistoryEntryEntity>>((ref) {
      final repo = ref.watch(xoloRepositoryProvider);
      final workspaceId = ref.watch(activeWorkspaceIdProvider);

      return repo.watchRecentHistory(workspaceId);
    });
