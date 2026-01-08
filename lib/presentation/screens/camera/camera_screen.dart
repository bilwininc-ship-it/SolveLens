// Camera screen with custom viewfinder, robust error handling, and full features
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
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
  bool _isFlashOn = false;
  String? _errorMessage;
  final ImagePicker _imagePicker = ImagePicker();

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
      setState(() {
        _errorMessage = null;
        _isInitialized = false;
      });

      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras found on this device';
        });
        return;
      }

      _controller = CameraController(
        _cameras![0],
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Camera initialization failed. Please check permissions.';
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final newFlashMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _controller!.setFlashMode(newFlashMode);
      
      if (mounted) {
        setState(() {
          _isFlashOn = !_isFlashOn;
        });
      }
    } catch (e) {
      debugPrint('Flash toggle error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Flash not available on this device'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        Navigator.pop(context, File(image.path));
      }
    } catch (e) {
      debugPrint('Gallery picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image from gallery'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _captureAndProcess() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera not ready. Please wait...')),
      );
      return;
    }
    
    if (_isScanning) return;

    setState(() => _isScanning = true);

    try {
      // Turn off flash before capture if it was on
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
      }

      final XFile image = await _controller!.takePicture();
      
      // Wait for animation to complete
      await Future.delayed(const Duration(milliseconds: 2000));
      
      if (mounted) {
        // Navigate to solution screen with image
        Navigator.pop(context, File(image.path));
      }
    } catch (e) {
      debugPrint('Capture error: $e');
      if (mounted) {
        setState(() => _isScanning = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.deepBlack,
      body: Stack(
        children: [
          // Camera Preview or Error
          if (_errorMessage != null)
            _buildErrorView()
          else if (_isInitialized && _controller != null)
            SizedBox.expand(
              child: CameraPreview(_controller!),
            )
          else
            _buildLoadingView(),

          // Custom Overlay
          if (_isInitialized && _errorMessage == null)
            _buildOverlay(),

          // Scan Animation
          if (_isScanning)
            const ScanAnimationOverlay(),

          // Controls
          if (_isInitialized && _errorMessage == null)
            _buildControls(),

          // Back Button
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.accentGold,
          ),
          SizedBox(height: 16),
          Text(
            'Initializing camera...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt_outlined,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeCamera,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPurple,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Pick from Gallery Instead'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.accentGold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.deepBlack.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
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
              onTap: _pickFromGallery,
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
              icon: _isFlashOn ? Icons.flash_on : Icons.flash_off,
              onTap: _toggleFlash,
              isActive: _isFlashOn,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive 
              ? AppTheme.accentGold.withOpacity(0.3)
              : AppTheme.slateGrey.withOpacity(0.8),
        ),
        child: Icon(
          icon,
          color: isActive ? AppTheme.lightGold : AppTheme.accentGold,
          size: 28,
        ),
      ),
    );
  }
}
