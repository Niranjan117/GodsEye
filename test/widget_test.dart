import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('admin sign-in opens the desktop console', (tester) async {
    await tester.pumpWidget(const GodsEyeApp());

    expect(find.text("God's Eye"), findsOneWidget);
    expect(find.text('User name'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Find feeds'), findsOneWidget);
    expect(find.text('Camera feed'), findsOneWidget);
    expect(find.text('Detection log and results'), findsOneWidget);
    expect(find.text('Load Feed'), findsOneWidget);
    expect(find.text('Find feed'), findsOneWidget);
    expect(find.text('Options'), findsNothing);
    expect(find.text('Exit'), findsNothing);
    expect(find.text('×'), findsNothing);
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
    expect(find.text('Track feeds'), findsOneWidget);
    expect(find.text('Track log'), findsOneWidget);
    expect(find.text('Track feed'), findsOneWidget);

    await tester.tap(find.text('Settings').first);
    await tester.pumpAndSettle();
    expect(find.text('Preview quality'), findsOneWidget);
    await tester.tap(find.text('Return to console'));
    await tester.pumpAndSettle();
    expect(find.text('Find feeds'), findsOneWidget);

    await tester.tap(find.text('Hints').first);
    await tester.pumpAndSettle();
    expect(find.text('Getting started'), findsOneWidget);
  });

  testWidgets('local search ranks a person and opens the Track tab', (
    tester,
  ) async {
    await tester.pumpWidget(const GodsEyeApp());
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextBox), 'blue jeans, black backpack');
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(find.textContaining('% Match'), findsWidgets);
    await tester.tap(find.textContaining('% Match').first);
    await tester.pumpAndSettle();

    expect(find.text('Cross-Camera Sighting Timeline'), findsOneWidget);
  });
}
