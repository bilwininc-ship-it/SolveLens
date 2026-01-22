import 'package:flutter/material.dart';

class UploadButton extends StatelessWidget {
  final VoidCallback onPressed;

  const UploadButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.upload_file),
      label: const Text('Görsel Yükle'),
    );
  }
}