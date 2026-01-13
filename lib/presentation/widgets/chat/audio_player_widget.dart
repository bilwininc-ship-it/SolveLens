// Premium Audio Player Widget - Elite Professor Navy & White Theme
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class AudioPlayerWidget extends StatefulWidget {
  final String? audioUrl;
  final VoidCallback? onPlaybackComplete;

  const AudioPlayerWidget({
    super.key,
    this.audioUrl,
    this.onPlaybackComplete,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isPlaying = false;
  bool _isLoading = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerStateSubscription;

  // Premium Elite Professor Colors
  static const Color primaryNavy = Color(0xFF1E3A8A);
  static const Color brightBlue = Color(0xFF3B82F6);
  static const Color lightGrey = Color(0xFFF8FAFC);
  static const Color mediumGrey = Color(0xFF64748B);
  static const Color cleanWhite = Color(0xFFFFFFFF);

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _setupAudioPlayer();
    _setupAnimation();
  }

  void _setupAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  void _setupAudioPlayer() {
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          _isLoading = state == PlayerState.paused && _position.inSeconds == 0;
        });

        if (state == PlayerState.completed) {
          widget.onPlaybackComplete?.call();
          setState(() {
            _position = Duration.zero;
          });
        }
      }
    });
  }

  Future<void> _togglePlayPause() async {
    if (widget.audioUrl == null) return;

    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_position >= _duration && _duration != Duration.zero) {
          await _audioPlayer.seek(Duration.zero);
        }
        
        // Play audio from Firebase Storage URL
        if (widget.audioUrl!.startsWith('http')) {
          await _audioPlayer.play(UrlSource(widget.audioUrl!));
        }
      }
    } catch (e) {
      debugPrint('Error toggling playback: $e');
    }
  }

  Future<void> _seekTo(double value) async {
    final position = Duration(seconds: value.toInt());
    await _audioPlayer.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _pulseController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.audioUrl == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cleanWhite,
            lightGrey,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryNavy.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryNavy.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Icon and Label
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryNavy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.headphones_rounded,
                  color: primaryNavy,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Elite Professor Audio',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: primaryNavy,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'Tap to listen',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              // Duration Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: brightBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatDuration(_duration),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: brightBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Player Controls
          Row(
            children: [
              // Play/Pause Button
              GestureDetector(
                onTap: _isLoading ? null : _togglePlayPause,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _isPlaying ? _pulseAnimation.value : 1.0,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              primaryNavy,
                              primaryNavy.withOpacity(0.8),
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryNavy.withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: _isLoading
                            ? Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(cleanWhite),
                                ),
                              )
                            : Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: cleanWhite,
                                size: 28,
                              ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Progress Bar and Time
              Expanded(
                child: Column(
                  children: [
                    // Custom Slider
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8,
                          elevation: 2,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 16,
                        ),
                        activeTrackColor: primaryNavy,
                        inactiveTrackColor: mediumGrey.withOpacity(0.2),
                        thumbColor: primaryNavy,
                        overlayColor: primaryNavy.withOpacity(0.2),
                      ),
                      child: Slider(
                        value: _duration.inSeconds > 0
                            ? _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds.toDouble())
                            : 0,
                        min: 0,
                        max: _duration.inSeconds > 0
                            ? _duration.inSeconds.toDouble()
                            : 1,
                        onChanged: _seekTo,
                      ),
                    ),
                    // Time Labels
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: TextStyle(
                              fontSize: 11,
                              color: primaryNavy,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          // Progress Indicator
                          if (_duration.inSeconds > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: brightBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${((_position.inSeconds / _duration.inSeconds) * 100).toInt()}%',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: brightBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          Text(
                            _formatDuration(_duration),
                            style: TextStyle(
                              fontSize: 11,
                              color: mediumGrey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
