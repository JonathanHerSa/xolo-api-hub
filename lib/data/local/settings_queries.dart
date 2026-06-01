part of 'database.dart';

extension SettingsQueries on AppDatabase {
  // ---------------------------------------------------------------------------
  // APP SETTINGS (KV STORE)
  // ---------------------------------------------------------------------------

  Future<void> setSetting(String key, String value) {
    return into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }

  Future<String?> getSetting(String key) async {
    final result = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return result?.value;
  }

  Stream<String?> watchSetting(String key) {
    return (select(appSettings)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((r) => r?.value);
  }
}
