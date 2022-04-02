// import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/models/anime.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:miru/models/mal_client.dart';
import 'package:miru/widgets/show_details.dart';
import 'package:miru/constants.dart' as Constants show limitOfListItems;

class ListContainer extends StatefulWidget {
  final List<Anime> animeList;
  final Function animeMapCallback;
  final Function animeListCallback;
  final MALClient client;
  final String listType;
  final bool? connStatus;
  const ListContainer({
    Key? key,
    required this.animeList,
    required this.animeMapCallback,
    required this.animeListCallback,
    required this.client,
    required this.listType,
    this.connStatus,
  }) : super(key: key);
  @override
  _ListContainerState createState() => _ListContainerState();
}

class _ListContainerState extends State<ListContainer> {
  late List<Anime> animeList = widget.animeList;
  late bool? netConnected = widget.connStatus;

  Future<void> refreshList(_limit) async {
    Map newMap = Map();
    // bool hasConnection = await DataConnectionChecker().hasConnection;
    Map result = await widget.client.getAnimeList(
      AnimeListRequest(limit: _limit),
    );
    while (result["paging"]["next"] != null) {
      newMap = await widget.client.getAnimeList(
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
      widget.animeMapCallback(result);
      this.animeList = result[widget.listType];
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
        child: ListView.builder(
          key: PageStorageKey(widget.listType),
          physics: const AlwaysScrollableScrollPhysics(),
          itemExtent: 106.0,
          itemCount: animeList.length,
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
                      String oldStatus = this.animeList[index].userStatus;
                      Get.toNamed(
                        "/animeDetailsPage",
                        arguments: {
                          "anime": this.animeList[index],
                          "connStatus": this.netConnected,
                          "deviceSize": size,
                          "client": widget.client,
                          "callback": (Anime val) {
                            if (oldStatus != val.userStatus) {
                              print("status changed");
                              // Update list locally so no need to call API again to refresh
                              widget.animeListCallback(val, oldStatus, index);
                              oldStatus = val.userStatus;
                            }
                            // setState() edits the entire state based on anime_details_page
                            setState(
                              () {},
                            );
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
                                  image: animeList[index].picture.toString(),
                                  imageErrorBuilder:
                                      (context, error, stackTrace) => Container(
                                          height: 90,
                                          width: 65,
                                          child:
                                              Image.asset("assets/404img.png")),
                                )
                              : Container(
                                  height: 90,
                                  width: 65,
                                  child: Image.asset("assets/404img.png")),
                        ),
                        Expanded(
                          child: ShowDetails(
                            title: "${animeList[index].title}",
                            progress:
                                "${animeList[index].userEpisodesWatched}/${animeList[index].totalEpisodes}",
                            score: "${animeList[index].userScore}",
                            airingStatus: "${animeList[index].userStatus}",
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
    );
  }
}
