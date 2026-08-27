// Basic smoke test: the app boots to the splash screen without throwing.

import 'package:flutter_test/flutter_test.dart';
import 'package:mining/core/constant/app_string.dart';

import 'package:mining/main.dart';

void main() {
  testWidgets('App boots to splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MiningApp());
    await tester.pump();

    expect(find.text(AppString.appName), findsOneWidget);
  });
}
