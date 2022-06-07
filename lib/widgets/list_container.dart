// import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:miru/models/mal_client.dart';
import 'package:miru/services/global_controller.dart';
import 'package:miru/widgets/show_details.dart';
import 'package:miru/constants.dart' as Constants show limitOfListItems;

class ListContainer extends StatefulWidget {
  final RxList<Anime>? animeList;
  final String listType;
  final bool? connStatus;
  const ListContainer({
    Key? key,
    required this.listType,
    this.animeList,
    this.connStatus,
  }) : super(key: key);
  @override
  _ListContainerState createState() => _ListContainerState();
}

class _ListContainerState extends State<ListContainer> {
  MALClient _client = Get.find<GlobalController>().client.value;
  late RxList<Anime> _animeList =
      widget.animeList ?? _client.clientAnimeList[widget.listType];
  late bool? netConnected = true;

  Future<void> refreshList(_limit) async {
    Map newMap = Map();
    // bool hasConnection = await DataConnectionChecker().hasConnection;
    Map result = await _client.getAnimeList(
      AnimeListRequest(limit: _limit),
    );
    while (result["paging"]["next"] != null) {
      newMap = await _client.getAnimeList(
        AnimeListRequest(
          limit: _limit,
          url: Uri.parse(result["paging"]["next"]),
        ),
      );
      for (String item in newMap.keys) {
        if (item != "paging" && item != "status_code") {
          result[item].addAll(newMap[item]);
        }
      }
      result["paging"]["next"] = newMap["paging"]["next"];
    }
    setState(() {
      _animeList = result[widget.listType];
      // this.netConnected = hasConnection;
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: () async {
        await refreshList(Constants.limitOfListItems);
      },
      child: Container(
        width: size.width,
        child: Obx(
          () => ListView.builder(
            key: PageStorageKey(widget.listType),
            physics: const AlwaysScrollableScrollPhysics(),
            itemExtent: 106.0,
            itemCount: _animeList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                child: Container(
                  width: size.width,
                  child: Card(
                    color: Colors.grey[900],
                    child: InkWell(
                      borderRadius: BorderRadius.all(Radius.circular(5.0)),
                      onTap: () {
                        String _oldStatus = _animeList[index].userStatus;
                        int _oldEpisodesWatched =
                            _animeList[index].userEpisodesWatched;

                        Get.toNamed(
                          "/animeDetailsPage",
                          arguments: {
                            "anime": _animeList[index],
                            "connStatus": this.netConnected,
                            "deviceSize": size,
                            "client": _client,
                            "callback": (Anime val) {
                              if (_oldStatus != val.userStatus) {
                                print("status changed");
                                // Update list locally so no need to call API again to refresh
                                _client.clientAnimeList[_oldStatus]
                                    .removeAt(index);
                                _client.clientAnimeList[val.userStatus]
                                    .insert(0, val);
                                _oldStatus = val.userStatus;
                              }

                              if (_oldEpisodesWatched !=
                                  val.userEpisodesWatched) setState(() {});
                            },
                          },
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(5.0),
                                bottomLeft: Radius.circular(5.0)),
                            child: this.netConnected!
                                ? FadeInImage.assetNetwork(
                                    fit: BoxFit.cover,
                                    height: 90,
                                    width: 65,
                                    placeholderCacheHeight: 90,
                                    placeholderCacheWidth: 65,
                                    placeholder: "assets/404img.png",
                                    image: _animeList[index].picture.toString(),
                                    imageErrorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                                height: 90,
                                                width: 65,
                                                child: Image.asset(
                                                    "assets/404img.png")),
                                  )
                                : Container(
                                    height: 90,
                                    width: 65,
                                    child: Image.asset("assets/404img.png")),
                          ),
                          Expanded(
                            child: ShowDetails(
                              title: "${_animeList[index].title}",
                              progress:
                                  "${_animeList[index].userEpisodesWatched}/${_animeList[index].totalEpisodes}",
                              score: "${_animeList[index].userScore}",
                              airingStatus: "${_animeList[index].showStatus}",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
