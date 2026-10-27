import 'package:arkie_mobile/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders Arkie branding', (tester) async {
    await tester.pumpWidget(const MobileApp(home: Text('Arkie')));

    expect(find.text('Arkie'), findsOneWidget);
  });
}
