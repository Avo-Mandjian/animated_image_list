library animated_image_list;

import "dart:math";

import 'package:flutter/material.dart';

import 'package:animated_image_list/photoViewerArbnb/PhotoViewerArbnb_page.dart';
import 'package:animated_image_list/photoViewerArbnb/PhotoViewerArbnb_screen.dart';
import 'package:animated_image_list/photoViewerArbnb/TransparentRoute.dart';
import 'package:animated_image_list/photoViewerArbnb/transparent_image.dart';

import 'SnappingListView.dart';

typedef ItemBuilder = Widget Function(
    BuildContext context, int index, double progress);

class AnimatedImageList extends StatelessWidget {
  final List<String> images;
  final ProviderBuilder? provider;
  final ProviderBuilder? placeHolder;
  final ItemBuilder? builder;
  final Axis scrollDirection;
  final double itemExtent;
  final double maxExtent;
  final EdgeInsetsGeometry paddingOfImage;
  final BorderRadiusGeometry? borderRadiusImage;
  final double elevation;
  final Function(int)? onItemChanged;

  /// builder for snapping effect list with two static sizes
  /// [scrollDirection] scroll direction for list horizontal or isVertical
  /// [itemExtent] not selected item size required to calculate animations
  /// [maxExtent] selected item size required to calculate animations
  /// [provider] Function which maps an url or image string to an image provider
  /// [images] 	A list of images url to display in the list by default it accepts urls
  ///  if custom image needed use provider paramter
  /// [builder] builder function for each item
  /// [placeHolder] 	Optional function which returns default placeholder
  /// for lightbox and error widget if image fails to load
  const AnimatedImageList({
    Key? key,
    required this.images,
    this.provider,
    this.placeHolder,
    this.builder,
    this.scrollDirection = Axis.vertical,
    this.itemExtent = 150,
    this.maxExtent = 400,
    this.paddingOfImage = const EdgeInsets.all(0),
    this.borderRadiusImage,
    this.elevation = 0.0,
    this.onItemChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SnappingListView.builder(
        onItemChanged: onItemChanged,
        itemBuilder: (context, index, progress, maxSize) {
          // print(maxHeight);
          String photo = images[index];
          var isVertical = scrollDirection == Axis.vertical;
          double translate =
              progress > 1 ? max(maxSize * (progress - 1.0), 0.0) : 0.0;
          return Padding(
              padding: paddingOfImage,
              child: Hero(
                  tag: "$photo-$index",
                  child: Material(
                      color: Colors.transparent,
                      elevation: elevation,
                      clipBehavior: Clip.antiAlias,
                      borderRadius: borderRadiusImage,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(TransparentRoute(
                            builder: (BuildContext context) =>
                                PhotoViewerArbnbPage(
                              photo,
                              index,
                              placeHolder: placeHolder,
                              provider: provider,
                            ),
                          ));
                        },
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            OverflowBox(
                              maxHeight: isVertical ? maxSize : null,
                              minHeight: isVertical ? itemExtent : null,
                              maxWidth: isVertical ? null : maxSize,
                              minWidth: isVertical ? null : itemExtent,
                              child: Container(
                                  height: isVertical ? maxSize : null,
                                  width: isVertical ? null : maxSize,
                                  child: Transform(
                                      transform: Matrix4.identity()
                                        ..translate(
                                            !isVertical ? translate : 0.0,
                                            isVertical ? translate : 0.0),
                                      child: provider != null
                                          ? provider!(photo) as Widget?
                                          : Image.network(
                                              photo,
                                              fit: BoxFit.fill,
                                              loadingBuilder:
                                                  (context, image, progress) {
                                                if (progress != null)
                                                  return Center(
                                                    child: SizedBox(
                                                      height: maxSize / 3,
                                                      width: maxSize / 3,
                                                      child:
                                                          CircularProgressIndicator(
                                                        value: (progress
                                                                .cumulativeBytesLoaded) /
                                                            (progress
                                                                    .expectedTotalBytes ??
                                                                1.0),
                                                      ),
                                                    ),
                                                  );
                                                return image;
                                              },
                                              errorBuilder:
                                                  (BuildContext context,
                                                      Object exception,
                                                      StackTrace? stackTrace) {
                                                return Image(
                                                  image: placeHolder
                                                          ?.call(photo) ??
                                                      MemoryImage(
                                                          kTransparentImage),
                                                );
                                              },
                                            ))),
                            ),
                            builder?.call(context, index, progress) ??
                                Container()
                          ],
                        ),
                      ))));
        },
        itemCount: images.length,
        scrollDirection: scrollDirection,
        itemExtent: itemExtent,
        maxExtent: maxExtent,
      ),
    );
  }
}
