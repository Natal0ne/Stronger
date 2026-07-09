import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

import 'package:stronger/core/navigation/main_navigation.dart';
import 'package:stronger/core/theme/app_colors.dart';
import 'package:stronger/core/database/database_helper.dart';
import 'package:stronger/core/database/database_provider.dart';
import 'package:stronger/core/database/preferences_provider.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  final dbInstance = await DatabaseHelper.instance.database;
  final prefsInstance = await SharedPreferences.getInstance(); 

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(dbInstance),
        sharedPreferencesProvider.overrideWithValue(prefsInstance), 
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Be Stronger!',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          surface: AppColors.backgroundSurface,
          surfaceContainer: AppColors.surfaceContainer,
          primary: AppColors.accent,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: AppColors.surfaceContainer,
          surfaceTintColor: Colors.transparent,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surfaceContainer,
          elevation: 0,
          centerTitle: true,
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: AppColors.surfaceContainer,
          indicatorColor: AppColors.accent,
        ),
        scaffoldBackgroundColor: const ColorScheme.dark().surface,
      ),
      home: const MainNavigation(),
    );
  }
}