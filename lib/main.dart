import 'package:enviro_agri_manager/local/drift/app_database.dart';
import 'package:enviro_agri_manager/providers/connectivity_provider.dart';
import 'package:enviro_agri_manager/providers/environmental_data_provider.dart';
import 'package:enviro_agri_manager/providers/region_provider.dart';
import 'package:enviro_agri_manager/repositories/category_repository.dart';
import 'package:enviro_agri_manager/repositories/environmental_data_repository.dart';
import 'package:enviro_agri_manager/repositories/product_repository.dart';
import 'package:enviro_agri_manager/repositories/region_repository.dart';
import 'package:enviro_agri_manager/services/category_service.dart';
import 'package:enviro_agri_manager/services/environmental_data_service.dart';
import 'package:enviro_agri_manager/services/product_service.dart';
import 'package:enviro_agri_manager/services/regions_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final db = AppDatabase();
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: db),
        Provider(create: (_) => CategoryService()),
        Provider(create: (_) => EnvironmentalDataService()),
        Provider(create: (_) => ProductService()),
        Provider(create: (_) => RegionService()),

        // Category
        ProxyProvider2<AppDatabase, CategoryService, CategoryRepository>(
          update: (_, db, service, __) => CategoryRepository(db, service),
        ),

        ChangeNotifierProxyProvider<CategoryRepository, CategoryProvider>(
          create: (_) => CategoryProvider(null),
          update: (_, repo, provider) => provider!..update(repo),
        ),

        // Environmental Data
        ProxyProvider2<
          AppDatabase,
          EnvironmentalDataService,
          EnvironmentalDataRepository
        >(
          update: (_, db, service, __) =>
              EnvironmentalDataRepository(db, service),
        ),

        ChangeNotifierProxyProvider<
          EnvironmentalDataRepository,
          EnvironmentalDataProvider
        >(
          create: (_) => EnvironmentalDataProvider(null),
          update: (_, repo, provider) => provider!..update(repo),
        ),

        // Product
        ProxyProvider2<AppDatabase, ProductService, ProductRepository>(
          update: (_, db, service, __) => ProductRepository(db, service),
        ),
        ChangeNotifierProxyProvider<ProductRepository, ProductProvider>(
          create: (_) => ProductProvider(null),
          update: (_, repo, provider) => provider!..update(repo),
        ),

        // Region
        ProxyProvider2<AppDatabase, RegionService, RegionRepository>(
          update: (_, db, service, __) => RegionRepository(db, service),
        ),
        ChangeNotifierProxyProvider<RegionRepository, RegionProvider>(
          create: (_) => RegionProvider(null),
          update: (_, repo, provider) => provider!..update(repo),
        ),
        //---
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hệ thống Quản lý Danh mục Nông nghiệp & Môi trường',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF5E81AC),
        fontFamily: GoogleFonts.inter().fontFamily,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF5E81AC),
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: GoogleFonts.inter(
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
            textStyle: GoogleFonts.inter(fontWeight: FontWeight.w500),
          ),
        ),
      ),
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
