import 'package:flutter/material.dart';
import 'package:miru/services/mal_client.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'package:miru/pages/mal_web_view.dart';

class LoginRequest {
  String clientID;
  String codeChallenge;

  LoginRequest({this.clientID, this.codeChallenge});

  String createRequest(MALClient client) {
    // TODO: Open this string in browser
    String url =
        "https://myanimelist.net/v1/oauth2/authorize?response_type=code&client_id=$clientID&code_challenge=$codeChallenge";
    //TODO: Push webview for user to accept
    //TODO: Get url after it changes by checking the request with webviewcontroller
    //TODO: Use Uri to get the code parameter from the url then get token from generateToken()
    return url;
  }

  Future<void> generateToken(MALClient client, String code) async {
    String url = "https://myanimelist.net/v1/oauth2/token";
    Map<String, String> data = {
      "client_id": clientID,
      "code": code,
      "code_verifier": this.codeChallenge,
      "grant_type": "authorization_code"
    };
    Response response = await client.userClient.post(url, body: data);
    Map responseMap = json.decode(response.body);
    print(response.statusCode);
    print(responseMap);
  }

  void print_user_info(MALClient client) async {
    String url = 'https://api.myanimelist.net/v2/users/@me';
    Response response = await client.userClient.get(url, headers: {
      "Authorization":
          "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImp0aSI6ImI3NjM4NGE5Njk3Y2ZlNzQ5NTFkNzM0MGE0NjM2M2YzN2Q4ZWNmMzFiYmJiNjgyYWIxZTU4Nzc2YTQ3ZmY5ZGVhMmVmOWRmOTZjYTYxNGFmIn0.eyJhdWQiOiJiNmNkMWM2ZTMxNzJhZGUxMTQyMjcyZDRjMjg4YmRmMiIsImp0aSI6ImI3NjM4NGE5Njk3Y2ZlNzQ5NTFkNzM0MGE0NjM2M2YzN2Q4ZWNmMzFiYmJiNjgyYWIxZTU4Nzc2YTQ3ZmY5ZGVhMmVmOWRmOTZjYTYxNGFmIiwiaWF0IjoxNjEzNzI2Njc0LCJuYmYiOjE2MTM3MjY2NzQsImV4cCI6MTYxNjE0MjI3NCwic3ViIjoiMTE4MzY5OTkiLCJzY29wZXMiOltdfQ.jtAaIzjik1kdXd60YssJ9-9G4S-Ce9X1zXaM2P1HiZYAnyRUYEqrARp3N6M5qWJodaUebZZcTy8t7vysATeMC6P6aAl8REqN6IpyfnIxkS66DrEwPqMnzNMGpBUlwp9RwU-cTju73i1RxfkRlx1rZMSg_SONAnRGUbhPmDSIbwFYHQlBmHUzXAqisBIDiV5iiTVz8M4pdsEhNj-x_jV2cLcCO_J4tEPrhS8TKyLPa87x011KLMAg2UWYQ17JU9lrta2aauMWu501hdsSpT2p-Bu4fuEFTOU-n19WZdMJjpyLW1eNEO9jqOrolnl0qAD-eDINsNTyI1m0m3QEoT343Q, refresh_token: def5020049a78c3173fbb1c44cad8ce5ee27a00192c9f147fdfd5c8196422704844c862ea60c911362a2480a79910201edb52f936fef52ca6b4ef6bcf730b378ab8ca6a1c7bdca26cf66df18a0248cc41ba87ee37"
    });
    Map respMap = json.decode(response.body);
    print("User name is ${respMap["name"]}");
  }
}
