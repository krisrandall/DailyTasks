import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/task_service.dart';
import 'services/media_service.dart';
import 'services/platform_service.dart';
import 'services/widget_service.dart';
import 'platforms/mobile/mobile_layout.dart';
import 'platforms/tv/tv_layout.dart';
import 'platforms/widget/desktop_widget.dart';
import 'utils/constants.dart';
import 'config/app_config.dart';

class DailyTasksApp extends StatelessWidget {
  final PlatformType? forcePlatformType;

  const DailyTasksApp({
    Key? key, 
    this.forcePlatformType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final taskService = TaskService();
            // Initialize the task service asynchronously
            taskService.initialize();
            return taskService;
          },
        ),
        ChangeNotifierProvider(create: (_) => MediaService()),
      ],
      child: MaterialApp(
        title: AppStrings.appTitle,
        theme: _buildTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: ThemeMode.system,
        home: _buildHome(),
        debugShowCheckedModeBanner: !AppConfig.isDebugMode,
      ),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
      ),
      cardTheme: CardThemeData(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4.0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 12.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 12.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.dark,
      ),
      cardTheme: CardThemeData(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4.0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 12.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 12.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  Widget _buildHome() {
    return FutureBuilder<void>(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSplashScreen();
        }

        if (snapshot.hasError) {
          return _buildErrorScreen(snapshot.error.toString());
        }

        return _buildMainScreen();
      },
    );
  }

  Widget _buildSplashScreen() {
    return Scaffold(
      backgroundColor: AppConstants.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 80.0,
              color: Colors.white,
            ),
            const SizedBox(height: 24.0),
            Text(
              AppStrings.appTitle,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48.0),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.0,
              color: Colors.red,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Failed to initialize app',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              error,
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                // Restart app
                // This would typically restart the entire app
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainScreen() {
    return FutureBuilder<PlatformType>(
      future: _determinePlatformType(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final platformType = snapshot.data!;
        
        switch (platformType) {
          case PlatformType.tv:
            return const TVLayout();
          case PlatformType.widget:
            return const DesktopWidget();
          case PlatformType.mobile:
          case PlatformType.desktop:
          default:
            return const MobileLayout();
        }
      },
    );
  }

  Future<void> _initializeApp() async {
    // Validate configuration
    if (!AppConfig.isValidConfiguration()) {
      throw Exception('Invalid app configuration');
    }

    // Initialize widget service
    try {
      await WidgetService.initialize();
      WidgetService.registerCallback();
    } catch (e) {
      print('Widget service not available: $e');
    }

    // Request permissions if needed
    final hasPermission = await PlatformService.hasStoragePermission;
    if (!hasPermission) {
      final granted = await PlatformService.requestStoragePermission();
      if (!granted) {
        throw Exception('Storage permission is required');
      }
    }

    // Add any other initialization logic here
    await Future.delayed(const Duration(seconds: 1)); // Simulate loading
  }

  Future<PlatformType> _determinePlatformType() async {
    if (forcePlatformType != null) {
      return forcePlatformType!;
    }

    // Check if running as widget
    if (await PlatformService.isWidget) {
      return PlatformType.widget;
    }

    // Check if running on TV
    if (await PlatformService.isAndroidTV) {
      return PlatformType.tv;
    }

    // Default to current platform detection
    return PlatformService.currentPlatform;
  }
}