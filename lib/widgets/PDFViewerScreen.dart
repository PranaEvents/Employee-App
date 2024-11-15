import 'package:flutter/material.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';

class Pdfviewerscreen extends StatefulWidget {
  final String pdfUrl;

  const Pdfviewerscreen({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  _PdfviewerscreenState createState() => _PdfviewerscreenState();
}

class _PdfviewerscreenState extends State<Pdfviewerscreen> {
  late PdfControllerPinch pdfControllerPinch;
  int totalPageCount = 0, currentPageCount = 1;
  bool isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    _loadPdf(); // Start loading the PDF
  }

  Future<void> _loadPdf() async {
    setState(() {
      isLoading = true; // Set loading to true
    });
    pdfControllerPinch = PdfControllerPinch(
      document: PdfDocument.openData(await InternetFile.get(widget.pdfUrl)),
    );
    setState(() {
      isLoading = false; // Set loading to false after the PDF is loaded
    });
  }

  Widget _buildUI() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xffde9844),)); // Show loader while loading
    }

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Total Pages: $totalPageCount"),
            IconButton(
                onPressed: () {
                  pdfControllerPinch.previousPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.linear);
                },
                icon: Icon(Icons.arrow_back)),
            Text("Current Page: $currentPageCount"),
            IconButton(
                onPressed: () {
                  pdfControllerPinch.nextPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.linear);
                },
                icon: Icon(Icons.arrow_forward)),
          ],
        ),
        _pdfView(),
      ],
    );
  }

  Widget _pdfView() {
    return Expanded(
        child: PdfViewPinch(
      scrollDirection: Axis.vertical,
      controller: pdfControllerPinch,
      onDocumentLoaded: (doc) {
        setState(() {
          totalPageCount = doc.pagesCount;
        });
      },
      onPageChanged: (page) {
        setState(() {
          currentPageCount = page;
        });
      },
    ));
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
                colors: [
                  Color(0xffd22464),
                  Color(0xffde9844)
                ], // Gradient colors for the background
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: const Text(
            "Document Viewer",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 239, 239, 239),
        body: _buildUI(),
      ),
    );
  }
}
