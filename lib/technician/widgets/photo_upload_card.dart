import 'package:flutter/material.dart';

class PhotoUploadCard extends StatelessWidget {
  final String title;

  const PhotoUploadCard({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.camera_alt),
        title: Text(title),
        trailing: const Icon(Icons.upload),
      ),
    );
  }
}