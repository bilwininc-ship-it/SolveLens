// Enhanced Hybrid Input Bar - Camera + PDF + Text Field + Real Voice Recording
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../../../core/di/service_locator.dart';
import '../../../services/voice/voice_service.dart';
import '../../theme/app_theme.dart';

class HybridInputBar extends StatefulWidget {
  final Function(String text)? onSendText;
  final Function(File image, String? caption)? onSendImage;
  final Function(String transcribedText, double durationMinutes)? onSendVoice;
  final Function(File pdf, String fileName, String fileSize)? onSendPDF;
  final bool isProcessing;
  final bool canSendText;
  final bool canSendVoice;

  const HybridInputBar({
    super.key,
    this.onSendText,
    this.onSendImage,
    this.onSendVoice,
    this.onSendPDF,
    this.isProcessing = false,
    this.canSendText = true,
    this.canSendVoice = true,
  });

  @override
  State<HybridInputBar> createState() => _HybridInputBarState();
}

class _HybridInputBarState extends State<HybridInputBar> {
  final TextEditingController _textController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  final AudioRecorder _audioRecorder = AudioRecorder();
  final VoiceService _voiceService = getIt<VoiceService>();
  
  bool _isRecording = false;
  bool _hasText = false;
  bool _isTranscribing = false;
  DateTime? _recordingStartTime;
  String? _recordingPath;

  @override
  void initState() {
    super.initState();
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    try {
      // Check permissions
      if (await _audioRecorder.hasPermission()) {
        debugPrint('Microphone permission granted');
      } else {
        debugPrint('Microphone permission not granted');
      }
    } catch (e) {
      debugPrint('Error initializing recorder: $e');
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _handleCamera() async {
    try {
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Fotoğraf Ekle',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Fotoğraf Çek',
                  color: const Color(0xFF1E3A8A),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                const SizedBox(height: 12),
                _buildSourceOption(
                  icon: Icons.photo_library,
                  label: 'Galeriden Seç',
                  color: const Color(0xFF1E3A8A),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
              ],
            ),
          ),
        ),
      );

      if (source != null) {
        final XFile? image = await _imagePicker.pickImage(
          source: source,
          imageQuality: 85,
        );

        if (image != null) {
          final caption = _textController.text.trim();
          _textController.clear();
          widget.onSendImage?.call(File(image.path), caption.isEmpty ? null : caption);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fotoğraf seçilemedi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final fileName = result.files.single.name;
        final fileSize = result.files.single.size;

        const maxSizeInBytes = 15 * 1024 * 1024;
        
        if (fileSize > maxSizeInBytes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text('PDF dosya boyutu 15MB sınırını aşıyor'),
                    ),
                  ],
                ),
                backgroundColor: Color(0xFF1E3A8A),
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }

        final formattedSize = _formatFileSize(fileSize);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('PDF seçildi: $fileName ($formattedSize)'),
                  ),
                ],
              ),
              backgroundColor: const Color(0xFF1E3A8A),
              duration: const Duration(seconds: 3),
            ),
          );
        }

        widget.onSendPDF?.call(file, fileName, formattedSize);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('PDF seçilemedi: $e'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF1E3A8A),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      final kb = (bytes / 1024).toStringAsFixed(2);
      return '$kb KB';
    } else {
      final mb = (bytes / (1024 * 1024)).toStringAsFixed(2);
      return '$mb MB';
    }
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSendText() {
    final text = _textController.text.trim();
    if (text.isNotEmpty && !widget.isProcessing) {
      widget.onSendText?.call(text);
      _textController.clear();
    }
  }

  Future<void> _handleMicrophone() async {
    if (!widget.canSendVoice) {
      _showQuotaExceededMessage('voice');
      return;
    }

    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        final path = '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.aacLc,
            bitRate: 128000,
            sampleRate: 44100,
          ),
          path: path,
        );

        setState(() {
          _isRecording = true;
          _recordingStartTime = DateTime.now();
          _recordingPath = path;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.mic, color: Colors.white),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Kayd ediliyor... Durdurmak için mikrofona basın'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: _cancelRecording,
                    tooltip: 'İptal',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              backgroundColor: AppTheme.errorRed,
              duration: const Duration(days: 1),
            ),
          );
        }
      } else {
        _showSnackBar('Mikrofon izni gerekli');
      }
    } catch (e) {
      debugPrint('Error starting recording: $e');
      _showSnackBar('Kayıt başlatılamadı: $e');
    }
  }

  Future<void> _stopRecording() async {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }

    try {
      final path = await _audioRecorder.stop();
      
      setState(() {
        _isRecording = false;
      });

      if (path != null && _recordingStartTime != null) {
        final duration = DateTime.now().difference(_recordingStartTime!);
        final durationMinutes = duration.inSeconds / 60.0;
        
        // Show transcription progress
        setState(() {
          _isTranscribing = true;
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text('Ses metne dönüştürülüyor...'),
                ],
              ),
              backgroundColor: AppTheme.primaryNavy,
              duration: Duration(seconds: 5),
            ),
          );
        }

        // Upload to Firebase Storage and get transcription
        await _uploadAndTranscribe(File(path), durationMinutes);
        
        setState(() {
          _isTranscribing = false;
        });
      }

      _recordingStartTime = null;
      _recordingPath = null;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      setState(() {
        _isRecording = false;
        _isTranscribing = false;
      });
      _showSnackBar('Kayıt durdurulamadı: $e');
    }
  }

  Future<void> _uploadAndTranscribe(File audioFile, double durationMinutes) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı giriş yapmamış');
      }

      // Upload to Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('voice_messages')
          .child(user.uid)
          .child('${DateTime.now().millisecondsSinceEpoch}.m4a');

      await storageRef.putFile(audioFile);
      final audioUrl = await storageRef.getDownloadURL();

      debugPrint('Audio uploaded to Firebase: $audioUrl');

      // Use VoiceService to transcribe via Speech-to-Text
      await _voiceService.initialize();
      
      // For now, we'll use a placeholder transcription
      // In production, you would integrate Google Cloud Speech-to-Text API
      final transcribedText = 'Sesli mesaj kaydedildi. Transkripsiy on yakında eklenecek.';
      
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Ses kaydedildi!'),
              ],
            ),
            backgroundColor: AppTheme.successGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }

      widget.onSendVoice?.call(transcribedText, durationMinutes);
    } catch (e) {
      debugPrint('Error uploading audio: $e');
      _showSnackBar('Ses yüklenemedi: $e');
    }
  }

  void _cancelRecording() async {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }

    if (_isRecording) {
      await _audioRecorder.stop();
    }

    setState(() {
      _isRecording = false;
      _recordingStartTime = null;
      _recordingPath = null;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 12),
              Text('Kayıt iptal edildi'),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showQuotaExceededMessage(String quotaType) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          quotaType == 'text'
              ? '💬 Metin mesaj kotanız doldu. Yükseltmek için premium üye olun!'
              : '🎤 Ses kotanız doldu. Yükseltmek için premium üye olun!',
        ),
        backgroundColor: Colors.orange,
        action: SnackBarAction(
          label: 'Yükselt',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Camera/Photo Button
            IconButton(
              onPressed: widget.isProcessing || _isRecording || _isTranscribing ? null : _handleCamera,
              icon: Icon(
                Icons.add_photo_alternate,
                color: widget.isProcessing || _isRecording || _isTranscribing
                    ? Colors.grey.shade400
                    : const Color(0xFF1E3A8A),
              ),
              tooltip: 'Fotoğraf ekle',
            ),
            // PDF Button
            IconButton(
              onPressed: widget.isProcessing || _isRecording || _isTranscribing ? null : _pickPDF,
              icon: Icon(
                Icons.picture_as_pdf,
                color: widget.isProcessing || _isRecording || _isTranscribing
                    ? Colors.grey.shade400
                    : const Color(0xFF1E3A8A),
              ),
              tooltip: 'PDF ekle',
            ),
            const SizedBox(width: 4),
            // Text Field
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 100,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  enabled: !widget.isProcessing && !_isRecording && !_isTranscribing,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: _isRecording ? 'Kaydediliyor...' : _isTranscribing ? 'İşleniyor...' : 'Soru sorun...',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 15,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1A1A1A),
                  ),
                  onSubmitted: (_) => _handleSendText(),
                ),
              ),
            ),
            const SizedBox(width: 4),
            // Send or Microphone Button
            _hasText
                ? IconButton(
                    onPressed: widget.isProcessing || _isRecording || _isTranscribing ? null : _handleSendText,
                    icon: Icon(
                      Icons.send,
                      color: widget.isProcessing || _isRecording || _isTranscribing
                          ? Colors.grey.shade400
                          : const Color(0xFF1E3A8A),
                    ),
                    tooltip: 'Gönder',
                  )
                : IconButton(
                    onPressed: widget.isProcessing || _isTranscribing ? null : _handleMicrophone,
                    icon: _isTranscribing
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E3A8A)),
                            ),
                          )
                        : Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: widget.isProcessing
                                ? Colors.grey.shade400
                                : _isRecording
                                    ? Colors.red
                                    : const Color(0xFF1E3A8A),
                          ),
                    tooltip: _isRecording ? 'Kaydı durdur' : 'Sesli mesaj',
                  ),
          ],
        ),
      ),
    );
  }
}
