import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'app.dart';
import 'services/platform_service.dart';
import 'config/app_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configure system UI
  await _configureSystemUI();
  
  // Initialize error handling
  _initializeErrorHandling();
  
  // Run the app
  runApp(const DailyTasksApp());
}

Future<void> _configureSystemUI() async {
  // Set preferred orientations based on platform
  final platformType = PlatformService.currentPlatform;
  
  switch (platformType) {
    case PlatformType.mobile:
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      break;
    case PlatformType.tv:
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      break;
    case PlatformType.widget:
    case PlatformType.desktop:
      // No orientation restrictions
      break;
  }
  
  // Set system UI mode
  PlatformService.setSystemUIMode(platformType);
  
  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
}

void _initializeErrorHandling() {
  if (AppConfig.isDebugMode) {
    // In debug mode, let Flutter handle errors normally
    return;
  }
  
  // Handle Flutter errors
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    _logError('Flutter Error', details.exception, details.stack);
  };
  
  // Handle Dart errors
  PlatformDispatcher.instance.onError = (error, stack) {
    _logError('Dart Error', error, stack);
    return true;
  };
}

void _logError(String type, Object error, StackTrace? stackTrace) {
  if (AppConfig.enableLogging) {
    print('$type: $error');
    if (stackTrace != null) {
      print('Stack trace: $stackTrace');
    }
  }
  
  // TODO: Send to crash reporting service in production
}