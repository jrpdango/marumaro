import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/widgets/content_card.dart';

class ListContainer extends StatefulWidget {
  const ListContainer({Key? key}) : super(key: key);

  @override
  State<ListContainer> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<ListContainer> {
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        child: ListView.builder(
          itemCount: 20,
          itemBuilder: ((context, index) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
              child: ContentCard(
                // TODO: This is a temporary image
                imageUrl:
                    'https://media.discordapp.net/attachments/489847778881699871/994210790318018640/facebook_1657108707628_6950417680840581726.jpg?width=528&height=660',
              ),
            );
          }),
        ),
        onRefresh: () async {
          return await null;
        });
  }
}
