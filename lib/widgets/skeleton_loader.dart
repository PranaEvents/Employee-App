import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  final Key _key = const Key("1");

  const SkeletonLoader({super.key});
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        key: _key,
        margin: const EdgeInsets.all(10),
        child: ListTile(
          title: Container(
            width: 100,
            height: 15,
            color: Colors.white,
          ),
          subtitle: Container(
            width: 150,
            height: 10,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
