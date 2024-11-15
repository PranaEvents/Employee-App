import 'package:flutter/material.dart';

class Imageviewerscreen extends StatefulWidget {
  final String imageUrl;

  const Imageviewerscreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  _ImageviewerscreenState createState() => _ImageviewerscreenState();
}

class _ImageviewerscreenState extends State<Imageviewerscreen> {
  bool isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _loadPdf();
    // No need to load anything explicitly, Image.network will handle the loading
  }

  Future<void> _loadPdf() async {
    setState(() {
      isLoading = true; // Set loading to true
    });
    setState(() {
      isLoading = false; // Set loading to false after the PDF is loaded
    });
  }

  Widget _buildUI() {
    return Center(
      child: isLoading
          ? const CircularProgressIndicator(
              color: Color(0xffde9844),
            ) // Show loader while loading
          : Image.network(
              widget.imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) {
                  // Image is fully loaded
                  return child;
                } else {
                  // Image is still loading
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xffde9844),
                    ),
                  );
                }
              },
              errorBuilder: (context, error, stackTrace) {
                // Handle error during image loading
                return const Center(
                  child: Text(
                    'Failed to load image',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xffd22464), Color(0xffde9844)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            "Document Viewer",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: const Color(0xFFEFEFEF),
        body: _buildUI(),
      ),
    );
  }
}
