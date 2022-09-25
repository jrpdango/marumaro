import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:miru/globals.dart';

class UserProfileCard extends StatelessWidget {
  const UserProfileCard({Key? key}) : super(key: key);

  Future<NetworkImage?> _getUserImage() async {
    if (Globals.client.userImage != null) return Globals.client.userImage;

    try {
      Globals.client.userImage = NetworkImage(
        (await Globals.client.userDataRequest(
          mode: 'Jikan',
        ))['data']['images']['jpg']['image_url'],
      );
      return Globals.client.userImage;
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7.0),
        ),
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(7.0)),
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 15.0, vertical: 20.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(300.0),
                  child: FutureBuilder(
                    future: _getUserImage(),
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<dynamic> snapshot,
                    ) {
                      if (snapshot.hasData) {
                        return Image(
                          fit: BoxFit.cover,
                          image: snapshot.data,
                          height: 55.0,
                          width: 55.0,
                        );
                      } else {
                        return const SizedBox(
                          height: 55.0,
                          width: 55.0,
                          child: SpinKitCircle(
                            color: Colors.white,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.portrait,
                      color: Colors.white,
                    ),
                    Text(
                      Globals.client.username ?? 'Loading name...',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
