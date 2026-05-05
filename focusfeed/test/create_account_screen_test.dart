import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:focusfeed/features/auth/screens/create_account_screen.dart';

void main() {
  testWidgets('signup form asks for username without name fields', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: CreateAccountScreen()));

    expect(find.text('Create Account'), findsWidgets);
    expect(find.widgetWithText(TextFormField, 'Username'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Display Name'), findsNothing);
    expect(find.widgetWithText(TextFormField, 'Full Name'), findsNothing);
  });
}
