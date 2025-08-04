import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_task.dart';
import '../services/media_service.dart';
import '../utils/constants.dart';

class MediaChooserScreen extends StatefulWidget {
  final DailyTask task;
  final Function(MediaFile) onMediaSelected;

  const MediaChooserScreen({
    Key? key,
    required this.task,
    required this.onMediaSelected,
  }) : super(key: key);

  @override
  State<MediaChooserScreen> createState() => _MediaChooserScreenState();
}

class _MediaChooserScreenState extends State<MediaChooserScreen> {
  List<MediaFile> _mediaFiles = [];
  bool _isLoading = true;
  String? _errorMessage;
  MediaFile? _selectedMedia;

  @override
  void initState() {
    super.initState();
    _loadMediaFiles();
  }

  Future<void> _loadMediaFiles() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final mediaService = context.read<MediaService>();
      final mediaFiles = await mediaService.getMediaFilesForTask(widget.task);

      setState(() {
        _mediaFiles = mediaFiles;
        _isLoading = false;
      });

      if (mediaFiles.isEmpty) {
        setState(() {
          _errorMessage = AppStrings.noMediaFound;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading media files: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.task.name),
            Text(
              AppStrings.selectMediaFile,
              style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshMediaFiles,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_mediaFiles.isEmpty) {
      return _buildEmptyState();
    }

    return _buildMediaGrid();
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.0,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16.0),
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24.0),
          ElevatedButton.icon(
            onPressed: _loadMediaFiles,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64.0,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16.0),
          Text(
            AppStrings.noMediaFound,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            'Check if the folder path is correct and contains media files',
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          Text(
            'Folder: ${widget.task.onDeviceMediaFolder}',
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.grey[500],
              fontFamily: 'monospace',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24.0),
          ElevatedButton.icon(
            onPressed: _refreshMediaFiles,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGrid() {
    return Column(
      children: [
        // Media count info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          color: Theme.of(context).cardColor,
          child: Row(
            children: [
              Icon(
                Icons.folder,
                size: 20.0,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.task.onDeviceMediaFolder.split('/').last,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${_mediaFiles.length} media files',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              _buildFilterButtons(),
            ],
          ),
        ),
        
        // Media grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16.0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: _getCrossAxisCount(),
              crossAxisSpacing: 12.0,
              mainAxisSpacing: 12.0,
              childAspectRatio: 0.8,
            ),
            itemCount: _mediaFiles.length,
            itemBuilder: (context, index) {
              final mediaFile = _mediaFiles[index];
              return GestureDetector(
                onTap: () => _selectMediaFile(mediaFile),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    border: _selectedMedia == mediaFile
                        ? Border.all(color: AppConstants.primaryColor, width: 3.0)
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Material(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                        ),
                        child: Stack(
                          children: [
                            // Background icon
                            Center(
                              child: Icon(
                                mediaFile.isVideo
                                    ? Icons.video_file
                                    : Icons.audio_file,
                                size: 40.0,
                                color: Colors.grey[400],
                              ),
                            ),
                            
                            // Play button
                            Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                                padding: const EdgeInsets.all(12.0),
                                child: const Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 20.0,
                                ),
                              ),
                            ),
                            
                            // File name overlay
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                    ],
                                  ),
                                ),
                                child: Text(
                                  mediaFile.displayName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            
                            // Selection indicator
                            if (_selectedMedia == mediaFile)
                              Positioned(
                                top: 8.0,
                                right: 8.0,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppConstants.primaryColor,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        
        // Selection info
        if (_selectedMedia != null) _buildSelectionBar(),
      ],
    );
  }

  Widget _buildFilterButtons() {
    final videoCount = _mediaFiles.where((f) => f.isVideo).length;
    final audioCount = _mediaFiles.where((f) => !f.isVideo).length;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFilterChip(
          label: 'All (${_mediaFiles.length})',
          isSelected: true,
          onTap: () {}, // TODO: Implement filtering
        ),
        const SizedBox(width: 8.0),
        _buildFilterChip(
          label: 'Video ($videoCount)',
          isSelected: false,
          onTap: () {}, // TODO: Implement filtering
        ),
        const SizedBox(width: 8.0),
        _buildFilterChip(
          label: 'Audio ($audioCount)',
          isSelected: false,
          onTap: () {}, // TODO: Implement filtering
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.primaryColor : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppConstants.primaryColor : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.0,
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      color: AppConstants.primaryColor.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            _selectedMedia!.isVideo ? Icons.video_file : Icons.audio_file,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedMedia!.displayName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _selectedMedia!.size,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _playSelectedMedia(),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  int _getCrossAxisCount() {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 6;
    if (screenWidth > 800) return 4;
    if (screenWidth > 600) return 3;
    return 2;
  }

  void _selectMediaFile(MediaFile mediaFile) {
    setState(() {
      _selectedMedia = mediaFile;
    });
  }

  void _playSelectedMedia() {
    if (_selectedMedia != null) {
      widget.onMediaSelected(_selectedMedia!);
      Navigator.pop(context);
    }
  }

  Future<void> _refreshMediaFiles() async {
    final mediaService = context.read<MediaService>();
    await mediaService.refreshMediaCache(widget.task.onDeviceMediaFolder);
    await _loadMediaFiles();
  }
}