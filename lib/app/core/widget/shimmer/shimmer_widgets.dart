import 'package:flutter/material.dart';

class ShimmerWidgets {
  Widget rowShimmer({double leftWidth = 50.0, double rightWidth = 60.0}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            height: 18,
            width: leftWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
          ),
          Container(
            height: 18,
            width: rightWidth,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
