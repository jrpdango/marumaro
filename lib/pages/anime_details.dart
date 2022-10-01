import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/enums/app_bar_type.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/widgets/custom_app_bar.dart';

class AnimeDetails extends StatefulWidget {
  final Anime? anime;
  const AnimeDetails({
    Key? key,
    required this.anime,
  }) : super(key: key);
  @override
  State<AnimeDetails> createState() => _AnimeDetailsState();
}

class _AnimeDetailsState extends State<AnimeDetails> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 140.0,
                child: FadeInImage.assetNetwork(
                  fit: BoxFit.cover,
                  height: 140,
                  width: 115,
                  placeholderCacheHeight: 90,
                  placeholderCacheWidth: 65,
                  placeholder: 'assets/404img.png',
                  image: widget.anime?.pictureMedium.toString() ?? '',
                  imageErrorBuilder: (context, error, stackTrace) => SizedBox(
                    height: 90,
                    width: 65,
                    child: Image.asset('assets/404img.png'),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      10.0,
                      90.0,
                      10.0,
                      12.0,
                    ),
                    child: FadeInImage.assetNetwork(
                      fit: BoxFit.cover,
                      height: 140,
                      width: 115,
                      placeholderCacheHeight: 90,
                      placeholderCacheWidth: 65,
                      placeholder: 'assets/404img.png',
                      image: widget.anime?.pictureMedium.toString() ?? '',
                      imageErrorBuilder: (context, error, stackTrace) =>
                          SizedBox(
                        height: 90,
                        width: 65,
                        child: Image.asset('assets/404img.png'),
                      ),
                    ),
                  ),
                  Text(
                    widget.anime?.title ?? '',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
