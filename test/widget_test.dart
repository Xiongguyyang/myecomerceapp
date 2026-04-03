import 'package:flutter_test/flutter_test.dart';
import 'package:myecomerceapp/core/config/app_config.dart';
import 'package:myecomerceapp/core/localization/locale_cubit.dart';
import 'package:myecomerceapp/core/theme/theme_cubit.dart';
import 'package:myecomerceapp/main.dart';

void main() {
  testWidgets('MyApp builds with dev config', (WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(config: AppConfig.dev, localeCubit: LocaleCubit(), themeCubit: ThemeCubit()),
    );
    expect(find.byType(MyApp), findsOneWidget);
  });
}
