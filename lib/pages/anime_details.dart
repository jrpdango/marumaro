import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/constants.dart';
import 'package:miru/globals.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/widgets/detail_status_bar.dart';
import 'package:miru/widgets/detail_status_bar_section.dart';
import 'package:miru/widgets/list_status_overlay.dart';
import 'package:miru/enums/anime_list_type.dart';

class AnimeDetails extends StatefulWidget {
  final Anime? anime;
  final int? index;
  final Function? onUpdate;
  const AnimeDetails({
    Key? key,
    required this.anime,
    required this.index,
    this.onUpdate,
  }) : super(key: key);
  @override
  State<AnimeDetails> createState() => _AnimeDetailsState();
}

class _AnimeDetailsState extends State<AnimeDetails> {
  int? index;

  @override
  void initState() {
    index = widget.index;
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
          Container(
            constraints: const BoxConstraints(
              maxHeight: 800.0,
            ),
            child: Stack(
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 4.0,
                          ),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                widget.anime?.title ?? '',
                                style: Theme.of(context).textTheme.headline5,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                              InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(4.0),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0,
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        'Title Info',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: MiruColors.primaryVariant,
                                            ),
                                      ),
                                      const Icon(
                                        Icons.arrow_drop_down_rounded,
                                        color: MiruColors.primaryVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: DetailStatusBar(
                      children: <Widget>[
                        DetailStatusBarSection(
                          icon: Icons.movie_rounded,
                          text: widget.anime?.userStatus?.displayName ?? '',
                          onTap: () {
                            Get.dialog(
                              ListStatusOverlay(
                                animeListType: widget.anime?.userStatus,
                                onSelect: (AnimeListType animeListType) {
                                  // TODO: set this to happen when pressing 'Update List'
                                  if (index != null) {
                                    Globals.client
                                        .animeMap[widget.anime?.userStatus]
                                        ?.removeAt(index!);
                                    Globals.client.animeMap[animeListType]
                                        ?.insert(0, widget.anime!);
                                    index = 0;
                                  }
                                  setState(() {
                                    widget.anime?.userStatus = animeListType;
                                  });
                                  widget.onUpdate?.call();
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
