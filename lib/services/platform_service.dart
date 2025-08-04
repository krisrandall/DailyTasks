import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

enum PlatformType {
  mobile,
  tv,
  widget,
  desktop,
}

class PlatformService {
  static const MethodChannel _channel = MethodChannel('daily_tasks/platform');
  
  /// Detect the current platform type
  static PlatformType get currentPlatform {
    if (kIsWeb) {
      return PlatformType.desktop;
    }
    
    if (Platform.isAndroid) {
      // Check if running on Android TV
      // This would need platform-specific code to detect TV properly
      // For now, we'll use a simple screen size heuristic in the UI
      return PlatformType.mobile;
    }
    
    if (Platform.isIOS) {
      return PlatformType.mobile;
    }
    
    return PlatformType.desktop;
  }
  
  /// Check if running on Android TV
  static Future<bool> get isAndroidTV async {
    if (!Platform.isAndroid) return false;
    
    try {
      final result = await _channel.invokeMethod<bool>('isAndroidTV');
      return result ?? false;
    } catch (e) {
      // Fallback: assume not TV if we can't detect
      return false;
    }
  }
  
  /// Check if running as a widget
  static Future<bool> get isWidget async {
    try {
      final result = await _channel.invokeMethod<bool>('isWidget');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
  
  /// Get screen size category
  static ScreenSize getScreenSize(double width, double height) {
    final diagonal = _calculateDiagonal(width, height);
    
    if (diagonal < 7) {
      return ScreenSize.small; // Phone
    } else if (diagonal < 12) {
      return ScreenSize.medium; // Large phone / Small tablet
    } else if (diagonal < 24) {
      return ScreenSize.large; // Tablet
    } else {
      return ScreenSize.extraLarge; // TV / Desktop
    }
  }
  
  /// Calculate diagonal screen size in inches (approximate)
  static double _calculateDiagonal(double width, double height) {
    // Rough calculation assuming ~160 DPI
    final widthInches = width / 160;
    final heightInches = height / 160;
    return math.sqrt(widthInches * widthInches + heightInches * heightInches);
  }
  
  /// Check if device supports external storage
  static Future<bool> get hasExternalStorage async {
    if (!Platform.isAndroid) return false;
    
    try {
      final result = await _channel.invokeMethod<bool>('hasExternalStorage');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }
  
  /// Get external storage paths
  static Future<List<String>> get externalStoragePaths async {
    if (!Platform.isAndroid) return [];
    
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getExternalStoragePaths');
      return result?.cast<String>() ?? [];
    } catch (e) {
      return [];
    }
  }
  
  /// Request storage permissions (Android)
  static Future<bool> requestStoragePermission() async {
    if (!Platform.isAndroid) return true;
    
    try {
      // For Android 13+ (API 33+), request specific media permissions
      if (Platform.isAndroid) {
        final permissions = <Permission>[
          Permission.storage,
          Permission.audio,
          Permission.videos,
        ];
        
        // Add manage external storage for Android 11+
        if (await Permission.manageExternalStorage.status.isDenied) {
          permissions.add(Permission.manageExternalStorage);
        }
        
        final statuses = await permissions.request();
        
        // Check if any essential permission is granted
        return statuses[Permission.storage]?.isGranted == true ||
               statuses[Permission.audio]?.isGranted == true ||
               statuses[Permission.videos]?.isGranted == true ||
               statuses[Permission.manageExternalStorage]?.isGranted == true;
      }
      
      return false;
    } catch (e) {
      print('Error requesting storage permission: $e');
      return false;
    }
  }
  
  /// Check if storage permission is granted
  static Future<bool> get hasStoragePermission async {
    if (!Platform.isAndroid) return true;
    
    try {
      // Check multiple permission types for different Android versions
      final storageStatus = await Permission.storage.status;
      final audioStatus = await Permission.audio.status;
      final videoStatus = await Permission.videos.status;
      final manageExternalStatus = await Permission.manageExternalStorage.status;
      
      return storageStatus.isGranted ||
             audioStatus.isGranted ||
             videoStatus.isGranted ||
             manageExternalStatus.isGranted;
    } catch (e) {
      print('Error checking storage permission: $e');
      return false;
    }
  }
  
  /// Set system UI mode for different platforms
  static void setSystemUIMode(PlatformType platform) {
    switch (platform) {
      case PlatformType.tv:
        // Hide status bars and navigation bars for TV
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
        break;
      case PlatformType.widget:
        // Minimal UI for widget
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
        break;
      case PlatformType.mobile:
      case PlatformType.desktop:
        // Normal UI
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        break;
    }
  }
  
  /// Get appropriate font sizes for platform
  static Map<String, double> getFontSizes(PlatformType platform) {
    switch (platform) {
      case PlatformType.tv:
        return {
          'title': 24.0,
          'subtitle': 18.0,
          'body': 16.0,
          'caption': 14.0,
        };
      case PlatformType.widget:
        return {
          'title': 14.0,
          'subtitle': 12.0,
          'body': 11.0,
          'caption': 10.0,
        };
      case PlatformType.mobile:
      case PlatformType.desktop:
      default:
        return {
          'title': 18.0,
          'subtitle': 16.0,
          'body': 14.0,
          'caption': 12.0,
        };
    }
  }
  
  /// Get appropriate spacing for platform
  static Map<String, double> getSpacing(PlatformType platform) {
    switch (platform) {
      case PlatformType.tv:
        return {
          'small': 12.0,
          'medium': 20.0,
          'large': 32.0,
        };
      case PlatformType.widget:
        return {
          'small': 4.0,
          'medium': 8.0,
          'large': 12.0,
        };
      case PlatformType.mobile:
      case PlatformType.desktop:
      default:
        return {
          'small': 8.0,
          'medium': 16.0,
          'large': 24.0,
        };
    }
  }
}

enum ScreenSize {
  small,
  medium, 
  large,
  extraLarge,
}