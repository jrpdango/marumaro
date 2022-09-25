import 'package:flutter/material.dart';

class ContentCard extends StatelessWidget {
  final String imageUrl;

  const ContentCard({
    Key? key,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(5.0)),
        onTap: () {},
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(5.0),
                bottomLeft: Radius.circular(5.0),
              ),
              child: FadeInImage.assetNetwork(
                fit: BoxFit.cover,
                height: 90,
                width: 65,
                placeholderCacheHeight: 90,
                placeholderCacheWidth: 65,
                placeholder: "assets/404img.png",
                image: imageUrl,
                imageErrorBuilder: (context, error, stackTrace) => SizedBox(
                  height: 90,
                  width: 65,
                  child: Image.asset("assets/404img.png"),
                ),
              ),
            ),
            const Expanded(
              child: SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
