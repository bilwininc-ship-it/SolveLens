import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../auth/logic/providers/auth_provider.dart';
import '../../logic/providers/analysis_provider.dart';
import '../../data/models/match_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../services/firebase/firebase_service.dart';
import '../../logic/prediction_engine.dart';
import 'analysis_result_screen.dart';

/// Analysis Screen - PHASE 11 & 12
/// Hybrid Image Picker + Gemini OCR Match Extraction
class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalysisProvider(),
      child: const _AnalysisScreenContent(),
    );
  }
}

class _AnalysisScreenContent extends StatelessWidget {
  const _AnalysisScreenContent();

  @override
  Widget build(BuildContext context) {
    final analysisProvider = Provider.of<AnalysisProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.navy,
      appBar: AppBar(
        backgroundColor: AppColors.navyLight,
        elevation: 0,
        title: const Text(
          'Bulletin Analysis',
          style: TextStyle(
            color: AppColors.cyanNeon,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.ivory),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Credit Display
                _buildCreditCard(context, authProvider),
                const SizedBox(height: 24),

                // Upload Button
                _buildUploadButton(context, analysisProvider),
                const SizedBox(height: 24),

                // Image Preview
                if (analysisProvider.hasImage) ..[
                  _buildImagePreview(context, analysisProvider),
                  const SizedBox(height: 24),
                ],

                // Extract Button
                if (analysisProvider.hasImage && !analysisProvider.hasMatches)
                  _buildExtractButton(context, analysisProvider, authProvider),

                // Loading State
                if (analysisProvider.isLoading) ..[
                  const SizedBox(height: 24),
                  _buildLoadingIndicator(),
                ],

                // Error Message
                if (analysisProvider.errorMessage != null) ..[
                  const SizedBox(height: 16),
                  _buildErrorMessage(context, analysisProvider),
                ],

                // Extracted Matches
                if (analysisProvider.hasMatches) ..[
                  const SizedBox(height: 24),
                  _buildMatchesHeader(analysisProvider),
                  const SizedBox(height: 16),
                  _buildMatchesList(context, analysisProvider),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Credit Display Card
  Widget _buildCreditCard(BuildContext context, AuthProvider authProvider) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseService.firestore
          .collection('users')
          .doc(authProvider.currentUser?.uid)
          .get(),
      builder: (context, snapshot) {
        final credits = snapshot.data?.get('credits') ?? 0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.navyLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.cyanNeon.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Credits',
                style: TextStyle(
                  color: AppColors.grey,
                  fontSize: 14,
                ),
              ),
              Text(
                '$credits',
                style: const TextStyle(
                  color: AppColors.cyanNeon,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Upload Bulletin Button
  Widget _buildUploadButton(BuildContext context, AnalysisProvider provider) {
    return ElevatedButton(
      onPressed: () => _pickImage(context, provider),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navyLight,
        foregroundColor: AppColors.cyanNeon,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.cyanNeon.withOpacity(0.5)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            provider.hasImage ? Icons.refresh : Icons.upload_file,
            color: AppColors.cyanNeon,
          ),
          const SizedBox(width: 8),
          Text(
            provider.hasImage ? 'Change Bulletin Image' : 'Upload Bulletin Image',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Image Preview
  Widget _buildImagePreview(BuildContext context, AnalysisProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cyanNeon.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Preview Label
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Icon(Icons.image, color: AppColors.cyanNeon, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    provider.selectedImageName ?? 'Preview',
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.error),
                  onPressed: () => provider.clearImage(),
                ),
              ],
            ),
          ),
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(8),
              bottomRight: Radius.circular(8),
            ),
            child: Image.memory(
              provider.selectedImageBytes!,
              fit: BoxFit.contain,
              width: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  /// Extract Matches Button
  Widget _buildExtractButton(
    BuildContext context,
    AnalysisProvider analysisProvider,
    AuthProvider authProvider,
  ) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseService.firestore
          .collection('users')
          .doc(authProvider.currentUser?.uid)
          .get(),
      builder: (context, snapshot) {
        final credits = snapshot.data?.get('credits') ?? 0;
        final hasCredits = credits > 0;

        return ElevatedButton(
          onPressed: hasCredits
              ? () => _extractMatches(context, analysisProvider, authProvider)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: hasCredits ? AppColors.cyanNeon : AppColors.grey,
            foregroundColor: AppColors.navy,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            disabledBackgroundColor: AppColors.grey.withOpacity(0.3),
            disabledForegroundColor: AppColors.grey,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasCredits ? Icons.auto_awesome : Icons.lock,
                color: hasCredits ? AppColors.navy : AppColors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                hasCredits ? 'Extract Matches (1 Credit)' : 'Get More Credits',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Loading Indicator
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cyanNeon.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyanNeon),
          ),
          const SizedBox(height: 16),
          const Text(
            'AI is reading the bulletin...',
            style: TextStyle(
              color: AppColors.cyanNeon,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'This may take a few seconds',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  /// Error Message
  Widget _buildErrorMessage(BuildContext context, AnalysisProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Matches Header
  Widget _buildMatchesHeader(AnalysisProvider provider) {
    return Row(
      children: [
        const Icon(Icons.sports_soccer, color: AppColors.cyanNeon),
        const SizedBox(width: 8),
        Text(
          'Extracted Matches (${provider.extractedMatches.length})',
          style: const TextStyle(
            color: AppColors.ivory,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Matches List
  Widget _buildMatchesList(BuildContext context, AnalysisProvider provider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.extractedMatches.length,
      itemBuilder: (context, index) {
        final match = provider.extractedMatches[index];
        return _buildMatchCard(context, match, index);
      },
    );
  }

  /// Individual Match Card (Clickable)
  Widget _buildMatchCard(BuildContext context, MatchModel match, int index) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    return InkWell(
      onTap: () => _analyzeMatch(context, match, authProvider),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.navyLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cyanNeon.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match Number & Analyze Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Match ${index + 1}',
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cyanNeon.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.cyanNeon.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.auto_awesome, color: AppColors.cyanNeon, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Analyze',
                        style: TextStyle(
                          color: AppColors.cyanNeon,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Teams
            Row(
              children: [
                Expanded(
                  child: Text(
                    match.home,
                    style: const TextStyle(
                      color: AppColors.ivory,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'VS',
                    style: TextStyle(
                      color: AppColors.cyanNeon,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    match.away,
                    style: const TextStyle(
                      color: AppColors.ivory,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Date
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today, color: AppColors.grey, size: 14),
                const SizedBox(width: 6),
                Text(
                  match.date,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Pick image using hybrid approach (Web: file_picker, Android: image_picker)
  Future<void> _pickImage(BuildContext context, AnalysisProvider provider) async {
    try {
      Uint8List? imageBytes;
      String? imageName;

      if (kIsWeb) {
        // Web: Use file_picker
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );

        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          imageBytes = file.bytes;
          imageName = file.name;
        }
      } else {
        // Android: Use image_picker
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          imageBytes = await pickedFile.readAsBytes();
          imageName = pickedFile.name;
        }
      }

      // Set image if picked
      if (imageBytes != null && imageName != null) {
        provider.setImage(imageBytes, imageName);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image selected successfully'),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// Extract matches from bulletin image
  Future<void> _extractMatches(
    BuildContext context,
    AnalysisProvider analysisProvider,
    AuthProvider authProvider,
  ) async {
    // Check API key
    if (AppConstants.geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please configure Gemini API Key in app_constants.dart'),
            backgroundColor: AppColors.error,
            duration: Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    // Extract matches
    final success = await analysisProvider.extractMatches();

    if (success) {
      // Deduct credit
      try {
        final userId = authProvider.currentUser?.uid;
        if (userId != null) {
          await FirebaseService.firestore
              .collection('users')
              .doc(userId)
              .update({
            'credits': FieldValue.increment(-1),
          });
        }
      } catch (e) {
        // Log error but don't block the UI
        debugPrint('Failed to deduct credit: $e');
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Matches extracted successfully!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Error message is already set in provider
      // No need to show additional snackbar
    }
  }

  /// Analyze match with AI prediction - PHASE 13 & 14
  Future<void> _analyzeMatch(
    BuildContext context,
    MatchModel match,
    AuthProvider authProvider,
  ) async {
    // Check credits first
    try {
      final userId = authProvider.currentUser?.uid;
      if (userId == null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please log in to use this feature'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      final userDoc = await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .get();
      
      final credits = userDoc.get('credits') ?? 0;
      
      if (credits < 1) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Insufficient credits. Please purchase more credits.'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Check API keys
      if (AppConstants.geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE') {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please configure Gemini API Key in app_constants.dart'),
              backgroundColor: AppColors.error,
              duration: Duration(seconds: 4),
            ),
          );
        }
        return;
      }

      // Show loading dialog
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => _buildLoadingDialog(),
        );
      }

      // Generate prediction
      final predictionEngine = PredictionEngine();
      final prediction = await predictionEngine.predictMatch(match);

      // Deduct credit
      await FirebaseService.firestore
          .collection('users')
          .doc(userId)
          .update({
        'credits': FieldValue.increment(-1),
      });

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Navigate to result screen
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnalysisResultScreen(prediction: prediction),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if open
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Show error
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  /// Loading dialog for AI analysis
  Widget _buildLoadingDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.navyLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cyanNeon.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.cyanNeon),
              strokeWidth: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              'AI is calculating win probabilities...',
              style: TextStyle(
                color: AppColors.cyanNeon,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Analyzing team statistics and form',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}