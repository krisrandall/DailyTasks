import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/daily_task.dart';
import '../services/media_service.dart';
import '../utils/constants.dart';

class MediaPlayerScreen extends StatefulWidget {
  final DailyTask task;
  final MediaFile mediaFile;
  final VoidCallback onMediaCompleted;

  const MediaPlayerScreen({
    Key? key,
    required this.task,
    required this.mediaFile,
    required this.onMediaCompleted,
  }) : super(key: key);

  @override
  State<MediaPlayerScreen> createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _startControlsTimer();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      if (widget.mediaFile.isVideo) {
        await _initializeVideoPlayer();
      } else {
        await _initializeAudioPlayer();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Failed to load media: $e';
      });
    }
  }

  Future<void> _initializeVideoPlayer() async {
    _videoController = VideoPlayerController.file(widget.mediaFile.file);
    
    await _videoController!.initialize();
    
    _videoController!.addListener(() {
      setState(() {
        _position = _videoController!.value.position;
        _duration = _videoController!.value.duration;
        _isPlaying = _videoController!.value.isPlaying;
      });

      // Check if video completed
      if (_position >= _duration && _duration > Duration.zero) {
        _onMediaCompleted();
      }
    });

    _duration = _videoController!.value.duration;
  }

  Future<void> _initializeAudioPlayer() async {
    _audioPlayer = AudioPlayer();
    
    await _audioPlayer!.setSourceDeviceFile(widget.mediaFile.file.path);
    
    _audioPlayer!.onDurationChanged.listen((duration) {
      setState(() {
        _duration = duration;
      });
    });

    _audioPlayer!.onPositionChanged.listen((position) {
      setState(() {
        _position = position;
      });
    });

    _audioPlayer!.onPlayerComplete.listen((_) {
      _onMediaCompleted();
    });

    _audioPlayer!.onPlayerStateChanged.listen((state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  void _startControlsTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControlsVisibility() {
    setState(() {
      _showControls = !_showControls;
    });
    
    if (_showControls) {
      _startControlsTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: _toggleControlsVisibility,
          child: Stack(
            children: [
              // Media content
              Center(
                child: _buildMediaContent(),
              ),
              
              // Controls overlay
              if (_showControls || !_isPlaying)
                _buildControlsOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaContent() {
    if (_isLoading) {
      return const CircularProgressIndicator(
        color: Colors.white,
      );
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (widget.mediaFile.isVideo && _videoController != null) {
      return AspectRatio(
        aspectRatio: _videoController!.value.aspectRatio,
        child: VideoPlayer(_videoController!),
      );
    } else {
      return _buildAudioPlayerUI();
    }
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.error_outline,
          color: Colors.white,
          size: 64.0,
        ),
        const SizedBox(height: 16.0),
        Text(
          _errorMessage ?? 'Unable to play media',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24.0),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Go Back'),
        ),
      ],
    );
  }

  Widget _buildAudioPlayerUI() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Audio icon
          Container(
            width: 200.0,
            height: 200.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppConstants.primaryColor.withOpacity(0.2),
            ),
            child: const Icon(
              Icons.music_note,
              size: 80.0,
              color: Colors.white,
            ),
          ),
          
          const SizedBox(height: 32.0),
          
          // File name
          Text(
            widget.mediaFile.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 8.0),
          
          // Task name
          Text(
            widget.task.name,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16.0,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: Column(
        children: [
          _buildTopControls(),
          const Spacer(),
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mediaFile.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.task.name,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Progress bar
          _buildProgressBar(),
          
          const SizedBox(height: 16.0),
          
          // Play controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _seekBackward,
                icon: const Icon(
                  Icons.replay_10,
                  color: Colors.white,
                  size: 32.0,
                ),
              ),
              
              const SizedBox(width: 24.0),
              
              // Play/Pause button
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppConstants.primaryColor,
                ),
                child: IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 36.0,
                  ),
                ),
              ),
              
              const SizedBox(width: 24.0),
              
              IconButton(
                onPressed: _seekForward,
                icon: const Icon(
                  Icons.forward_10,
                  color: Colors.white,
                  size: 32.0,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16.0),
          
          // Complete button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _markAsCompleted,
              icon: const Icon(Icons.check),
              label: const Text('Mark as Completed'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.completedColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppConstants.primaryColor,
            inactiveTrackColor: Colors.white.withOpacity(0.3),
            thumbColor: AppConstants.primaryColor,
            overlayColor: AppConstants.primaryColor.withOpacity(0.3),
            trackHeight: 4.0,
          ),
          child: Slider(
            value: _duration.inMilliseconds > 0
                ? _position.inMilliseconds.toDouble()
                : 0.0,
            max: _duration.inMilliseconds.toDouble(),
            onChanged: _onSeekChanged,
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _togglePlayPause() {
    if (widget.mediaFile.isVideo && _videoController != null) {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    } else if (_audioPlayer != null) {
      if (_isPlaying) {
        _audioPlayer!.pause();
      } else {
        _audioPlayer!.resume();
      }
    }
  }

  void _seekBackward() {
    final newPosition = _position - const Duration(seconds: 10);
    _seekTo(newPosition);
  }

  void _seekForward() {
    final newPosition = _position + const Duration(seconds: 10);
    _seekTo(newPosition);
  }

  void _seekTo(Duration position) {
    Duration clampedPosition;
    if (position < Duration.zero) {
      clampedPosition = Duration.zero;
    } else if (position > _duration) {
      clampedPosition = _duration;
    } else {
      clampedPosition = position;
    }
    
    if (widget.mediaFile.isVideo && _videoController != null) {
      _videoController!.seekTo(clampedPosition);
    } else if (_audioPlayer != null) {
      _audioPlayer!.seek(clampedPosition);
    }
  }

  void _onSeekChanged(double value) {
    final position = Duration(milliseconds: value.toInt());
    _seekTo(position);
  }

  void _onMediaCompleted() {
    // Auto-mark as completed when media finishes
    _markAsCompleted();
  }

  void _markAsCompleted() {
    widget.onMediaCompleted();
    
    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Task Completed! 🎉'),
        content: Text('You have completed "${widget.task.name}" for today.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close player
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
             '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:'
             '${seconds.toString().padLeft(2, '0')}';
    }
  }
}