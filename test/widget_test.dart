// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:aroosi_flutter/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App renders splash or dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: App()));
    // The router redirects splash -> dashboard by default.
    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsWidgets);
  });
}
