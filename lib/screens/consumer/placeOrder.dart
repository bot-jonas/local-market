import 'package:flutter/material.dart';
import 'package:local_market/screens/authentication/index.dart';
import 'package:local_market/screens/consumer/index.dart';
import 'package:provider/provider.dart';
import 'package:local_market/utils/api.dart';

class PlaceOrderScreen extends StatefulWidget {
  @override
  _PlaceOrderScreenState createState() => _PlaceOrderScreenState();
}

class _PlaceOrderScreenState extends State<PlaceOrderScreen> {
  API api;
  bool snackbarLocked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    api = Provider.of<API>(context);
  }

  List<Widget> buildItems() {
    List<Widget> items = [];

    for (var c in api.currentUser.cart) {
      var quantity = c["quantity"];
      var name = c["name"];
      var price = c["price"];

      items.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text("${quantity}x $name"), Text("R\$ $price")],
      ));
    }

    var subtotal = api.currentUser.total.toStringAsFixed(2);

    items.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text("Subtotal"), Text("R\$ $subtotal")],
    ));

    return items;
  }

  List<Widget> buildFees() {
    List<Widget> items = [];

    var e = {};

    for (var c in api.currentUser.cart) {
      if (e[c["enterprise"]["email"]] == null) {
        e[c["enterprise"]["email"]] = 1;
        var name = c["enterprise"]["name"];
        var price = c["enterprise"]["e_delivery_fee"];

        items.add(Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text(name), Text("R\$ $price")],
        ));
      }
    }

    var subtotal = api.currentUser.deliveryFee.toStringAsFixed(2);

    items.add(Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [Text("Subtotal"), Text("R\$ $subtotal")],
    ));

    return items;
  }

  placeOrder({String paymentMethod}) async {
    snackbarLocked = false;

    if (!snackbarLocked) {
      snackbarLocked = true;

      var data = await api.placeOrder(paymentMethod: paymentMethod);

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
            duration: const Duration(seconds: 1),
            content: Text(data["message"]),
          ))
          .closed
          .then((reason) {
        snackbarLocked = false;
      });

      if (!data["OK"] && api.currentUser == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthenticationScreen()),
        );
      }

      if (data["OK"]) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConsumerScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Finalizar compra"),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: ListView(
          children: [
            Text("Itens",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Column(children: buildItems()),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text("Taxas de entrega",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            Column(
              children: buildFees(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text("R\$ " +
                      api.currentUser.totalWithDeliveryFee.toStringAsFixed(2))
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                    onPressed: () {
                      placeOrder(paymentMethod: "CASH");
                    },
                    child: Text("Pagar com dinheiro")),
                ElevatedButton(
                    onPressed: () {
                      placeOrder(paymentMethod: "CARD");
                    },
                    child: Text("Pagar com cartão"))
              ],
            )
          ],
        ),
      ),
    );
  }
}
