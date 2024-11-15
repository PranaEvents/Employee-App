import 'package:flutter/material.dart';

class SearchResults extends StatelessWidget {
  final bool isLoading;
  final List<dynamic> searchResults;

  const SearchResults({
    Key? key,
    required this.isLoading,
    required this.searchResults,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator()) // Show loading indicator
        : searchResults.isEmpty
            ? Center(child: Text('No results found'))
            : Expanded(
                child: ListView.builder(
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.shopping_bag),
                      title: Text(searchResults[index]['name']),
                      subtitle: Text('Price: \$${searchResults[index]['price']}'),
                    );
                  },
                ),
              );
  }
}