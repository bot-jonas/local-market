import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as HTTP;

class User {
  String email;
  String userType;
  String name;
  String cAddress;
  String eCategory;
  int eDeliveryTime;
  double eDeliveryFee;

  List products = [];
  List cart = [];

  double get total {
    double t = 0;
    for (var c in cart) {
      t += c["quantity"] * double.parse(c["price"]);
    }

    return t;
  }

  double get deliveryFee {
    var enterprises = {};

    double t = 0;
    for (var c in cart) {
      if (enterprises[c["enterprise"]["email"]] == null) {
        enterprises[c["enterprise"]["email"]] = 1;

        t += double.parse(c["enterprise"]["e_delivery_fee"]);
      }
    }

    return t;
  }

  double get totalWithDeliveryFee {
    var enterprises = {};

    double t = 0;
    for (var c in cart) {
      t += c["quantity"] * double.parse(c["price"]);

      if (enterprises[c["enterprise"]["email"]] == null) {
        enterprises[c["enterprise"]["email"]] = 1;

        t += double.parse(c["enterprise"]["e_delivery_fee"]);
      }
    }

    return t;
  }

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

  Future<Map<String, dynamic>> getProducts() async {
    String url = "https://jonasalves.cf/apis/local_market/get_products";

    Map<String, String> headers = {"Authorization": "Bearer $jwt"};
    HTTP.Response r = await HTTP.get(Uri.parse(url), headers: headers);

    if (r.statusCode == 401) {
      logout();

      return {"OK": false, "message": "Sessão expirada!"};
    } else {
      Map<String, dynamic> data = jsonDecode(utf8.decode(r.bodyBytes));

      if (data["OK"]) {
        currentUser.products = data["products"];
      }

      return data;
    }
  }

  Future<Map<String, dynamic>> registerProduct(
      {name, description, price, image}) async {
    String url = "https://jonasalves.cf/apis/local_market/register_product";
    Map<String, String> headers = {"Authorization": "Bearer $jwt"};
    Map<String, dynamic> body = {
      "name": name,
      "description": description,
      "price": price,
      "image": image
    };

    HTTP.Response r =
        await HTTP.post(Uri.parse(url), headers: headers, body: body);

    if (r.statusCode == 401) {
      logout();

      return {"OK": false, "message": "Sessão expirada!"};
    } else {
      Map<String, dynamic> data = jsonDecode(utf8.decode(r.bodyBytes));

      if (data["OK"]) {
        currentUser.products.insert(0, {
          "id": data["id"],
          "name": name,
          "image": image,
          "description": description,
          "price": (price == "") ? "0" : price
        });
      }

      return data;
    }
  }

  Future<Map<String, dynamic>> updateProduct(
      {id, name, image, description, price}) async {
    String url = "https://jonasalves.cf/apis/local_market/update_product";
    Map<String, String> headers = {"Authorization": "Bearer $jwt"};
    Map<String, dynamic> body = {
      "id": id,
      "name": name,
      "description": description,
      "image": image,
      "price": price
    };

    HTTP.Response r =
        await HTTP.post(Uri.parse(url), headers: headers, body: body);

    if (r.statusCode == 401) {
      logout();

      return {"OK": false, "message": "Sessão expirada!"};
    } else {
      Map<String, dynamic> data = jsonDecode(utf8.decode(r.bodyBytes));

      if (data["OK"]) {
        int idx = currentUser.products.indexWhere((p) => p["id"] == id);
        currentUser.products[idx] = {
          "id": id,
          "name": data["product"]["name"],
          "description": data["product"]["description"],
          "image": data["product"]["image"],
          "price": data["product"]["price"]
        };
      }

      return data;
    }
  }

  Future<Map<String, dynamic>> deleteProduct({id}) async {
    String url = "https://jonasalves.cf/apis/local_market/delete_product/$id";
    Map<String, String> headers = {"Authorization": "Bearer $jwt"};

    HTTP.Response r = await HTTP.delete(Uri.parse(url), headers: headers);

    if (r.statusCode == 401) {
      logout();

      return {"OK": false, "message": "Sessão expirada!"};
    } else {
      Map<String, dynamic> data = jsonDecode(utf8.decode(r.bodyBytes));

      if (data["OK"]) {
        currentUser.products.removeWhere((p) => p["id"] == id);
      }

      return data;
    }
  }

  Future<Map<String, dynamic>> search({q}) async {
    String url = "https://jonasalves.cf/apis/local_market/search?q=$q";
    Map<String, String> headers = {"Authorization": "Bearer $jwt"};

    HTTP.Response r = await HTTP.get(Uri.parse(url), headers: headers);

    if (r.statusCode == 401) {
      logout();

      return {"OK": false, "message": "Sessão expirada!"};
    } else {
      Map<String, dynamic> data = jsonDecode(utf8.decode(r.bodyBytes));

      return data;
    }
  }

  Future<Map<String, dynamic>> placeOrder({paymentMethod}) async {
    String url = "https://jonasalves.cf/apis/local_market/place_order";
    Map<String, String> headers = {
      "Authorization": "Bearer $jwt",
      'Content-Type': 'application/json; charset=UTF-8'
    };

    String body = jsonEncode({
      "cart": currentUser.cart,
      "payment_method": paymentMethod,
    });

    HTTP.Response r =
        await HTTP.post(Uri.parse(url), headers: headers, body: body);

    if (r.statusCode == 401) {
      logout();

      return {"OK": false, "message": "Sessão expirada!"};
    } else {
      Map<String, dynamic> data = jsonDecode(utf8.decode(r.bodyBytes));

      if (data["OK"]) {
        currentUser.cart = [];
      }

      return data;
    }
  }

  Future<Map<String, dynamic>> getConsumerOrders() async {
    String url = "https://jonasalves.cf/apis/local_market/get_orders/consumer";
    Map<String, String> headers = {"Authorization": "Bearer $jwt"};

    HTTP.Response r = await HTTP.get(Uri.parse(url), headers: headers);

    if (r.statusCode == 401) {
      logout();

      return {"OK": false, "message": "Sessão expirada!"};
    } else {
      Map<String, dynamic> data = jsonDecode(utf8.decode(r.bodyBytes));

      return data;
    }
  }

  Future<Map<String, dynamic>> getEnterpriseOrders() async {
    String url =
        "https://jonasalves.cf/apis/local_market/get_orders/enterprise";
    Map<String, String> headers = {"Authorization": "Bearer $jwt"};

    HTTP.Response r = await HTTP.get(Uri.parse(url), headers: headers);

    if (r.statusCode == 401) {
      logout();

      return {"OK": false, "message": "Sessão expirada!"};
    } else {
      Map<String, dynamic> data = jsonDecode(utf8.decode(r.bodyBytes));

      return data;
    }
  }

  Future<Map<String, dynamic>> cancelOrder({id}) async {
    String url = "https://jonasalves.cf/apis/local_market/update_order";
    Map<String, String> headers = {"Authorization": "Bearer $jwt"};
    Map<String, String> body = {"order_id": id, "status": "CANCELED"};

    HTTP.Response r =
        await HTTP.post(Uri.parse(url), headers: headers, body: body);

    if (r.statusCode == 401) {
      logout();

      return {"OK": false, "message": "Sessão expirada!"};
    } else {
      Map<String, dynamic> data = jsonDecode(utf8.decode(r.bodyBytes));

      return data;
    }
  }

  Future<Map<String, dynamic>> closeOrder({id}) async {
    String url = "https://jonasalves.cf/apis/local_market/update_order";
    Map<String, String> headers = {"Authorization": "Bearer $jwt"};
    Map<String, String> body = {"order_id": id, "status": "CLOSED"};

    HTTP.Response r =
        await HTTP.post(Uri.parse(url), headers: headers, body: body);

    if (r.statusCode == 401) {
      logout();

      return {"OK": false, "message": "Sessão expirada!"};
    } else {
      Map<String, dynamic> data = jsonDecode(utf8.decode(r.bodyBytes));

      return data;
    }
  }

  Future<Map<String, dynamic>> uploadImage({File image}) async {
    String url = "https://api.imgur.com/3/image";
    Map<String, String> headers = {
      "Authorization": "Client-ID 8f464ccaef4fabc"
    };

    var upload;

    try {
      List<int> bytes = await image.readAsBytes();
      String b64 = base64Encode(bytes);

      Map<String, String> body = {"image": b64};

      HTTP.Response r =
          await HTTP.post(Uri.parse(url), headers: headers, body: body);

      Map<String, dynamic> data = jsonDecode(utf8.decode(r.bodyBytes));

      upload = {
        "OK": true,
        "message": "Upload feito com sucesso!",
        "data": data["data"]
      };
    } catch (e) {
      upload = {"OK": false, "message": "Não foi possível fazer o upload"};
    }

    return upload;
  }
}
