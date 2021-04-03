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

class API {
  static final API instance = API._internal();

  factory API() {
    // create current user from Shared Prefs
    return instance;
  }

  API._internal();

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
}
