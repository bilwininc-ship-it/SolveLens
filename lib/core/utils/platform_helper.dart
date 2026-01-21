import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class PlatformHelper {
  /// Check if running on web
  static bool get isWeb => kIsWeb;
  
  /// Check if running on mobile (Android or iOS)
  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  
  /// Check if running on Android
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  
  /// Check if running on iOS
  static bool get isIOS => !kIsWeb && Platform.isIOS;
  
  /// Check if camera is available on this platform
  static bool get hasCameraSupport => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
  
  /// Check if device info is available
  static bool get hasDeviceInfo => !kIsWeb;
  
  /// Check if file picker is available
  static bool get hasFilePicker => true; // Both web and mobile support file picker
  
  /// Check if voice features are available
  static bool get hasVoiceSupport => !kIsWeb && (Platform.isAndroid || Platform.isIOS);
}
