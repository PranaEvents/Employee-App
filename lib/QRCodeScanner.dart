import 'dart:convert';
import 'package:derejacom/Api/api_base_url.dart';
import 'package:derejacom/Services/TokenServices.dart';
import 'package:derejacom/widgets/ImageViewerScreen.dart';
import 'package:derejacom/widgets/PDFViewerScreen.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:quickalert/quickalert.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class QRScannerScreen extends StatefulWidget {
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool isLoading = false;
  bool isProcessing = false;
  final TokenService _tokenService = TokenService();
  String? _employerId;

  @override
  void initState() {
    super.initState();
    _startQRScanner();
    _fetchEmployerIdFromToken();
  }

  void _startQRScanner() {
    controller?.resumeCamera();
    setState(() => isLoading = true);
  }

  Future<void> _fetchEmployerIdFromToken() async {
    final tokenData = await _tokenService.getDecodedToken();
    if (tokenData != null && mounted) {
      setState(() => _employerId = tokenData['nameid']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(flex: 11, child: _buildQrView(context)),
            if (isLoading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    final double scanArea = MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400
        ? 250.0
        : 350.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: const Color(0xffde9844),
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isProcessing) {
        setState(() {
          result = scanData;
          isProcessing = true;
        });
        _handleScannedData(result?.code);
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No camera permission')),
      );
    }
  }

  Future<void> _handleScannedData(String? qrCode) async {
    if (qrCode == null) return;

    setState(() => isLoading = false);

    if (!_isDesiredFormat(qrCode)) {
      await _showQuickAlert(
        QuickAlertType.error,
        'Failed',
        'Invalid QR code format. Please scan the correct QR code.',
      );
      setState(() => isProcessing = false);
      return;
    }

    final qrCodeData = jsonDecode(qrCode);
    final userId = qrCodeData['userid'];
    if (_employerId != null) {
      await _sendPostRequest(userId, _employerId!);
    }
  }

  bool _isDesiredFormat(String qrCode) {
    try {
      final qrCodeData = jsonDecode(qrCode);
      return qrCodeData.containsKey('userid');
    } catch (_) {
      return false;
    }
  }

  Future<void> _sendPostRequest(String employeeId, String employerId) async {
    final token = await _tokenService.getToken();
    final url = Uri.parse(ApiConstants.postQrScanDataUrl());

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'employerId': employerId,
          'employeeId': employeeId,
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body) as List<dynamic>;
        Navigator.pop(context); // Close the QR code screen
        _showModals(jsonResponse);
      } else {
        Navigator.pop(context);
        await _showQuickAlert(
          QuickAlertType.error,
          'Oops...',
          response.statusCode == 400
              ? 'The employee has already been scanned'
              : 'Customer check-in failed! Error: ${response.body}',
        );
      }
    } catch (e) {
      await _showQuickAlert(
        QuickAlertType.error,
        'Error',
        'An unexpected error occurred: $e',
      );
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  Future<void> _showQuickAlert(
      QuickAlertType type, String title, String message) async {
    await QuickAlert.show(
      context: context,
      type: type,
      title: title,
      text: message,
      confirmBtnText: "OK",
    );
  }

  void _showModals(List<dynamic> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        final documentUrls =
            items[0]['cvUrl']?.split(', ') ?? ["No Document Uploaded"];
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildProfileHeader(items[0]),
                const Divider(color: Colors.grey),
                const SizedBox(height: 10),
                _buildInfoRows(items[0]),
                const SizedBox(height: 15),
                _buildDocumentList(documentUrls),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(dynamic item) {
    return Row(
      children: [
        ClipOval(
          child: Image.asset(
            "assets/DefaultImg.jpg",
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item['firstName']} ${item['lastName']}',
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                item['phoneNumber'],
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRows(dynamic item) {
    return Column(
      children: [
        _buildInfoRow(Icons.accessibility,
            item['disability'] == true ? "Disability" : "Normal"),
        _buildInfoRow(Icons.male, item['gender'].toUpperCase()),
        _buildInfoRow(Icons.email, item['email']),
        _buildInfoRow(Icons.flag, item['region'].toUpperCase()),
        _buildInfoRow(Icons.location_city, item['city'].toUpperCase()),
        _buildInfoRow(Icons.school, item['university']),
        _buildInfoRow(Icons.business_center, item['department']),
        _buildInfoRow(Icons.grade_outlined,
            "Year of Graduate ${item['yearofGraduate'].split('/').last}"),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildDocumentList(List<String> documentUrls) {
    return ListView.builder(
      itemCount: documentUrls.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
    return _buildDocumentButton(documentUrls[index], context);
      },
    );
  }

  IconData _getFileIcon(String url) {
    if (url.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.png'))
      return Icons.image;
    return Icons.insert_drive_file;
  }

  Widget _buildDocumentButton(String url, BuildContext context) {
    // Determine the file extension
    String fileName = url.split('/').last;
    IconData icon;

    // Set the appropriate icon based on the file type
    if (url.endsWith('.pdf')) {
      icon = Icons.picture_as_pdf; // PDF icon
    } else if (url.endsWith('.doc') || url.endsWith('.docx')) {
      icon = Icons.description; // DOC/DOCX icon
    } else {
      icon = Icons.image; // Image icon for other file types
    }

    return Container(
      width: 100,
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffde9844), Color(0xffd22464)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 0),
            backgroundColor: const Color.fromARGB(0, 254, 254, 254),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: ListTile(
            // Display document name
            title: Text(
              fileName,
              style: const TextStyle(
                fontFamily: "Josefin Sans",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            leading: Icon(
              icon,
              color: Colors.white,
              size: 35,
            ), // Display the corresponding icon
            onTap: () {
              // Open document based on file type
              if (url.endsWith('.pdf')) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Pdfviewerscreen(pdfUrl: url)),
                );
              } else if (url.endsWith('.doc') || url.endsWith('.docx')) {
                _openFile(url);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Imageviewerscreen(imageUrl: url)),
                );
              }
            },
          )),
    );
  }

   Future<void> _openFile(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  // void _handleDocumentOpening(String url) async {
  //   if (url.endsWith('.pdf')) {
  //     Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => Pdfviewerscreen(pdfUrl: url)));
  //   } else if (url.endsWith('.doc') || url.endsWith('.docx')) {
  //     await _openDocument(url);
  //   } else {
  //     Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => Imageviewerscreen(imageUrl: url)));
  //   }
  // }

  Future<void> _openDocument(String url) async {
    // Implement the document opening logic here using a suitable package
    // For example, you could use a package to view documents or download and open
    // Example using url_launcher package
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
