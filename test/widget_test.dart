import 'package:flutter_test/flutter_test.dart';
import 'package:halal_app/app.dart';
import 'package:halal_app/core/di/service_locator.dart';
import 'package:halal_app/features/splash/presentation/pages/splash_page.dart';

void main() {
  testWidgets('Splash screen shows brand name', (WidgetTester tester) async {
    await initDependencies();
    await tester.pumpWidget(const HalalApp());
    await tester.pump();

    expect(find.text('حلال'), findsOneWidget);
    expect(find.text('طلبك... يوصلك'), findsOneWidget);

    await tester.pump(SplashPage.navigationDelay);
    await tester.pumpAndSettle();
  });
}
