import 'package:cached_network_image/cached_network_image.dart';
import 'package:car_route_app_assessment_technonext/app/core/widget/shimmer/shimmer_base.dart';
import 'package:flutter/material.dart';
import '../constants/app_constraints.dart';

class AppNetworkImageProvider extends StatelessWidget {
  final String? imagePath;
  final double width, padding, radius;
  final double? height;
  final BoxFit fit;
  final bool isBike;

  const AppNetworkImageProvider(
    this.imagePath,
    this.width,
    this.radius, {
    super.key,
    this.height,
    this.padding = 8,
    this.fit = BoxFit.fill,
    this.isBike = false,
  });

  @override
  Widget build(BuildContext context) {
    logger.i("");
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: appHelper.validateImageURL(imagePath ?? ""),
        height: height,
        width: width,
        fit: fit,
        progressIndicatorBuilder: (
          context,
          child,
          loadingProgress,
        ) {
          return ShimmerBase(
            child: SizedBox(
              height: height,
              width: width,
            ),
          );
        },
        errorWidget: (
          BuildContext context,
          String url,
          dynamic error,
        ) {
          logger.e(error);
          return SizedBox(
            height: height,
            width: width,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child:  Image.asset("assets/png/no_image.png"),
            ),
          );
        },
      ),
    );
  }
}
