import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:myecomerceapp/core/config/app_config.dart';
import 'package:myecomerceapp/core/localization/locale_cubit.dart';
import 'package:myecomerceapp/core/theme/app_theme.dart';
import 'package:myecomerceapp/core/theme/theme_cubit.dart';
import 'package:myecomerceapp/firebase_options.dart';
import 'package:myecomerceapp/presentation/service_locator.dart' as di;
import 'package:myecomerceapp/presentation/service_locator.dart';
import 'package:myecomerceapp/presentation/splash/bloc/splas_cubit.dart';
import 'package:myecomerceapp/presentation/splash/pages/splash.dart';
import 'package:myecomerceapp/presentation/home/cubit/product_cubit.dart';
import 'package:myecomerceapp/presentation/cart/cubit/cart_cubit.dart';
import 'package:myecomerceapp/domain/product/usecases/get_all_products.dart';
import 'package:myecomerceapp/domain/product/usecases/get_products_by_category.dart';
import 'package:myecomerceapp/domain/product/repository/product_repository.dart';
import 'package:myecomerceapp/domain/cart/usecases/add_to_cart.dart';
import 'package:myecomerceapp/domain/cart/usecases/clear_cart.dart';
import 'package:myecomerceapp/domain/cart/usecases/get_cart_items.dart';
import 'package:myecomerceapp/domain/cart/usecases/remove_from_cart.dart';
import 'package:myecomerceapp/domain/cart/usecases/update_cart_quantity.dart';

Future<void> mainWithConfig(AppConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.initializeDependencies();

  // Load saved language and theme before the first frame.
  final localeCubit = LocaleCubit();
  await localeCubit.init();
  final themeCubit = ThemeCubit();
  await themeCubit.init();

  runApp(MyApp(config: config, localeCubit: localeCubit, themeCubit: themeCubit));
}

class MyApp extends StatelessWidget {
  final AppConfig config;
  final LocaleCubit localeCubit;
  final ThemeCubit themeCubit;
  const MyApp({super.key, required this.config, required this.localeCubit, required this.themeCubit});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: localeCubit),
        BlocProvider.value(value: themeCubit),
        BlocProvider(
          create: (_) => ProductCubit(
            getAllProducts: sl<GetAllProducts>(),
            getProductsByCategory: sl<GetProductsByCategory>(),
            productRepository: sl<ProductRepository>(),
          ),
        ),
        BlocProvider(
          create: (_) => CartCubit(
            getCartItems: sl<GetCartItems>(),
            addToCart: sl<AddToCart>(),
            removeFromCart: sl<RemoveFromCart>(),
            updateCartQuantity: sl<UpdateCartQuantity>(),
            clearCart: sl<ClearCart>(),
          ),
        ),
      ],
      // BlocBuilder rebuilds MaterialApp when locale or theme changes.
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) => BlocBuilder<LocaleCubit, Locale>(
          builder: (context, locale) {
            return MaterialApp(
              title: 'Flexy',
              debugShowCheckedModeBanner: config.showDebugBanner,
              locale: locale,
              themeMode: themeMode,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              supportedLocales: const [Locale('en'), Locale('lo')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (deviceLocale, supportedLocales) {
                const flutterBuiltIn = ['en', 'ar', 'fr', 'de', 'es', 'ja', 'ko',
                  'pt', 'ru', 'zh', 'it', 'nl', 'pl', 'sv', 'th', 'tr', 'uk'];
                if (flutterBuiltIn.contains(locale.languageCode)) return locale;
                return const Locale('en');
              },
              home: BlocProvider(
                create: (_) => SplashCubit(),
                child: const SplashPages(),
              ),
            );
          },
        ),
      ),
    );
  }
}
