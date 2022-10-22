import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/widgets/detail_status_bar.dart';
import 'package:miru/widgets/detail_status_bar_section.dart';
import 'package:miru/widgets/list_status_overlay.dart';
import 'package:miru/enums/anime_list_type.dart';

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
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment(0.0, 0.3),
                    colors: <Color>[
                      Colors.transparent,
                      Color.fromRGBO(0, 0, 0, 0.2),
                    ],
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstATop,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 300.0,
                  child: Opacity(
                    opacity: 0.3,
                    // TODO: Create separate widget for FadeInImages
                    child: FadeInImage.assetNetwork(
                      fit: BoxFit.cover,
                      height: 300,
                      placeholderCacheHeight: 300,
                      placeholderCacheWidth: 365,
                      placeholder: 'assets/404img.png',
                      image: widget.anime?.pictureMedium.toString() ?? '',
                      imageErrorBuilder: (context, error, stackTrace) =>
                          SizedBox(
                        height: 300,
                        child: Image.asset('assets/404img.png'),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: FadeInImage.assetNetwork(
                          fit: BoxFit.cover,
                          height: 140,
                          width: 115,
                          placeholderCacheHeight: 140,
                          placeholderCacheWidth: 115,
                          placeholder: 'assets/404img.png',
                          image: widget.anime?.pictureMedium.toString() ?? '',
                          imageErrorBuilder: (context, error, stackTrace) =>
                              SizedBox(
                            height: 140,
                            width: 115,
                            child: Image.asset('assets/404img.png'),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          widget.anime?.title ?? '',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          DetailStatusBar(
            children: <Widget>[
              DetailStatusBarSection(
                icon: Icons.movie_rounded,
                text: widget.anime?.userStatus?.displayName ?? '',
                onTap: () {
                  Get.dialog(
                    ListStatusOverlay(
                      animeListType: widget.anime?.userStatus,
                      callback: (AnimeListType animeListType) {
                        setState(() {
                          widget.anime?.userStatus = animeListType;
                        });
                      },
                    ),
                  );
                },
              ),
              DetailStatusBarSection(
                icon: Icons.remove_red_eye,
                text: '2/12',
                onTap: () {},
              ),
              DetailStatusBarSection(
                icon: Icons.star,
                text: '0',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
