import 'package:enviro_agri_manager/local/drift/app_database.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/providers/environmental_data_provider.dart';
import 'package:enviro_agri_manager/providers/product_review_provider.dart';
import 'package:enviro_agri_manager/providers/region_provider.dart';
import 'package:enviro_agri_manager/providers/settings_provider.dart';
import 'package:enviro_agri_manager/repositories/category_repository.dart';
import 'package:enviro_agri_manager/repositories/environmental_data_repository.dart';
import 'package:enviro_agri_manager/repositories/product_repository.dart';
import 'package:enviro_agri_manager/repositories/product_review_repository.dart';
import 'package:enviro_agri_manager/repositories/region_repository.dart';
import 'package:enviro_agri_manager/services/auth_service.dart';
import 'package:enviro_agri_manager/services/category_service.dart';
import 'package:enviro_agri_manager/services/connectivity_service.dart';
import 'package:enviro_agri_manager/services/environmental_data_service.dart';
import 'package:enviro_agri_manager/services/product_review_service.dart';
import 'package:enviro_agri_manager/services/product_service.dart';
import 'package:enviro_agri_manager/services/regions_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'providers/product_provider.dart';
import 'providers/category_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/auth_wrapper.dart';
import 'screens/user_management_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        //Theme
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        // Connectivity
        Provider(
          create: (_) => ConnectivityService(),
          dispose: (context, connectivityService) =>
              connectivityService.dispose(),
        ),
        ChangeNotifierProxyProvider<ConnectivityService, ConnectivityProvider>(
          create: (context) =>
              ConnectivityProvider(context.read<ConnectivityService>()),
          update: (_, service, provider) => provider!..updateService(service),
        ),

        // Auth
        Provider(create: (_) => AuthService()),
        ChangeNotifierProxyProvider2<
          ConnectivityProvider,
          AuthService,
          AuthProvider
        >(
          create: (context) => AuthProvider(
            context.read<ConnectivityProvider>(),
            context.read<AuthService>(),
          ),
          update: (_, connectivity, authService, provider) =>
              provider!..updateDependencies(connectivity, authService),
        ),
        // Database
        // Database
        Provider<AppDatabase?>(
          create: (_) => kIsWeb ? null : AppDatabase(),
          dispose: (_, db) => db?.close(),
        ),

        // Services
        Provider(create: (_) => CategoryService()),
        Provider(create: (_) => EnvironmentalDataService()),
        Provider(create: (_) => ProductService()),
        Provider(create: (_) => ProductReviewService()),
        Provider(create: (_) => RegionService()),

        // Category
        ProxyProvider2<AppDatabase?, CategoryService, CategoryRepository>(
          update: (_, db, service, _) => CategoryRepository(db, service),
        ),
        ChangeNotifierProxyProvider<CategoryRepository, CategoryProvider>(
          create: (context) =>
              CategoryProvider(context.read<CategoryRepository>()),
          update: (_, repo, provider) => provider!..update(repo),
        ),

        // Environmental Data
        ProxyProvider2<
          AppDatabase?,
          EnvironmentalDataService,
          EnvironmentalDataRepository
        >(
          update: (_, db, service, _) =>
              EnvironmentalDataRepository(db, service),
        ),
        ChangeNotifierProxyProvider<
          EnvironmentalDataRepository,
          EnvironmentalDataProvider
        >(
          create: (context) => EnvironmentalDataProvider(
            context.read<EnvironmentalDataRepository>(),
          ),
          update: (_, repo, provider) => provider!..update(repo),
        ),

        // Product
        ProxyProvider2<AppDatabase?, ProductService, ProductRepository>(
          update: (_, db, service, _) => ProductRepository(db, service),
        ),
        ChangeNotifierProxyProvider<ProductRepository, ProductProvider>(
          create: (context) =>
              ProductProvider(context.read<ProductRepository>()),
          update: (_, repo, provider) => provider!..update(repo),
        ),
        // Product Reviews
        ProxyProvider<ProductReviewService, ProductReviewRepository>(
          update: (_, service, _) => ProductReviewRepository(service),
        ),
        ChangeNotifierProxyProvider2<
          ProductReviewRepository,
          ProductRepository,
          ProductReviewProvider
        >(
          create: (context) => ProductReviewProvider(
            context.read<ProductReviewRepository>(),
            context.read<ProductRepository>(),
          ),
          update: (_, repo1, repo2, provider) =>
              provider!..update(repo1, repo2),
        ),

        // Region
        ProxyProvider2<AppDatabase?, RegionService, RegionRepository>(
          update: (_, db, service, _) => RegionRepository(db, service),
        ),
        ChangeNotifierProxyProvider<RegionRepository, RegionProvider>(
          create: (context) => RegionProvider(context.read<RegionRepository>()),
          update: (_, repo, provider) => provider!..update(repo),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<SettingsProvider>().themeMode;
    return MaterialApp(
      title: 'Hệ thống Quản lý Danh mục Nông nghiệp & Môi trường',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF5E81AC),
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF5E81AC),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5E81AC),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF5E81AC),
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),

        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF2E3440),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5E81AC),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        textTheme: TextTheme(
          bodyLarge: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.white,
            fontSize: 16,
          ),
          bodyMedium: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.white70,
            fontSize: 14,
          ),
          labelLarge: const TextStyle(fontFamily: 'Inter', color: Colors.white),
        ),

        cardColor: const Color(0xFF2A2A2A),
        dividerColor: Colors.white12,
        hintColor: Colors.white54,
        iconTheme: const IconThemeData(color: Colors.white70),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          hintStyle: const TextStyle(
            fontFamily: 'Inter',
            color: Colors.white54,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF5E81AC)),
          ),
        ),
      ),
      themeMode: isDark,
      home: const AuthWrapper(),
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegisterScreen.routeName: (context) => const RegisterScreen(),
        ForgotPasswordScreen.routeName: (context) =>
            const ForgotPasswordScreen(),
        UserManagementScreen.routeName: (context) =>
            const UserManagementScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
