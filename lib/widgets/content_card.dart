import 'package:flutter/material.dart';

class ContentCard extends StatelessWidget {
  const ContentCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
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
                // TODO: This is a placeholder image
                image:
                    'https://media.discordapp.net/attachments/489847778881699871/994210790318018640/facebook_1657108707628_6950417680840581726.jpg?width=528&height=660',
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
