import 'dart:convert';
import 'package:http/http.dart' as HTTP;

class User {
  String email;
  String userType;
  String name;
  String cAddress;
  String eCategory;
  int eDeliveryTime;
  int eDeliveryFee;

  User(
    this.email,
    this.userType, {
    this.name,
    this.cAddress,
    this.eCategory,
    this.eDeliveryFee,
    this.eDeliveryTime,
  });

  User.fromJson(Map<String, dynamic> json)
      : email = json['email'],
        userType = json['user_type'],
        cAddress = json['c_address'],
        eCategory = json['e_category'],
        eDeliveryFee = json['e_delivery_fee'],
        eDeliveryTime = json['e_delivery_time'];
}

class Authentication {
  static final Authentication instance = Authentication._internal();

  factory Authentication() {
    // create current user from Shared Prefs
    return instance;
  }

  Authentication._internal();

  User currentUser;

  Future<Map<String, dynamic>> register({email, password, userType}) async {
    String url =
        "https://jonasalves.cf/apis/local_market/authentication/register";
    Map<String, dynamic> body = {
      "email": email,
      "password": password,
      "user_type": userType
    };

    HTTP.Response r = await HTTP.post(Uri.parse(url), body: body);
    Map<String, dynamic> data = jsonDecode(utf8.decode(r.bodyBytes));

    if (data["OK"]) {
      currentUser = User.fromJson(data["user"]);
    }

    return data;
  }

  Future<Map<String, dynamic>> authenticate({email, password}) async {
    String url =
        "https://jonasalves.cf/apis/local_market/authentication/authenticate";
    Map<String, dynamic> body = {"email": email, "password": password};

    HTTP.Response r = await HTTP.post(Uri.parse(url), body: body);
    Map<String, dynamic> data = jsonDecode(utf8.decode(r.bodyBytes));

    if (data["OK"]) {
      currentUser = User.fromJson(data["user"]);
    }

    return data;
  }

  void logout() {
    currentUser = null;
  }

  Future<Map<String, dynamic>> postMethod() async {
    String url;
    Map<String, dynamic> headers = {};
    Map<String, dynamic> body = {};

    HTTP.Response r =
        await HTTP.post(Uri.parse(url), headers: headers, body: body);
    Map<String, dynamic> data = jsonDecode(utf8.decode(r.bodyBytes));

    return data;
  }

  Future<Map<String, dynamic>> getMethod() async {
    String url;
    Map<String, dynamic> headers = {};

    HTTP.Response r = await HTTP.get(Uri.parse(url), headers: headers);
    Map<String, dynamic> data = jsonDecode(utf8.decode(r.bodyBytes));

    return data;
  }
}
