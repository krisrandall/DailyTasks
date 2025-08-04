import 'dart:io';
import 'package:path/path.dart' as path;
import 'constants.dart';

class FileUtils {
  /// Check if a file has a supported media extension
  static bool isSupportedMediaFile(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    return AppConstants.allSupportedExtensions.contains(extension);
  }
  
  /// Check if a file is a video file
  static bool isVideoFile(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    return AppConstants.supportedVideoExtensions.contains(extension);
  }
  
  /// Check if a file is an audio file
  static bool isAudioFile(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    return AppConstants.supportedAudioExtensions.contains(extension);
  }
  
  /// Get all media files from a directory
  static Future<List<File>> getMediaFilesFromDirectory(String directoryPath) async {
    try {
      final directory = Directory(directoryPath);
      
      if (!await directory.exists()) {
        return [];
      }
      
      final files = await directory
          .list(recursive: false, followLinks: false)
          .where((entity) => entity is File)
          .cast<File>()
          .where((file) => isSupportedMediaFile(file.path))
          .toList();
      
      // Sort files alphabetically by name
      files.sort((a, b) => path.basename(a.path)
          .toLowerCase()
          .compareTo(path.basename(b.path).toLowerCase()));
      
      return files;
    } catch (e) {
      print('Error reading directory $directoryPath: $e');
      return [];
    }
  }
  
  /// Get the next file in sequence
  static File? getNextFileInSequence(List<File> files, String? lastPlayedFile) {
    if (files.isEmpty) return null;
    
    if (lastPlayedFile == null) {
      return files.first;
    }
    
    // Find the index of the last played file
    final lastIndex = files.indexWhere((file) => 
        path.basename(file.path) == path.basename(lastPlayedFile));
    
    if (lastIndex == -1) {
      // Last played file not found, start from beginning
      return files.first;
    }
    
    // Return next file, or loop back to first if we're at the end
    final nextIndex = (lastIndex + 1) % files.length;
    return files[nextIndex];
  }
  
  /// Get a display name for a file (without extension)
  static String getDisplayName(File file) {
    final fileName = path.basename(file.path);
    final name = path.basenameWithoutExtension(fileName);
    
    // Replace underscores and hyphens with spaces, and capitalize words
    return name
        .replaceAll(RegExp(r'[_-]'), ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : word)
        .join(' ');
  }
  
  /// Get file size in human readable format
  static String getFileSize(File file) {
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } catch (e) {
      return 'Unknown';
    }
  }
  
  /// Get file duration (placeholder - would need media info package for real implementation)
  static Future<String> getFileDuration(File file) async {
    // TODO: Implement using a package like flutter_ffmpeg or similar
    // For now, return a placeholder
    return 'Unknown';
  }
  
  /// Check if a directory path exists
  static Future<bool> directoryExists(String path) async {
    try {
      final directory = Directory(path);
      return await directory.exists();
    } catch (e) {
      return false;
    }
  }
  
  /// Get common media directories on the device
  static Future<List<String>> getCommonMediaDirectories() async {
    final List<String> directories = [];
    
    // Add external storage paths (Android)
    try {
      final externalDir = Directory('/storage/emulated/0');
      if (await externalDir.exists()) {
        for (final folderName in AppConstants.commonFolderNames) {
          final dirPath = path.join(externalDir.path, folderName);
          if (await directoryExists(dirPath)) {
            directories.add(dirPath);
          }
        }
      }
    } catch (e) {
      print('Error checking external directories: $e');
    }
    
    return directories;
  }
  
  /// Sanitize a file name for safe storage
  static String sanitizeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
  }
}