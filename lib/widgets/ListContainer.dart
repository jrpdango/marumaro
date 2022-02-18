import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:miru/services/anime_list_request.dart';
import 'package:miru/services/mal_client.dart';
import 'package:miru/widgets/ShowDetails.dart';

class ListContainer extends StatefulWidget {
  final List animeList;
  final Function animeMapCallback;
  final MALClient client;
  final String listType;
  final bool connStatus;
  const ListContainer(
      {Key key,
      this.animeList,
      this.animeMapCallback,
      this.client,
      this.listType,
      this.connStatus})
      : super(key: key);
  @override
  _ListContainerState createState() => _ListContainerState();
}

class _ListContainerState extends State<ListContainer> {
  List animeList;
  bool netConnected;

  Future<void> refreshList() async {
    Map result = await widget.client.getAnimeList(AnimeListRequest());
    bool checkConn = await DataConnectionChecker().hasConnection;
    setState(() {
      widget.animeMapCallback(result);
      this.animeList = result[widget.listType];
      this.netConnected = checkConn;
    });
  }

  @override
  void initState() {
    this.netConnected = widget.connStatus;
    this.animeList = widget.animeList;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: () async {
        await refreshList();
      },
      child: Container(
          width: size.width,
          child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: animeList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                  child: Container(
                    width: size.width,
                    child: Card(
                      color: Colors.grey[900],
                      child: InkWell(
                        borderRadius: BorderRadius.all(Radius.circular(5.0)),
                        onTap: () {
                          String oldStatus =
                              this.animeList[index]["list_status"]["status"];
                          Get.toNamed("/animeDetailsPage", arguments: {
                            "animeMap": this.animeList[index],
                            "connStatus": this.netConnected,
                            "deviceSize": size,
                            "client": widget.client,
                            "callback": (val) async {
                              setState(() {
                                if (oldStatus != val["list_status"]["status"]) {
                                  print("status changed");
                                  this.animeList.removeAt(index);
                                } else {
                                  print("still the same");
                                  print(this.animeList[index]["list_status"]
                                      ["status"]);
                                  print(val["list_status"]["status"]);
                                  this.animeList[index] = val;
                                }
                              });
                              await refreshList();
                            }
                          });
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5.0),
                                  bottomLeft: Radius.circular(5.0)),
                              child: this.netConnected
                                  ? FadeInImage.assetNetwork(
                                      fit: BoxFit.cover,
                                      height: 90,
                                      width: 65,
                                      placeholderCacheHeight: 90,
                                      placeholderCacheWidth: 65,
                                      placeholder: "assets/404img.png",
                                      image: animeList[index]["node"]
                                          ["main_picture"]["medium"],
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
                                title: "${animeList[index]["node"]["title"]}",
                                progress:
                                    "${animeList[index]["list_status"]["num_episodes_watched"]}/${animeList[index]["node"]["num_episodes"]}",
                                score:
                                    "${animeList[index]["list_status"]["score"]}",
                                airingStatus:
                                    "${animeList[index]["node"]["status"]}",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              })),
    );
  }
}
