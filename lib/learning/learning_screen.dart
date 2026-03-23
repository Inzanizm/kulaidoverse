import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kulaidoverse/theme.dart';
import 'package:video_player/video_player.dart';
import 'package:kulaidoverse/learning/article.dart';
import 'article_detail.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  bool isVideos = true;

  final List<Map<String, dynamic>> _videos = [
    {
      'path': 'assets/vid/vid1.mp4',
      'title': 'What Causes Color Blindness?',
      'duration': '3 mins',
      'thumbnail': 'assets/vid/thumb1.png', // Optional: add thumbnail images
    },
    {
      'path': 'assets/vid/vid2.mp4',
      'title': 'Inherited Color Vision Deficiency',
      'duration': '4 mins',
      'thumbnail': 'assets/vid/thumb2.png',
    },
    {
      'path': 'assets/vid/vid3.mp4',
      'title': 'Myths About Color Vision Deficiency',
      'duration': '5 mins',
      'thumbnail': 'assets/vid/thumb3.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Ensure portrait mode when in learning screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _tabSwitcher(),
          const SizedBox(height: 20),
          Expanded(child: isVideos ? _videoList() : _articleList()),
        ],
      ),
    );
  }

  // ---------------- TABS ----------------
  Widget _tabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabItem(
              title: 'Videos',
              selected: isVideos,
              onTap: () {
                if (!isVideos) setState(() => isVideos = true);
              },
            ),
          ),
          Expanded(
            child: _tabItem(
              title: 'Articles',
              selected: !isVideos,
              onTap: () {
                if (isVideos) setState(() => isVideos = false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabItem({
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ---------------- VIDEOS ----------------
  Widget _videoList() {
    return ListView.builder(
      itemCount: _videos.length,
      itemBuilder: (_, index) => _videoCard(_videos[index]),
    );
  }

  Widget _videoCard(Map<String, dynamic> video) {
    return GestureDetector(
      onTap: () async {
        // Lock to landscape before navigating
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);

        if (!mounted) return;

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => VideoPlayerScreen(
                  videoPath: video['path'],
                  title: video['title'],
                ),
          ),
        );

        // Return to portrait when coming back
        if (!mounted) return;
        await SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Video thumbnail with fallback to placeholder
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child:
                  video['thumbnail'] != null
                      ? Image.asset(
                        video['thumbnail'],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildPlaceholder();
                        },
                      )
                      : _buildPlaceholder(),
            ),
            // Dark gradient overlay for better visibility
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            // Play button overlay
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                size: 40,
                color: Colors.white,
              ),
            ),
            // Title overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video['title'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      video['duration'],
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade700,
      child: const Icon(Icons.videocam, size: 64, color: Colors.white54),
    );
  }

  // ---------------- ARTICLES ----------------
  Widget _articleList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GridView.builder(
            itemCount: articlesData.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              final article = articlesData[index];
              return _articleCard(context, article);
            },
          ),
        ),
      ],
    );
  }

  Widget _articleCard(BuildContext context, Article article) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(article: article),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: AppTheme.softBlack,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 40, color: AppTheme.pureWhite),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              article.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppTheme.pureWhite,
              ),
            ),
            const SizedBox(height: AppTheme.spaceXs),
          ],
        ),
      ),
    );
  }
}

// ==================== VIDEO PLAYER SCREEN ====================

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final String title;

  const VideoPlayerScreen({
    super.key,
    required this.videoPath,
    required this.title,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  bool _showControls = true;
  double _sliderValue = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _controller = VideoPlayerController.asset(widget.videoPath);
      await _controller.initialize();
      await _controller.setLooping(false);

      // Listen to position updates for progress bar
      _controller.addListener(_onVideoPositionChanged);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _controller.play();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  void _onVideoPositionChanged() {
    if (!_isDragging && _controller.value.isInitialized && mounted) {
      final position = _controller.value.position.inMilliseconds.toDouble();
      final duration = _controller.value.duration.inMilliseconds.toDouble();

      if (duration > 0) {
        setState(() {
          _sliderValue = position / duration;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoPositionChanged);
    _controller.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video Player
            Center(
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : _hasError
                      ? const Text(
                        'Error loading video',
                        style: TextStyle(color: Colors.white),
                      )
                      : AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
            ),

            // Controls Overlay
            if (!_isLoading && !_hasError && _showControls)
              Container(
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
                    stops: const [0.0, 0.2, 0.8, 1.0],
                  ),
                ),
              ),

            // Top Bar (Back button and title)
            if (!_isLoading && !_hasError && _showControls)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false, // Don't apply safe area padding at bottom
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Center Play/Pause Button
            if (!_isLoading && !_hasError && _showControls)
              Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // Bottom Controls (Progress bar + time)
            if (!_isLoading && !_hasError && _showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Interactive Progress Slider
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.red,
                            inactiveTrackColor: Colors.white.withOpacity(0.3),
                            thumbColor: Colors.red,
                            overlayColor: Colors.red.withOpacity(0.2),
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 8,
                            ),
                          ),
                          child: Slider(
                            value: _sliderValue.clamp(0.0, 1.0),
                            onChanged: (value) {
                              setState(() {
                                _isDragging = true;
                                _sliderValue = value;
                              });
                            },
                            onChangeEnd: (value) async {
                              final duration = _controller.value.duration;
                              final newPosition = Duration(
                                milliseconds:
                                    (value * duration.inMilliseconds).round(),
                              );
                              await _controller.seekTo(newPosition);
                              setState(() {
                                _isDragging = false;
                              });
                            },
                          ),
                        ),

                        // Time indicators
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(_controller.value.position),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                _formatDuration(_controller.value.duration),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
