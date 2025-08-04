import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/daily_task.dart';
import '../models/task_enums.dart';
import '../utils/file_utils.dart';

class MediaFile {
  final File file;
  final String displayName;
  final bool isVideo;
  final String size;

  MediaFile({
    required this.file,
    required this.displayName,
    required this.isVideo,
    required this.size,
  });
}

class MediaService extends ChangeNotifier {
  final Map<String, List<MediaFile>> _mediaCache = {};
  
  /// Get media files for a specific task
  Future<List<MediaFile>> getMediaFilesForTask(DailyTask task) async {
    // Check cache first
    if (_mediaCache.containsKey(task.onDeviceMediaFolder)) {
      return _mediaCache[task.onDeviceMediaFolder]!;
    }
    
    final mediaFiles = await _loadMediaFiles(task.onDeviceMediaFolder);
    _mediaCache[task.onDeviceMediaFolder] = mediaFiles;
    
    return mediaFiles;
  }
  
  /// Get the next media file for a sequence task
  Future<MediaFile?> getNextMediaFile(DailyTask task) async {
    final mediaFiles = await getMediaFilesForTask(task);
    
    if (mediaFiles.isEmpty) return null;
    
    if (task.taskType == TaskType.sequence) {
      final files = mediaFiles.map((mf) => mf.file).toList();
      final nextFile = FileUtils.getNextFileInSequence(files, task.lastMediaFilePlayed);
      
      if (nextFile != null) {
        return mediaFiles.firstWhere((mf) => mf.file.path == nextFile.path);
      }
    }
    
    return null;
  }
  
  /// Load media files from directory
  Future<List<MediaFile>> _loadMediaFiles(String directoryPath) async {
    try {
      final files = await FileUtils.getMediaFilesFromDirectory(directoryPath);
      
      final mediaFiles = <MediaFile>[];
      for (final file in files) {
        mediaFiles.add(MediaFile(
          file: file,
          displayName: FileUtils.getDisplayName(file),
          isVideo: FileUtils.isVideoFile(file.path),
          size: FileUtils.getFileSize(file),
        ));
      }
      
      return mediaFiles;
    } catch (e) {
      print('Error loading media files from $directoryPath: $e');
      return [];
    }
  }
  
  /// Refresh media cache for a specific folder
  Future<void> refreshMediaCache(String folderPath) async {
    _mediaCache.remove(folderPath);
    await _loadMediaFiles(folderPath);
    notifyListeners();
  }
  
  /// Clear all media cache
  Future<void> clearCache() async {
    _mediaCache.clear();
    notifyListeners();
  }
  
  /// Check if media folder exists and has files
  Future<bool> validateMediaFolder(String folderPath) async {
    final mediaFiles = await _loadMediaFiles(folderPath);
    return mediaFiles.isNotEmpty;
  }
  
  /// Get thumbnail path for a media file (placeholder implementation)
  Future<String?> getThumbnailPath(MediaFile mediaFile) async {
    // TODO: Implement thumbnail generation using video_thumbnail package
    // For now, return null - UI should show a default icon
    return null;
  }
  
  /// Get media file count for a folder
  Future<int> getMediaFileCount(String folderPath) async {
    final mediaFiles = await _loadMediaFiles(folderPath);
    return mediaFiles.length;
  }
  
  /// Get media folder info
  Future<Map<String, dynamic>> getMediaFolderInfo(String folderPath) async {
    final mediaFiles = await _loadMediaFiles(folderPath);
    
    int videoCount = 0;
    int audioCount = 0;
    
    for (final mediaFile in mediaFiles) {
      if (mediaFile.isVideo) {
        videoCount++;
      } else {
        audioCount++;
      }
    }
    
    return {
      'totalFiles': mediaFiles.length,
      'videoFiles': videoCount,
      'audioFiles': audioCount,
      'folderExists': await FileUtils.directoryExists(folderPath),
    };
  }
}