# Supabase Products Setup Guide

## 1. Database Setup

### Step 1: Create the Products Table
1. Go to your Supabase Dashboard: https://app.supabase.com
2. Select your project: `gtchfrjbfndkkntqkweg`
3. Navigate to **SQL Editor** in the left sidebar
4. Copy and paste the entire content from `supabase_products_setup.sql`
5. Click **Run** to execute the SQL

This will:
- Create the `products` table with all necessary columns
- Add indexes for better performance
- Set up Row Level Security (RLS) policies
- Insert 15 sample products
- Create auto-update trigger for `updated_at` field

### Step 2: Verify the Setup
After running the SQL, you should see:
- A new `products` table in your database
- 15 sample products inserted
- Policies enabled for public read and authenticated write access

## 2. Flutter App Setup

### Step 1: Initialize Supabase in main.dart
Update your `main.dart` to initialize Supabase before running the app:

```dart
import 'package:flutter/material.dart';
import 'package:myecomerceapp/core/config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();
  
  runApp(const MyApp());
}
```

### Step 2: Register the Repository
Add the Supabase repository to your dependency injection (if using get_it):

```dart
import 'package:myecomerceapp/data/supabase/repositories/product_supabase_repository.dart';

// In your service locator setup
sl.registerLazySingleton(() => ProductSupabaseRepository());
```

### Step 3: Use the Products Page
Navigate to the products page in your app:

```dart
import 'package:myecomerceapp/presentation/supabase_products/pages/supabase_products_page.dart';
import 'package:myecomerceapp/presentation/supabase_products/cubit/supabase_products_cubit.dart';
import 'package:myecomerceapp/data/supabase/repositories/product_supabase_repository.dart';

// In your navigation or route
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => BlocProvider(
      create: (context) => SupabaseProductsCubit(ProductSupabaseRepository())
        ..loadProducts(),
      child: const SupabaseProductsPage(),
    ),
  ),
);
```

## 3. Files Created

### Configuration
- `lib/core/config/supabase_config.dart` - Supabase initialization and client

### Data Layer
- `lib/data/supabase/models/product_supabase_model.dart` - Product model for Supabase
- `lib/data/supabase/repositories/product_supabase_repository.dart` - Repository with CRUD operations

### Presentation Layer
- `lib/presentation/supabase_products/cubit/supabase_products_state.dart` - State management
- `lib/presentation/supabase_products/cubit/supabase_products_cubit.dart` - Business logic
- `lib/presentation/supabase_products/pages/supabase_products_page.dart` - UI with DataTable

### SQL
- `supabase_products_setup.sql` - Complete database setup script

## 4. Features Included

### Repository Methods
- `getAllProducts()` - Fetch all products
- `getProductsByCategory(category)` - Filter by category
- `searchProducts(query)` - Search by name
- `getProductById(id)` - Get single product
- `insertProduct(product)` - Add new product
- `updateProduct(id, data)` - Update existing product
- `deleteProduct(id)` - Remove product
- `subscribeToProducts()` - Real-time updates
- `getFilteredProducts()` - Advanced filtering

### UI Features
- DataTable with all product information
- Product images
- Price and discount display
- Rating and review count
- Stock status
- Tags display
- Pull-to-refresh
- Error handling
- Loading states

## 5. Environment Variables

Your `.env.local` file is already configured with:
```
SUPABASE_URL=https://gtchfrjbfndkkntqkweg.supabase.co
PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

## 6. Next Steps

1. Run `flutter pub get` to install new dependencies
2. Execute the SQL script in Supabase
3. Update your main.dart to initialize Supabase
4. Navigate to the SupabaseProductsPage to see your products

## 7. Testing

To test the setup:
1. Open the app and navigate to the products page
2. You should see a table with 15 sample products
3. Pull down to refresh the data
4. Check that images, prices, and other data display correctly

## 8. Customization

You can customize the sample data by:
- Modifying the INSERT statements in the SQL file
- Adding more products
- Changing categories, prices, or other fields
- Using your own image URLs
