import 'package:flutter/material.dart';
import 'package:tamarun/core/theme/app_colors.dart';
import 'package:tamarun/core/widgets/remote_image.dart';

/// A full-screen, pinch-to-zoom viewer for a remote image.
///
/// Pushed when the user taps media artwork (for example the details poster).
/// The whole image is shown with [BoxFit.contain] and can be panned and zoomed
/// with [InteractiveViewer]. When [heroTag] is provided, a [Hero] links the
/// viewer to the tapped thumbnail for a shared transition.
class ImageViewer extends StatelessWidget {
  const ImageViewer({
    super.key,
    required this.uri,
    required this.fallback,
    this.heroTag,
  });

  final Uri uri;
  final Uri fallback;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final Widget image = RemoteImage(
      uri: uri,
      fallback: fallback,
      fit: BoxFit.contain,
    );
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 5.0,
              child: heroTag == null
                  ? image
                  : Hero(tag: heroTag!, child: image),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.spaceSm),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  color: Colors.white,
                  tooltip: "Close",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
