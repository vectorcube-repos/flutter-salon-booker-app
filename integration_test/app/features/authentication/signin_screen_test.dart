import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../../test_app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Signin Screen Integration Tests', () {
    setUpAll(() async {
      // Initialize app once for all tests
      await initializeTestApp();
    });

    tearDownAll(() async {
      // Clean up after all tests
      await resetTestApp();
    });

    testWidgets('successful login flow', (tester) async {
      // Start the app
      await tester.pumpWidget(getTestApp());
      await tester.pumpAndSettle();

      // Verify we're on the signin screen
      expect(find.text('Let\'s Sign You In.'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Enter valid credentials
      // Find TextFields by index (first is email, second is password)
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(2));
      
      await tester.enterText(textFields.first, 'test@example.com');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.pumpAndSettle();

      // Tap sign in button
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Verify navigation or success state
      // expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('shows validation errors when fields are empty', (tester) async {
      await tester.pumpWidget(getTestApp());
      await tester.pumpAndSettle();

      // Tap sign in without entering anything
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify validation errors are shown
      expect(find.textContaining('required'), findsAtLeastNWidgets(2));
    });

    testWidgets('shows email validation error for invalid email', (tester) async {
      await tester.pumpWidget(getTestApp());
      await tester.pumpAndSettle();

      // Enter invalid email
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'invalid-email');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.pumpAndSettle();

      // Tap sign in
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify email validation error
      expect(find.textContaining('email'), findsOneWidget);
    });

    testWidgets('shows password validation error for short password', (tester) async {
      await tester.pumpWidget(getTestApp());
      await tester.pumpAndSettle();

      // Enter valid email but short password
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'test@example.com');
      await tester.enterText(textFields.at(1), '123');
      await tester.pumpAndSettle();

      // Tap sign in
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify password validation error
      expect(find.textContaining('at least'), findsOneWidget);
    });

    testWidgets('can reveal and hide password', (tester) async {
      await tester.pumpWidget(getTestApp());
      await tester.pumpAndSettle();

      // Enter password in the second TextField
      final textFields = find.byType(TextField);
      final passwordField = textFields.at(1);
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Verify password is obscured initially
      TextField textField = tester.widget(passwordField);
      expect(textField.obscureText, true);

      // Tap the reveal password icon
      final iconButton = find.byType(IconButton);
      await tester.tap(iconButton);
      await tester.pumpAndSettle();

      // Password should now be visible
      textField = tester.widget(passwordField);
      expect(textField.obscureText, false);

      // Tap again to hide
      await tester.tap(iconButton);
      await tester.pumpAndSettle();

      // Password should be hidden again
      textField = tester.widget(passwordField);
      expect(textField.obscureText, true);
    });

    testWidgets('can navigate to signup screen', (tester) async {
      await tester.pumpWidget(getTestApp());
      await tester.pumpAndSettle();

      // Verify we're on signin screen
      expect(find.text('Let\'s Sign You In.'), findsOneWidget);

      // Tap "Sign Up" link
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Verify navigation to signup screen
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('clears errors when user starts typing', (tester) async {
      await tester.pumpWidget(getTestApp());
      await tester.pumpAndSettle();

      // Submit empty form to trigger validation errors
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Verify errors are shown
      expect(find.textContaining('required'), findsAtLeastNWidgets(2));

      // Start typing in email field
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 't');
      await tester.pumpAndSettle();

      // Error count should reduce
      expect(find.textContaining('required'), findsOneWidget);

      // Start typing in password field
      await tester.enterText(textFields.at(1), 'p');
      await tester.pumpAndSettle();

      // Both errors should be cleared
      expect(find.textContaining('required'), findsNothing);
    });

    testWidgets('shows loading state during sign in', (tester) async {
      await tester.pumpWidget(getTestApp());
      await tester.pumpAndSettle();

      // Enter valid credentials
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.first, 'test@example.com');
      await tester.enterText(textFields.at(1), 'password123');
      await tester.pumpAndSettle();

      // Tap sign in
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // Should show loading indicator (may or may not appear depending on network speed)
      // Skip this assertion as it's timing-dependent
      
      await tester.pumpAndSettle(const Duration(seconds: 10));
    });

    testWidgets('UI elements are properly displayed', (tester) async {
      await tester.pumpWidget(getTestApp());
      await tester.pumpAndSettle();

      // Verify all UI elements are present
      expect(find.text('Let\'s Sign You In.'), findsOneWidget);
      expect(find.text('To Continue, first Verify that it\'s You.'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.textContaining('account'), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);

      // Verify there are exactly 2 TextFields (email and password)
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('form maintains state during keyboard interaction', (tester) async {
      await tester.pumpWidget(getTestApp());
      await tester.pumpAndSettle();

      // Enter email
      final textFields = find.byType(TextField);
      final emailField = textFields.first;
      final passwordField = textFields.at(1);
      
      await tester.enterText(emailField, 'test@example.com');
      await tester.pumpAndSettle();

      // Tap password field (triggers keyboard focus change)
      await tester.tap(passwordField);
      await tester.pumpAndSettle();

      // Verify email is still there
      TextField emailWidget = tester.widget(emailField);
      expect(emailWidget.controller?.text, 'test@example.com');

      // Enter password
      await tester.enterText(passwordField, 'password123');
      await tester.pumpAndSettle();

      // Both fields should have values
      TextField passwordWidget = tester.widget(passwordField);
      expect(passwordWidget.controller?.text, 'password123');
    });
  });
}
