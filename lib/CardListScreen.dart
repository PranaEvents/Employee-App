import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:derejacom/widgets/DocumentListScreen.dart';
import 'package:derejacom/widgets/ImageViewerScreen.dart';
import 'package:derejacom/widgets/PDFViewerScreen.dart';
import 'package:derejacom/widgets/QRScanCard.dart';
import 'package:derejacom/widgets/card_item.dart';
import 'package:derejacom/widgets/skeleton_loader.dart';
import 'package:derejacom/widgets/api_service.dart';
import 'package:derejacom/Services/TokenServices.dart';

class CardListScreen extends StatefulWidget {
  const CardListScreen({Key? key}) : super(key: key);

  @override
  _CardListScreenState createState() => _CardListScreenState();
}

class _CardListScreenState extends State<CardListScreen> {
  final ApiService _apiService = ApiService();
  final ScrollController _scrollController = ScrollController();
  final TokenService _tokenService = TokenService();
  String? _employerId;
  int _currentPage = 1;
  final int _pageSize = 10;
  bool _hasMoreData = true;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _initializeEmployerId();
    // _scrollController.addListener(_onScroll);
  }

  Future<void> _initializeEmployerId() async {
    final tokenData = await _tokenService.getDecodedToken();
    if (tokenData != null) {
      _employerId = tokenData['nameid'];
      _fetchData();
    }
  }

  // void _fetchData() {
  //   if (_employerId != null) {
  //     _apiService.startFetchingItems(
  //         _currentPage, _pageSize, _employerId!, Duration(seconds: 1));
  //   }
  // }

  void _fetchData() {
    if (_employerId != null) {
      setState(() {
        _isLoading = true; // Indicate that data is being fetched
      });

      // Start fetching items periodically
      _apiService.startFetchingItems(
        _currentPage,
        _pageSize,
        _employerId!,
        Duration(seconds: 1),
      );

      // // Listen for updates from the itemsStream in your API service
      // _apiService.itemsStream.listen((fetchedItems) {
      //   setState(() {
      //      // Stop loading
      //     if (fetchedItems.isEmpty) {
      //       _hasMoreData = false; 
      //       _isLoading = false;// No more data available
      //     } else {
      //       _hasMoreData = fetchedItems.length ==
      //           _pageSize;
      //           _isLoading = false; // Check if more data is available
      //       // Process the fetched items as needed
      //     }
    
      //   });
      // }, onError: (error) {
      //   setState(() {
      //     _isLoading = false; // Stop loading on error
      //     // Handle the error state if needed
      //   });
      // });

      // Listen for updates from the itemsStream in your API service
_apiService.itemsStream.listen((fetchedItems) {
  Future.delayed(Duration(seconds: 10), () {
    setState(() {
      // Stop loading
      if (fetchedItems.isEmpty) {
        _hasMoreData = false; 
        _isLoading = false; // No more data available
      } else {
        _hasMoreData = fetchedItems.length == _pageSize;
        _isLoading = false; // Check if more data is available
        // Process the fetched items as needed
      }
    });
  });
}, onError: (error) {
  setState(() {
    _isLoading = false; // Stop loading on error
    // Handle the error state if needed
  });
});

    }
  }

  // void _onScroll() {
  //   if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
  //     _currentPage++;
  //     _fetchData();
  //   }
  // }

// void _onScroll() {
//   // Prevent multiple fetches while loading
//   // if (_isLoading) return;

//   // Check if we're at the bottom of the scrollable area
//   if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {
//     _currentPage++;
//     _fetchData();
//   }

//   // Check if we're at the top of the scrollable area
//   if (_scrollController.position.pixels <= _scrollController.position.minScrollExtent) {
//     if (_currentPage > 1) {
//       _currentPage--;
//       _fetchData();
//     }
//   }
// }

  void _nextPage() {
    setState(() {
      _currentPage++;
    });
    _fetchData(); // Fetch data for the next page
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
      });
      _fetchData();
    }
  }
  

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: _buildAppBar(),
    body: RefreshIndicator(
      color: const Color(0xffde9844),
      onRefresh: () async {
        _currentPage = 1; // Reset to first page on refresh
        _fetchData(); // Fetch data again
      },
      child: StreamBuilder<List<CardItem>>(
        stream: _apiService.itemsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
            return Container(child: SkeletonLoader());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error fetching data'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hourglass_empty, color: Colors.grey, size: 60),
                  SizedBox(height: 16),
                  Text('No data found',
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.black54,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            );
          } else {
            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () => _showModal(item),
                  child: Card(
                    child: Row(
                      children: [
                        Container(width: 7, height: 65, color: const Color(0xffd22464)),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${item.firstName} ${item.lastName}",
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold)),
                                Text("+${item.phoneNumber}",
                                    style: const TextStyle(
                                        fontSize: 14, fontWeight: FontWeight.w300)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    ),
  );
}

AppBar _buildAppBar() {
  return AppBar(
    title: const Text("List of Scanned",
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    actions: [
      // Previous Button
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          color: _currentPage > 1 ? const Color(0xffde9844) : Colors.grey,
          borderRadius: BorderRadius.circular(28.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed: _isLoading || _currentPage <= 1 ? null : _previousPage,
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          tooltip: 'Previous Page',
        ),
      ),
      // Next Button
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        decoration: BoxDecoration(
          color:_isLoading || _hasMoreData ? const Color(0xffde9844) : Colors.grey,
          borderRadius: BorderRadius.circular(28.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          onPressed:_isLoading || !_hasMoreData ? null : _nextPage,
          icon: const Icon(Icons.arrow_forward, color: Colors.white),
          tooltip: 'Next Page',
        ),
      ),
    ],
  );
}


  Widget _buildDocumentButton(String url, BuildContext context) {
    String fileName = url.split('/').last;
    IconData icon = Icons.image;

    if (url.endsWith('.pdf')) {
      icon = Icons.picture_as_pdf;
    } else if (url.endsWith('.doc') || url.endsWith('.docx')) {
      icon = Icons.description;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
      child: ElevatedButton(
        onPressed: () => _openFile(context, url, icon),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xffde9844),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: ListTile(
          title: Text(fileName,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
          leading: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  Future<void> _openFile(
      BuildContext context, String url, IconData icon) async {
    if (url.endsWith('.pdf')) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Pdfviewerscreen(pdfUrl: url)));
    } else if (url.endsWith('.doc') || url.endsWith('.docx')) {
      Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => Imageviewerscreen(imageUrl: url)));
    }
  }

  void _showModal(CardItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (BuildContext context) {
        List<String> documentUrls =
            item.cvUrl?.split(', ') ?? ["No Document Uploaded"];
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(item),
                const SizedBox(height: 20),
                const Divider(color: Colors.grey),
                const SizedBox(height: 10),
                _buildInfoRow(Icons.accessibility,
                    item.disability == true ? "Disability" : "Normal"),
                _buildInfoRow(Icons.male, item.gender.toUpperCase()),
                _buildInfoRow(Icons.email, item.email),
                _buildInfoRow(Icons.flag, item.region.toUpperCase()),
                _buildInfoRow(Icons.location_city, item.city.toUpperCase()),
                _buildInfoRow(Icons.school, item.university),
                _buildInfoRow(Icons.business_center, item.department),
                _buildInfoRow(Icons.grade_outlined,
                    "Year of Graduate ${item.yearofGraduate.split('/').last}"),
                const SizedBox(height: 15),
                ListView.builder(
                  itemCount: documentUrls.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return _buildDocumentButton(documentUrls[index], context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(CardItem item) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xffde9844), width: 2.0),
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Image.asset("assets/DefaultImg.jpg", fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xffde9844), Color(0xffd22464)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: Text(
                "${item.firstName} ${item.lastName}",
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "+${item.phoneNumber}",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String info) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Colors.black54),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              overflow: TextOverflow.clip,
              info,
              style: const TextStyle(
                  fontFamily: "Josefin Sans",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
