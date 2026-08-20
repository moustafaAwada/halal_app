import 'package:flutter_test/flutter_test.dart';
import 'package:Halal/app.dart';
import 'package:Halal/core/di/service_locator.dart';
import 'package:Halal/features/splash/presentation/pages/splash_page.dart';

void main() {
  testWidgets('Splash screen shows brand name', (WidgetTester tester) async {
    await initDependencies();
    await tester.pumpWidget(const HalalApp());
    await tester.pump();

    expect(find.text('حلال'), findsOneWidget);
    expect(find.text('طلبك... يوصلك'), findsOneWidget);

    await tester.pump(SplashPage.minSplashDuration);
    await tester.pumpAndSettle();
  });
}
