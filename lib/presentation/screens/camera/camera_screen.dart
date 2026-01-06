// Camera screen with custom viewfinder and scan overlay
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:io';
import '../../theme/app_theme.dart';
import '../../widgets/scan_animation_overlay.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras!.isEmpty) return;

      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      if (mounted) {
        setState(() => _isInitialized = true);
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  Future<void> _captureAndProcess() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    setState(() => _isScanning = true);

    try {
      final XFile image = await _controller!.takePicture();
      
      // Wait for animation to complete
      await Future.delayed(const Duration(milliseconds: 2000));
      
      if (mounted) {
        // Navigate to solution screen with image
        Navigator.pop(context, File(image.path));
      }
    } catch (e) {
      debugPrint('Capture error: $e');
      setState(() => _isScanning = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepBlack,
      body: Stack(
        children: [
          // Camera Preview
          if (_isInitialized && _controller != null)
            SizedBox.expand(
              child: CameraPreview(_controller!),
            )
          else
            const Center(
              child: CircularProgressIndicator(
                color: AppTheme.accentGold,
              ),
            ),

          // Custom Overlay
          _buildOverlay(),

          // Scan Animation
          if (_isScanning)
            const ScanAnimationOverlay(),

          // Controls
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.deepBlack.withOpacity(0.4),
      ),
      child: Stack(
        children: [
          // Focus Frame
          Center(
            child: Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.accentGold,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(17),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                      color: Colors.transparent,
                      width: 8,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Corner Markers
          Center(
            child: SizedBox(
              width: 300,
              height: 400,
              child: Stack(
                children: [
                  _buildCornerMarker(Alignment.topLeft),
                  _buildCornerMarker(Alignment.topRight),
                  _buildCornerMarker(Alignment.bottomLeft),
                  _buildCornerMarker(Alignment.bottomRight),
                ],
              ),
            ),
          ),

          // Instruction Text
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 450),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.slateGrey.withOpacity(0.9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.center_focus_strong, color: AppTheme.accentGold, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Scan your question',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerMarker(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 30,
        height: 30,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border(
            top: alignment.y < 0
                ? const BorderSide(color: AppTheme.lightGold, width: 4)
                : BorderSide.none,
            left: alignment.x < 0
                ? const BorderSide(color: AppTheme.lightGold, width: 4)
                : BorderSide.none,
            right: alignment.x > 0
                ? const BorderSide(color: AppTheme.lightGold, width: 4)
                : BorderSide.none,
            bottom: alignment.y > 0
                ? const BorderSide(color: AppTheme.lightGold, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              AppTheme.deepBlack,
              AppTheme.deepBlack.withOpacity(0.0),
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Gallery Button
            _buildControlButton(
              icon: Icons.photo_library,
              onTap: () {
                // TODO: Implement gallery picker
              },
            ),

            // Capture Button
            GestureDetector(
              onTap: _isScanning ? null : _captureAndProcess,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.accentGold,
                    width: 4,
                  ),
                ),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentGold,
                  ),
                ),
              ),
            ),

            // Flash Button
            _buildControlButton(
              icon: Icons.flash_off,
              onTap: () {
                // TODO: Implement flash toggle
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.slateGrey.withOpacity(0.8),
        ),
        child: Icon(
          icon,
          color: AppTheme.accentGold,
          size: 28,
        ),
      ),
    );
  }
}
