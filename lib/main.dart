import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.initializeDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
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
      child: MaterialApp(
        title: 'Flex JK Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF004054),
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: BlocProvider(
          create: (_) => SplashCubit(),
          child: const SplashPages(),
        ),
      ),
    );
  }
}
