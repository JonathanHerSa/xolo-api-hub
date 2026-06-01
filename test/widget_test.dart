import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Material smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('xolo-smoke'))),
    );

    expect(find.text('xolo-smoke'), findsOneWidget);
  });
}
