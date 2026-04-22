import 'package:flutter_test/flutter_test.dart';
import 'package:paytonpieper/app.dart';
import 'package:paytonpieper/features/onboarding/presentation/screen/onboarding_screen1.dart';

void main() {
  testWidgets('Splash screen navigates to onboarding after loading', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const Paytonpieper());
    await tester.pump();

    expect(find.text('ON THE BITE'), findsOneWidget);
    expect(find.byType(OnboardingScreen1), findsNothing);

    await tester.pump(const Duration(milliseconds: 3100));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen1), findsOneWidget);
  });
}
