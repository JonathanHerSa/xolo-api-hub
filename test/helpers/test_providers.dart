import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:xolo/core/network/http_client_provider.dart';
import 'package:xolo/core/utils/boolean_notifier.dart';
import 'package:xolo/data/local/database.dart';
import 'package:xolo/data/repositories/drift_xolo_repository.dart';
import 'package:xolo/domain/repositories/xolo_repository.dart';
import 'package:xolo/presentation/providers/database_providers.dart';
import 'package:xolo/presentation/providers/incognito_provider.dart';
import 'package:xolo/presentation/providers/workspace_provider.dart';

class TestHarness {
  TestHarness({
    required this.db,
    required this.repo,
    required this.container,
    required this.dio,
    required this.adapter,
  });

  final AppDatabase db;
  final DriftXoloRepository repo;
  final ProviderContainer container;
  final Dio dio;
  final DioAdapter adapter;

  static TestHarness create({
    List<Override> overrides = const [],
    HttpRequestMatcher? matcher,
  }) {
    final db = AppDatabase.memory();
    final repo = DriftXoloRepository(db);
    final dio = Dio();
    final adapter = DioAdapter(
      dio: dio,
      matcher: matcher ?? const FullHttpRequestMatcher(),
    );

    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        xoloRepositoryProvider.overrideWithValue(repo),
        dioProvider.overrideWithValue(dio),
        ...overrides,
      ],
    );

    return TestHarness(
      db: db,
      repo: repo,
      container: container,
      dio: dio,
      adapter: adapter,
    );
  }

  void dispose() {
    container.dispose();
    db.close();
  }
}

ProviderContainer providerContainerWithRepo(XoloRepository repo) {
  return ProviderContainer(
    overrides: [xoloRepositoryProvider.overrideWithValue(repo)],
  );
}

ProviderContainer fullProviderContainer(AppDatabase db) {
  final repo = DriftXoloRepository(db);
  final dio = Dio();
  return ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      xoloRepositoryProvider.overrideWithValue(repo),
      dioProvider.overrideWithValue(dio),
      isIncognitoProvider.overrideWith(() => _TestBooleanNotifier(false)),
      activeWorkspaceIdProvider.overrideWith(_TestWorkspaceNotifier.new),
    ],
  );
}

class _TestBooleanNotifier extends BooleanNotifier {
  _TestBooleanNotifier(this.initial);
  final bool initial;

  @override
  bool build() => initial;
}

class _TestWorkspaceNotifier extends WorkspaceNotifier {
  @override
  int? build() => null;

  @override
  Future<void> setWorkspace(int? id) async {
    state = id;
  }
}
