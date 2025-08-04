import 'package:flutter/material.dart';
import '../services/media_service.dart';
import '../utils/constants.dart';

class MediaThumbnailWidget extends StatelessWidget {
  final MediaFile mediaFile;
  final VoidCallback onTap;
  final double size;
  final bool showInfo;

  const MediaThumbnailWidget({
    Key? key,
    required this.mediaFile,
    required this.onTap,
    this.size = AppConstants.thumbnailSize,
    this.showInfo = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          width: size,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thumbnail area
              Expanded(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      topRight: Radius.circular(8.0),
                    ),
                    color: Colors.grey[200],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Placeholder icon
                      Icon(
                        mediaFile.isVideo
                            ? Icons.video_file
                            : Icons.audio_file,
                        size: size * 0.3,
                        color: Colors.grey[400],
                      ),
                      
                      // Play button overlay
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: size * 0.15,
                        ),
                      ),
                      
                      // Media type indicator
                      Positioned(
                        top: 8.0,
                        right: 8.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6.0,
                            vertical: 2.0,
                          ),
                          decoration: BoxDecoration(
                            color: mediaFile.isVideo
                                ? Colors.red.withOpacity(0.8)
                                : Colors.blue.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Text(
                            mediaFile.isVideo ? 'VIDEO' : 'AUDIO',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Info area
              if (showInfo)
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // File name
                        Text(
                          mediaFile.displayName,
                          style: TextStyle(
                            fontSize: size * 0.1,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        
                        const Spacer(),
                        
                        // File size
                        Text(
                          mediaFile.size,
                          style: TextStyle(
                            fontSize: size * 0.08,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class GridMediaThumbnailWidget extends StatelessWidget {
  final MediaFile mediaFile;
  final VoidCallback onTap;
  final bool isSelected;

  const GridMediaThumbnailWidget({
    Key? key,
    required this.mediaFile,
    required this.onTap,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: isSelected
            ? Border.all(color: AppConstants.primaryColor, width: 3.0)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Material(
          child: InkWell(
            onTap: onTap,
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
                  if (isSelected)
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
  }
}