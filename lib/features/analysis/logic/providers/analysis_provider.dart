import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../../../services/gemini/gemini_service.dart';
import '../../data/models/match_model.dart';
import '../../../../core/utils/logger.dart';

/// Analysis Provider
/// Manages image upload, OCR extraction, and match analysis state
class AnalysisProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();

  // State variables
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isLoading = false;
  String? _errorMessage;
  List<MatchModel> _extractedMatches = [];

  // Getters
  Uint8List? get selectedImageBytes => _selectedImageBytes;
  String? get selectedImageName => _selectedImageName;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<MatchModel> get extractedMatches => _extractedMatches;
  bool get hasImage => _selectedImageBytes != null;
  bool get hasMatches => _extractedMatches.isNotEmpty;

  /// Set selected image
  void setImage(Uint8List imageBytes, String imageName) {
    _selectedImageBytes = imageBytes;
    _selectedImageName = imageName;
    _extractedMatches = []; // Clear previous matches
    _errorMessage = null;
    notifyListeners();
    Logger.log('Image selected: $imageName (${imageBytes.length} bytes)');
  }

  /// Clear selected image and results
  void clearImage() {
    _selectedImageBytes = null;
    _selectedImageName = null;
    _extractedMatches = [];
    _errorMessage = null;
    notifyListeners();
    Logger.log('Image cleared');
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message
  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Extract matches from the selected image using Gemini OCR
  Future<bool> extractMatches() async {
    if (_selectedImageBytes == null) {
      _setError('No image selected');
      return false;
    }

    try {
      _setLoading(true);
      _setError(null);
      _extractedMatches = [];

      Logger.log('Starting match extraction from bulletin image...');

      // Call Gemini OCR service
      final matches = await _geminiService.extractMatches(_selectedImageBytes!);

      if (matches.isEmpty) {
        _setError('No matches found in the image. Please try with a clearer bulletin.');
        _setLoading(false);
        return false;
      }

      _extractedMatches = matches;
      _setLoading(false);
      
      Logger.log('Successfully extracted ${matches.length} matches');
      return true;
    } catch (e) {
      _setLoading(false);
      _setError(e.toString().replaceAll('Exception: ', ''));
      Logger.error('Match extraction failed', error: e);
      return false;
    }
  }

  /// Remove a specific match from the list
  void removeMatch(int index) {
    if (index >= 0 && index < _extractedMatches.length) {
      _extractedMatches.removeAt(index);
      notifyListeners();
      Logger.log('Match removed at index $index');
    }
  }

  /// Clear all extracted matches
  void clearMatches() {
    _extractedMatches = [];
    notifyListeners();
    Logger.log('All matches cleared');
  }
}