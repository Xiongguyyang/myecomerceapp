import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myecomerceapp/data/auth/reopositry/auth_firebase_service.dart';
import 'package:myecomerceapp/data/auth/reopositry/auth_repository_impl.dart';
import 'package:myecomerceapp/domain/auth/repository/atuh.dart';

// Product
import 'package:myecomerceapp/data/product/datasource/product_local_datasource.dart';
import 'package:myecomerceapp/data/product/repository/product_repository_impl.dart';
import 'package:myecomerceapp/domain/product/repository/product_repository.dart';
import 'package:myecomerceapp/domain/product/usecases/get_all_products.dart';
import 'package:myecomerceapp/domain/product/usecases/get_products_by_category.dart';
import 'package:myecomerceapp/domain/product/usecases/search_products.dart';

// Cart
import 'package:myecomerceapp/data/cart/datasource/cart_local_datasource.dart';
import 'package:myecomerceapp/data/cart/repository/cart_repository_impl.dart';
import 'package:myecomerceapp/domain/cart/repository/cart_repository.dart';
import 'package:myecomerceapp/domain/cart/usecases/add_to_cart.dart';
import 'package:myecomerceapp/domain/cart/usecases/clear_cart.dart';
import 'package:myecomerceapp/domain/cart/usecases/get_cart_items.dart';
import 'package:myecomerceapp/domain/cart/usecases/remove_from_cart.dart';
import 'package:myecomerceapp/domain/cart/usecases/update_cart_quantity.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);

  // Auth
  sl.registerSingleton<AuthFirebaseService>(AuthFirebaseServiceImpl());
  sl.registerSingleton<AuthRepository>(AuthRepositoryImpl());

  // Product datasource & repository
  sl.registerSingleton<ProductLocalDatasource>(ProductLocalDatasource());
  sl.registerSingleton<ProductRepository>(
    ProductRepositoryImpl(sl<ProductLocalDatasource>()),
  );

  // Product use cases
  sl.registerSingleton<GetAllProducts>(GetAllProducts(sl<ProductRepository>()));
  sl.registerSingleton<GetProductsByCategory>(GetProductsByCategory(sl<ProductRepository>()));
  sl.registerSingleton<SearchProducts>(SearchProducts(sl<ProductRepository>()));

  // Cart datasource & repository
  sl.registerSingleton<CartLocalDatasource>(CartLocalDatasource(sl<SharedPreferences>()));
  sl.registerSingleton<CartRepository>(
    CartRepositoryImpl(
      cartDatasource: sl<CartLocalDatasource>(),
      productDatasource: sl<ProductLocalDatasource>(),
    ),
  );

  // Cart use cases
  sl.registerSingleton<GetCartItems>(GetCartItems(sl<CartRepository>()));
  sl.registerSingleton<AddToCart>(AddToCart(sl<CartRepository>()));
  sl.registerSingleton<RemoveFromCart>(RemoveFromCart(sl<CartRepository>()));
  sl.registerSingleton<UpdateCartQuantity>(UpdateCartQuantity(sl<CartRepository>()));
  sl.registerSingleton<ClearCart>(ClearCart(sl<CartRepository>()));
}
