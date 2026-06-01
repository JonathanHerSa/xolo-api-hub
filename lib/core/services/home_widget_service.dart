import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';

import 'package:xolo/core/services/app_logger.dart';

final homeWidgetServiceProvider = Provider<HomeWidgetService>(
  (ref) => HomeWidgetService(),
);

class HomeWidgetService {
  static const String appGroupId = 'group.xolo_api_client';
  static const String androidWidgetName = 'HomeWidgetProvider';

  Future<void> updateLastRequest(String method, String url) async {
    try {
      await HomeWidget.saveWidgetData<String>('last_request_method', method);
      await HomeWidget.saveWidgetData<String>('last_request_url', url);
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
      );
    } catch (e) {
      AppLogger.warn('Error updating widget: $e');
    }
  }

  Future<void> updateLastRunCollection(int collectionId, String name) async {
    try {
      await HomeWidget.saveWidgetData<int>('last_run_collection_id', collectionId);
      await HomeWidget.saveWidgetData<String>('last_run_collection_name', name);
      await HomeWidget.updateWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
      );
    } catch (e) {
      AppLogger.warn('Error updating run widget: $e');
    }
  }
}
