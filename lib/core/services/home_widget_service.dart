import 'package:home_widget/home_widget.dart';

class HomeWidgetService {
  static const String appGroupId =
      'group.xolo_api_client'; // Relevant for iOS, optional for Android
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
      print('Error updating widget: $e');
    }
  }
}
