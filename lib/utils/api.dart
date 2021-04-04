import 'dart:convert';
import 'package:http/http.dart' as HTTP;

class User {
  String email;
  String userType;
  String name;
  String cAddress;
  String eCategory;
  int eDeliveryTime;
  double eDeliveryFee;

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
        name = json['name'],
        userType = json['user_type'],
        cAddress = json['c_address'],
        eCategory = json['e_category'],
        eDeliveryFee = double.parse(json['e_delivery_fee']),
        eDeliveryTime = int.parse(json['e_delivery_time']);
}

class API {
  static final API instance = API._internal();

  factory API() {
    // create current user from Shared Prefs
    return instance;
  }

  API._internal();

  User currentUser;
  String jwt;

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
      jwt = data["jwt"];
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
      jwt = data["jwt"];
    }

    return data;
  }

  void logout() {
    currentUser = null;
    jwt = null;
  }

  Future<Map<String, dynamic>> updateConsumer({name, address}) async {
    String url = "https://jonasalves.cf/apis/local_market/update_user";
    Map<String, String> headers = {"Authorization": "Bearer $jwt"};
    Map<String, dynamic> body = {"name": name, "c_address": address};

    HTTP.Response r =
        await HTTP.post(Uri.parse(url), headers: headers, body: body);

    if (r.statusCode == 401) {
      logout();

      return {"OK": false, "message": "Sessão expirada!"};
    } else {
      Map<String, dynamic> data = jsonDecode(utf8.decode(r.bodyBytes));

      if (data["OK"]) {
        currentUser = User.fromJson(data["user"]);
      }

      return data;
    }
  }

  Future<Map<String, dynamic>> updateEnterprise(
      {name, category, deliveryTime, deliveryFee}) async {
    String url = "https://jonasalves.cf/apis/local_market/update_user";
    Map<String, String> headers = {"Authorization": "Bearer $jwt"};
    Map<String, dynamic> body = {
      "name": name,
      "e_category": category,
      "e_delivery_time": deliveryTime,
      "e_delivery_fee": deliveryFee
    };

    HTTP.Response r =
        await HTTP.post(Uri.parse(url), headers: headers, body: body);

    if (r.statusCode == 401) {
      logout();

      return {"OK": false, "message": "Sessão expirada!"};
    } else {
      Map<String, dynamic> data = jsonDecode(utf8.decode(r.bodyBytes));

      if (data["OK"]) {
        currentUser = User.fromJson(data["user"]);
      }

      return data;
    }
  }
}
