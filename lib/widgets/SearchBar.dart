import 'dart:async';
import 'dart:convert';

import 'package:derejacom/Api/TotalItemsProvider.dart';
import 'package:derejacom/CardListScreen.dart';
import 'package:derejacom/Services/apiScannedService.dart';
import 'package:derejacom/Services/scannedCount.dart';
import 'package:derejacom/widgets/QRScanCard.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';

import 'package:derejacom/Api/api_base_url.dart';
import 'package:derejacom/Services/TokenServices.dart';
import 'package:derejacom/widgets/ImageViewerScreen.dart';
import 'package:derejacom/widgets/PDFViewerScreen.dart';
import 'package:derejacom/widgets/card_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchBarWidget extends StatefulWidget {
  final Function(String) onSearch;
  

  const SearchBarWidget({Key? key, required this.onSearch}) : super(key: key);

  @override
  _SearchBarWidgetState createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  bool _hasError = false;
  final TextEditingController _searchController = TextEditingController();
  final TokenService _tokenService = TokenService();
  final ApiScannedService apiScannedService = ApiScannedService();
  Timer? _debounce;
  String? _employerId;
  Map<String, dynamic>? _tokenData;
late TotalItemsProvider _totalItemsProvider;
  static const int page = 1;
  static const int pageSize = 10;

  @override
  void initState() {
    super.initState();
    _getEmployerIdFromToken();
     _totalItemsProvider = TotalItemsProvider();
  }

  Future<void> _getEmployerIdFromToken() async {
    _tokenData = await _tokenService.getDecodedToken();
    setState(() {
      _employerId = _tokenData?['nameid'];
    });
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchSearchResults(query);
    });
  }

  Future<void> _fetchSearchResults(String query) async {
    if (query.isEmpty) {
      _resetSearchResults();
      return;
    }

    if (_employerId == null) {
      print('Employer ID is not set yet');
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    final String url = '${ApiConstants.getSearchEmployeesUrl(_employerId!)}'
        '?PageSize=$pageSize&PageNumber=$page&key=$query';

    try {
      final response = await http.get(Uri.parse(url));
      print(response.statusCode);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data.isNotEmpty ? data : [];
          _hasError = false;
        });
        widget.onSearch(query);
      } else {
        throw Exception('Failed to load search results');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _searchResults.clear();
      });
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _resetSearchResults() {
    setState(() {
      _searchResults.clear();
      _hasError = false;
    });
    widget.onSearch('');
  }

  void _clearSearch() {
    _searchController.clear();
    _onSearchChanged(''); // Trigger search to reset results
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSearchTextField(),
        if (_isLoading) const LinearProgressIndicator(),
        if (_hasError) _buildErrorWidget(),
        if (!_isLoading && _searchResults.isNotEmpty)
          Expanded(child: _buildResultsList()),

                const SizedBox(height: 10),
          _buildCardRow(),
          const Expanded(child: CardListScreen()),
        // if (!_isLoading && _searchResults.isEmpty && !_hasError)
        //   const Padding(
        //     padding: EdgeInsets.all(2.0),
        //     child: Text('No results found'),
        //   ),
       ]
    );
  }



// Widget _buildCardRow() {
//   return FutureBuilder<int?>(
//     future: _getTotalItemsFromLocalStorage(), // Fetch totalItems asynchronously
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return Center(child: CircularProgressIndicator()); // Show loading spinner
//       } else if (snapshot.hasError) {
//         return Center(child: Text('Error: ${snapshot.error}')); // Show error
//       } else if (snapshot.hasData) {
//         int? totalItems = snapshot.data; // Get the totalItems from SharedPreferences
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             Expanded(
//               child: Padding(
//                 padding: EdgeInsets.all(2.0),
//                 child: CustomCard(
//                   title: 'Total Items',
//                   description: 'Display the total items from local storage',
//                   icon: Icons.info_outline,
//                   value: totalItems?.toString() ?? 'N/A', // Display totalItems
//                 ),
//               ),
//             ),
//           ],
//         );
//       } else {
//         return Center(child: Text('No data available')); // Handle case when there's no data
//       }
//     },
//   );
// }



  Widget _buildCardRow() {
    return StreamBuilder<int?>(
      stream: _totalItemsProvider.totalItemsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          int? totalItems = snapshot.data;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(2.0),
                  child: CustomCard(
                    title: 'Total Items',
                    description: 'Displays total items from SharedPreferences',
                    icon: Icons.info_outline,
                    value: totalItems?.toString() ?? 'N/A',
                  ),
                ),
              ),
            ],
          );
        } 
        else {
          return Center(child: Text('No data available'));
        }
      },
    );
  }



// Asynchronous function to get totalItems from SharedPreferences
// Future<int?> _getTotalItemsFromLocalStorage() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   return prefs.getInt('totalItems'); // Return the stored totalItems
// }


//   @override
// Widget build(BuildContext context) {
//   return Stack(
//     children: [
//       Column(
//         children: [
//           _buildSearchTextField(),
//           if (_isLoading) const LinearProgressIndicator(),
//           if (_hasError) _buildErrorWidget(),
//         ],
//       ),
//       if (!_isLoading && _searchResults.isNotEmpty)
//         Positioned(
//           top: 65, // Adjust this based on your search bar height
//           left: 0,
//           right: 0,
//           child: _buildResultsList(),
//         ),
//     ],
//   );
// }


  Widget _buildSearchTextField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextFormField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'Search for employee...',
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: const Icon(Iconsax.search_normal, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: _clearSearch,
                )
              : null,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    return  ListView.builder(
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final result = _searchResults[index];
          return _buildResultCard(result);
        },
      
    );
  }



  Widget _buildResultCard(result) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: InkWell(
        onTap: () => _showModals(result),
        borderRadius: BorderRadius.circular(12.0),
        splashColor: Colors.blue.withOpacity(0.3),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.antiAliasWithSaveLayer,
            children: [
              _buildListTile(result),
              // _buildBadge(),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _buildListTile(result) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      title: Text(
        '${result['firstName']} ${result['lastName']}',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        result['phoneNumber'],
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.arrow_right, color: Colors.red),
        onPressed: () {},
      ),
    );
  }

  Widget _buildErrorWidget() {
    return const Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: const [
          Icon(Icons.error_outline, color: Colors.red, size: 48),
          SizedBox(height: 8),
          Text(
            'An error occurred while fetching results. Please try again.',
            style: TextStyle(color: Colors.red, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showModals(item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        List<String> documentUrls =
            item['cvUrl']?.split(', ') ?? ["No Document Uploaded"];
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildProfileHeader(item),
                const SizedBox(height: 20),
                const Divider(color: Colors.grey),
                const SizedBox(height: 10),
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
                const SizedBox(height: 15),
                ListView.builder(
                  itemCount: documentUrls.length,
                  shrinkWrap:
                      true, // Prevents the ListView from taking infinite height
                  physics:
                      const NeverScrollableScrollPhysics(), // Disable scrolling for this ListView
                  itemBuilder: (context, index) {
                    return _buildDocumentButton(documentUrls[index]);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(item) {
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

  Widget _buildDocumentList(String url) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Documents", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildDocumentButton(url),
      ],
    );
  }

  Widget _buildDocumentButton(String url) {
    String fileName = url.split('/').last;
    IconData icon = _getFileIcon(url);

    return Container(
      width: double.infinity,
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
        onPressed: () => _handleDocumentOpening(url),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 0),
          backgroundColor: const Color.fromARGB(0, 254, 254, 254),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: ListTile(
          title: Text(
            fileName,
            style: const TextStyle(
              fontFamily: "Josefin Sans",
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color.fromARGB(255, 255, 255, 255),
            ),
          ),
          leading: Icon(icon, color: Colors.white, size: 35),
        ),
      ),
    );
  }

  IconData _getFileIcon(String url) {
    if (url.endsWith('.pdf')) {
      return Icons.picture_as_pdf; // PDF icon
    } else if (url.endsWith('.doc') || url.endsWith('.docx')) {
      return Icons.description; // DOC/DOCX icon
    }
    return Icons.image; // Default icon for other types
  }

  void _handleDocumentOpening(String url) async {
    if (url.endsWith('.pdf')) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Pdfviewerscreen(pdfUrl: url)));
    } else if (url.endsWith('.doc') || url.endsWith('.docx')) {
      await _openDocument(url);
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Imageviewerscreen(imageUrl: url)));
    }
  }

  Future<void> _openDocument(String url) async {
    // Implement the document opening logic here using a suitable package
    // For example, you could use a package to view documents or download and open
    // Example using url_launcher package
    // if (await canLaunch(url)) {
    //   await launch(url);
    // } else {
    //   throw 'Could not launch $url';
    // }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _totalItemsProvider.dispose();
    super.dispose();
  }
}
