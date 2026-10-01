import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cricket_score/main.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('CricPulseApp Admin workflow: login with akash@gmail.com -> dashboard -> scoring console', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const CricPulseApp());
    await tester.pumpAndSettle();

    // 1. Verify single unified Login Screen renders
    expect(find.text('CRICPULSE LIVE'), findsOneWidget);
    expect(find.text('SIGN IN'), findsOneWidget);
    // Role switcher tabs are no longer shown
    expect(find.text('ADMIN SCORER'), findsNothing);
    expect(find.text('AUDIENCE FAN'), findsNothing);

    // 2. Enter admin credentials (fields are empty by default)
    await tester.enterText(find.byType(TextFormField).at(0), 'akash@gmail.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'akash1234');

    // 3. Tap unified "SIGN IN" button
    await tester.tap(find.text('SIGN IN'));
    await tester.pumpAndSettle();

    // 4. Verify Admin Dashboard opens with management controls because email is admin
    expect(find.text('ADMIN DASHBOARD'), findsOneWidget);
    expect(find.text('Start New Live Match'), findsOneWidget);
    expect(find.text('YOUR MANAGED MATCHES'), findsOneWidget);

    // 5. Open Live Scoring console
    expect(find.text('OPEN SCORING'), findsWidgets);
    await tester.tap(find.text('OPEN SCORING').first);
    await tester.pumpAndSettle();

    // 6. Verify Scoring Console with interactive buttons (0, 1, 2, 3, 4, 6, W, WD, NB, etc.)
    expect(find.text('0'), findsWidgets);
    expect(find.text('1'), findsWidgets);
    expect(find.text('4'), findsWidgets);
    expect(find.text('6'), findsWidgets);
    expect(find.text('W'), findsWidgets);
    expect(find.text('WD'), findsWidgets);
    expect(find.text('NB'), findsWidgets);

    // 7. Tap scoring action: +4 runs
    await tester.tap(find.text('4').first);
    await tester.pumpAndSettle();

    // 8. Verify undo button is available
    expect(find.byIcon(Icons.undo), findsOneWidget);
    await tester.tap(find.byIcon(Icons.undo));
    await tester.pumpAndSettle();
  });

  testWidgets('CricPulseApp Audience workflow: login with regular user -> audience hub -> view live match', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const CricPulseApp());
    await tester.pumpAndSettle();

    // 1. Enter audience credentials in the same unified login
    await tester.enterText(find.byType(TextFormField).at(0), 'user@cricket.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'user123');

    // 2. Sign In via unified "SIGN IN" button
    expect(find.text('SIGN IN'), findsOneWidget);
    await tester.tap(find.text('SIGN IN'));
    await tester.pumpAndSettle();

    // 3. Verify Audience Home Screen opens with live match updates
    expect(find.text('CRICPULSE LIVE'), findsOneWidget);
    expect(find.textContaining('Audience Hub'), findsOneWidget);
    expect(find.textContaining('LIVE ('), findsOneWidget);
    expect(find.textContaining('UPCOMING ('), findsOneWidget);
    expect(find.textContaining('COMPLETED ('), findsOneWidget);
    // Ensure admin controls are NOT visible to audience
    expect(find.text('ADMIN DASHBOARD'), findsNothing);
  });

  testWidgets('CricPulseApp Registration workflow: audience fan registration', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const CricPulseApp());
    await tester.pumpAndSettle();

    // 1. Verify default login screen has empty fields and no prefilled text
    final emailField = tester.widget<TextFormField>(find.byType(TextFormField).at(0));
    expect(emailField.controller?.text, isEmpty);
    final passwordField = tester.widget<TextFormField>(find.byType(TextFormField).at(1));
    expect(passwordField.controller?.text, isEmpty);

    // 2. Switch to Registration
    await tester.tap(find.text('Need an account? Register as Fan'));
    await tester.pumpAndSettle();

    // 3. Verify Admin option is NOT present in registration
    expect(find.text('ADMIN SCORER'), findsNothing);
    expect(find.text('CREATE ACCOUNT'), findsOneWidget);
  });
}
