import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('admin sign-in opens the desktop console', (tester) async {
    await tester.pumpWidget(const GodsEyeApp());

    expect(find.text("God's Eye - Admin Login"), findsOneWidget);
    expect(find.text('User name:'), findsOneWidget);
    expect(find.text('Password:'), findsOneWidget);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text("God's Eye - Surveillance Console"), findsOneWidget);
    expect(find.text('Camera feed'), findsOneWidget);
    expect(find.text('Search results'), findsOneWidget);
    expect(find.text('Load Feed'), findsOneWidget);
    expect(find.text('Find feed...'), findsOneWidget);
    expect(find.text('Options'), findsOneWidget);
    expect(find.text('Exit'), findsOneWidget);
  });

  testWidgets('console exposes separate Find, Track, Settings, and Hints', (
    tester,
  ) async {
    await tester.pumpWidget(const GodsEyeApp());
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    for (final section in ['Find', 'Track', 'Settings', 'Hints']) {
      expect(find.text(section), findsWidgets);
    }

    await tester.tap(find.text('Track').first);
    await tester.pumpAndSettle();
    expect(find.text('Track actions'), findsOneWidget);
    expect(find.text('Track log'), findsOneWidget);
    expect(find.text('Track feed...'), findsOneWidget);

    await tester.tap(find.text('Settings').first);
    await tester.pumpAndSettle();
    expect(find.text('Display and feed preferences'), findsOneWidget);

    await tester.tap(find.text('Hints').first);
    await tester.pumpAndSettle();
    expect(find.text('Helpful usage notes will appear here.'), findsOneWidget);
  });
}
