import 'package:flutter_test/flutter_test.dart';
import 'package:myecomerceapp/core/config/app_config.dart';
import 'package:myecomerceapp/main.dart';

void main() {
  testWidgets('MyApp builds with dev config', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(config: AppConfig.dev));
    expect(find.byType(MyApp), findsOneWidget);
  });
}
