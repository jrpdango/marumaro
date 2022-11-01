import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/constants.dart';
import 'package:miru/enums/app_bar_type.dart';
import 'package:miru/globals.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/models/user_list_status.dart';
import 'package:miru/utils/progress_formatter.dart';
import 'package:miru/widgets/custom_app_bar.dart';
import 'package:miru/widgets/detail_status_bar.dart';
import 'package:miru/widgets/detail_status_bar_section.dart';
import 'package:miru/widgets/list_progress_overlay.dart';
import 'package:miru/widgets/list_score_overlay.dart';
import 'package:miru/widgets/list_status_overlay.dart';
import 'package:miru/enums/anime_list_type.dart';

class AnimeDetails extends StatefulWidget {
  final Anime? anime;
  final int index;
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
  int? _index;
  Anime? _anime;
  UserListStatus? _userListStatus;

  @override
  void initState() {
    // Store an index of where in the ListContainer the selected ContentCard is
    _index = widget.index;
    // Create a deep copy of the passed Anime
    _anime = widget.anime?.copyWith();
    // Create a new UserListStatus for updates
    _userListStatus = widget.anime?.userListStatus?.copyWith();
    super.initState();
  }

  /// Returns [true] if the current Anime has any changes to it.
  bool get hasChanges {
    return _anime?.userListStatus?.status == _userListStatus?.status &&
        _anime?.userListStatus?.currentProgress ==
            _userListStatus?.currentProgress &&
        _anime?.userListStatus?.score == _userListStatus?.score;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(
        appBarType: AppBarType.back,
        hasBackground: false,
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
                        image: _anime?.pictureMedium.toString() ?? '',
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
                            image: _anime?.pictureMedium.toString() ?? '',
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
                                _anime?.title ?? '',
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
                          text: _userListStatus?.status?.displayName ?? '',
                          onTap: () {
                            Get.dialog(
                              ListStatusOverlay(
                                currentStatus: _userListStatus?.status,
                                onSelect: (AnimeListType animeListType) {
                                  setState(() {
                                    _userListStatus?.status = animeListType;
                                  });
                                  // Close the overlay
                                  Get.back();
                                },
                              ),
                            );
                          },
                        ),
                        DetailStatusBarSection(
                          icon: Icons.remove_red_eye,
                          text:
                              '${_userListStatus?.currentProgress ?? '?'} / ${ProgressFormatter.format(_anime?.totalEpisodes) ?? '?'}',
                          onTap: () {
                            Get.dialog(
                              ListProgressOverlay(
                                onChanged: (String progress) {
                                  setState(() {
                                    _userListStatus?.currentProgress =
                                        int.tryParse(progress);
                                  });
                                  // Close the overlay
                                  Get.back();
                                },
                                currentProgress:
                                    _anime?.userListStatus?.currentProgress,
                                total: _anime?.totalEpisodes,
                              ),
                            );
                          },
                        ),
                        DetailStatusBarSection(
                          icon: Icons.star,
                          text: '${_userListStatus?.score ?? '?'}',
                          onTap: () {
                            Get.dialog(
                              ListScoreOverlay(
                                currentScore: _userListStatus?.score ?? 0,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Builder(
            builder: (_) {
              if (!hasChanges) {
                return Container(
                  height: 48.0,
                  width: double.infinity,
                  margin: const EdgeInsets.all(16.0),
                  child: TextButton(
                    onPressed: () {
                      if (_index == null) return;
                      // If list status changed, locally move the item to the right ListContainer
                      if (_anime?.userListStatus?.status !=
                          _userListStatus?.status) {
                        // Remove the ContentCard from wherever it was
                        Globals.client.animeMap[_anime?.userListStatus?.status]
                            ?.removeAt(_index!);
                        // Insert at index 0 the ContentCard at its new status ListContainer
                        Globals.client.animeMap[_userListStatus?.status]
                            ?.insert(0, _anime!);
                        // Set the local index to 0 since that's where the new ContentCard is
                        _index = 0;
                      }
                      // Edit the client's animeMap Anime with the current UserListStatus
                      widget.anime?.userListStatus =
                          _userListStatus?.copyWith();
                      // Assign the new userListStatus to the current Anime
                      // setState to hide the 'Update List' button
                      setState(() {
                        _anime?.userListStatus = _userListStatus?.copyWith();
                      });
                      // This callback should call setState() on the current ListContainer
                      widget.onUpdate?.call();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: MiruColors.buttonColor,
                    ),
                    child: Text(
                      'Update List',
                      style: Theme.of(context).textTheme.bodyText1?.copyWith(
                            color: MiruColors.textColor,
                          ),
                    ),
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }
}
