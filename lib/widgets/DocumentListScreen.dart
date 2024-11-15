import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class OpenDocument extends StatelessWidget {
  final String fileUrl;

  OpenDocument({required this.fileUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Open .docx Document'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // ignore: deprecated_member_use
            if (await canLaunch(fileUrl)) {
              // ignore: deprecated_member_use
              await launch(fileUrl);
            } else {
              throw 'Could not launch $fileUrl';
            }
          },
          child: Text('Open .docx Document'),
        ),
      ),
    );
  }
}
