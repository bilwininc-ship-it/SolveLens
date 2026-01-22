import 'package:url_launcher/url_launcher.dart';
import 'logger.dart';

/// Email Launcher Utility
/// Handles opening email client with pre-filled content
class EmailLauncher {
  /// Launch email client with support request
  static Future<void> launchSupport({
    required String userUid,
  }) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: 'bilwininc@gmail.com',
      query: _encodeQueryParameters({
        'subject': 'SolveLens Support Request - $userUid',
        'body': 'Hello SolveLens Support Team,\n\n'
            'I need help with:\n\n'
            '---\n'
            'User ID: $userUid\n'
            'App Version: 1.0.0',
      }),
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        Logger.log('Support email launched for user: $userUid');
      } else {
        Logger.error('Could not launch email client', error: 'No email app found');
        throw 'Could not launch email client';
      }
    } catch (e) {
      Logger.error('Failed to launch email', error: e);
      rethrow;
    }
  }

  /// Launch email client with custom parameters
  static Future<void> launchEmail({
    required String email,
    String? subject,
    String? body,
  }) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: _encodeQueryParameters({
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      }),
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        Logger.log('Email launched to: $email');
      } else {
        Logger.error('Could not launch email client', error: 'No email app found');
        throw 'Could not launch email client';
      }
    } catch (e) {
      Logger.error('Failed to launch email', error: e);
      rethrow;
    }
  }

  /// Encode query parameters for URI
  static String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
