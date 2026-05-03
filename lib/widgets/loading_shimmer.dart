import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade700,
      child: ListView.builder(
        itemCount: 4,
        itemBuilder: (_, _) => Padding(
          padding: const EdgeInsets.all(8),
          child: Container(height: 90, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
        ),
      ),
    );
  }
}
