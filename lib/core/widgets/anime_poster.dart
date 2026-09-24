import 'package:flutter/material.dart';

/// Displays an anime poster, falling back to a placeholder on load errors.
class AnimePoster extends StatelessWidget {
  const AnimePoster({
    super.key,
    required this.picture,
    this.height = 90.0,
    this.width = 65.0,
  });

  static const String _placeholder = "assets/404img.png";

  final Uri picture;
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return FadeInImage.assetNetwork(
      fit: BoxFit.cover,
      height: height,
      width: width,
      placeholderCacheHeight: height.round(),
      placeholderCacheWidth: width.round(),
      placeholder: _placeholder,
      image: picture.toString(),
      imageErrorBuilder: (context, error, stackTrace) => Image.asset(
        _placeholder,
        height: height,
        width: width,
      ),
    );
  }
}
