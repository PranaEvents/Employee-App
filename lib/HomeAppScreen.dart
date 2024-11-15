import 'package:derejacom/CardListScreen.dart';
import 'package:derejacom/QRCodeScanner.dart';
import 'package:derejacom/Services/TokenServices.dart';
import 'package:derejacom/signin_screen.dart';
import 'package:derejacom/widgets/QRScanCard.dart';
import 'package:derejacom/widgets/SearchBar.dart';
import 'package:derejacom/widgets/SearchResults.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  bool _hasSearched = false;
  List<dynamic> _searchResults = [];
  final TokenService _tokenService = TokenService();
  String? _companyName;
  
  @override
  void initState() {
    super.initState();
    _getCompanyNameFromToken();
  }

  Future<void> _getCompanyNameFromToken() async {
    final tokenData = await _tokenService.getDecodedToken();
    if (tokenData != null) {
      setState(() {
        _companyName = tokenData['email'];
      });
    }
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    // Simulate delay for fetching search results
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      _searchResults = [
        {"name": "Product 1", "price": 50},
        {"name": "Product 2", "price": 100},
      ];
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Color(0xffde9844)),
              SizedBox(width: 8),
              Text(
                "Confirm Logout",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          content: const Text(
            "Are you sure you want to logout?",
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel", style: Theme.of(context).textTheme.titleMedium),
            ),
            TextButton(
              onPressed: () => _logout(context),
              child: Text("Yes", style: Theme.of(context).textTheme.titleMedium),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 10),
         Expanded(child:  _buildSearchBar(),),
          // if (_hasSearched) SearchResults(isLoading: _isLoading, searchResults: _searchResults),
          // const SizedBox(height: 10),
          // _buildCardRow(),
          // const Expanded(child: CardListScreen()),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: Container(
      padding: EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
      // Row with Image on the left and Text link centered
        Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image on the left
          Image.asset(
            'assets/mcf.jpg', // Replace with your image path
            height: 70,
          ),
          
          SizedBox(width: 8), // Spacing between image and text

          // Clickable text centered
          Expanded(
            child: GestureDetector(
              onTap: () async {
                final url = Uri.parse("https://bit.ly/SystemElements");
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              },
              child: Text(
                'Powered by System Elements',
                style: TextStyle(fontSize: 12, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    ],
  ),
));
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80.0),
      child: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffd22464), Color(0xffde9844)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/logo_kl0fke.png',
              width: 150,
              height: 150,
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_companyName != null)
             Image.asset(
              'assets/dereja.png',
              width: 80,
              height: 80,
            ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: double.infinity,
      height: 70,
      child: SearchBarWidget(onSearch: _performSearch),
    );
  }

  Widget _buildCardRow() {
    return const SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: CustomCard(
                title: 'Total Scanned',
                description: 'Display the Number of Scanned',
                icon: Icons.info_outline,
                value: "20",
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(2.0),
              child: CustomCard(
                title: 'Total Scanned Today',
                description: 'Display the Number of Scanned Today',
                icon: Icons.info_outline,
                value: "300",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return SizedBox(
      width: 75.0,
      height: 75.0,
      child: FloatingActionButton(
        backgroundColor: const Color(0xffd22464),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: QRScannerScreen(),
                ),
              ),
            ),
          );
        },
        child: const Icon(
          Icons.qr_code_scanner,
          color: Colors.white,
          size: 50,
        ),
      ),
    );
  }
}
