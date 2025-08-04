class AppConfig {
  // App version
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // Feature flags
  static const bool enableExport = true;
  static const bool enableImport = true;
  static const bool enableNotifications = true;
  static const bool enableAnalytics = false;
  
  // Performance settings
  static const int maxMediaCacheSize = 100; // MB
  static const Duration mediaSearchTimeout = Duration(seconds: 30);
  static const Duration midnightCheckInterval = Duration(minutes: 1);
  
  // UI settings
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration longPressDelay = Duration(milliseconds: 500);
  static const int maxRecentTasks = 10;
  
  // Media settings
  static const List<String> supportedVideoFormats = [
    'mp4', 'mov', 'avi', 'mkv', 'webm', 'm4v', '3gp'
  ];
  static const List<String> supportedAudioFormats = [
    'mp3', 'wav', 'm4a', 'aac', 'ogg', 'flac', 'wma'
  ];
  
  // Platform specific settings
  static const Map<String, Map<String, dynamic>> platformSettings = {
    'mobile': {
      'maxThumbnailSize': 150.0,
      'gridCrossAxisCount': 2,
      'enableHapticFeedback': true,
    },
    'tv': {
      'maxThumbnailSize': 200.0,
      'gridCrossAxisCount': 4,
      'enableHapticFeedback': false,
    },
    'widget': {
      'maxThumbnailSize': 50.0,
      'gridCrossAxisCount': 1,
      'enableHapticFeedback': false,
    },
  };
  
  // Development settings
  static const bool isDebugMode = true; // Set to false for release
  static const bool enableLogging = true;
  static const bool enableDevtools = true;
  
  // Get platform-specific setting
  static T getPlatformSetting<T>(String platform, String key, T defaultValue) {
    final settings = platformSettings[platform];
    if (settings != null && settings.containsKey(key)) {
      return settings[key] as T;
    }
    return defaultValue;
  }
  
  // Validate configuration
  static bool isValidConfiguration() {
    return appVersion.isNotEmpty && 
           supportedVideoFormats.isNotEmpty && 
           supportedAudioFormats.isNotEmpty;
  }
}