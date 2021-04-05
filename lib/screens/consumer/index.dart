import 'package:flutter/material.dart';
import 'package:local_market/screens/authentication/index.dart';
import 'package:local_market/screens/consumer/configurations.dart';
import 'package:local_market/screens/consumer/placeOrder.dart';
import 'package:local_market/screens/consumer/search.dart';
import 'package:provider/provider.dart';
import 'package:local_market/utils/api.dart';

enum OptionsMenu { configurations, logout }

class ConsumerScreen extends StatefulWidget {
  @override
  _ConsumerScreenState createState() => _ConsumerScreenState();
}

class _ConsumerScreenState extends State<ConsumerScreen> {
  API api;
  int tabIndex = 0;

  var appBars = [];
  var bodies = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    api = Provider.of<API>(context);
  }

  void incrementCart(item) {
    int idx = api.currentUser.cart.indexWhere((p) => p["id"] == item.widget.id);

    setState(() {
      api.currentUser.cart[idx]["quantity"]++;
    });
  }

  void decrementCart(item) {
    int idx = api.currentUser.cart.indexWhere((p) => p["id"] == item.widget.id);

    setState(() {
      if (api.currentUser.cart[idx]["quantity"] == 1) {
        api.currentUser.cart.removeAt(idx);
      } else {
        api.currentUser.cart[idx]["quantity"]--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    appBars = [
      AppBar(
        title: Text("Usuário"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ConsumerSearchScreen()));
              },
              child: Icon(
                Icons.search,
                size: 26.0,
              ),
            ),
          ),
          PopupMenuButton<OptionsMenu>(
            onSelected: (value) {
              switch (value) {
                case OptionsMenu.configurations:
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ConsumerConfigurationsScreen()));
                  break;
                case OptionsMenu.logout:
                  api.logout();

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AuthenticationScreen()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => <PopupMenuItem<OptionsMenu>>[
              const PopupMenuItem<OptionsMenu>(
                value: OptionsMenu.configurations,
                child: Text("Configurações"),
              ),
              const PopupMenuItem<OptionsMenu>(
                value: OptionsMenu.logout,
                child: Text("Sair"),
              ),
            ],
          ),
        ],
      ),
      AppBar(
        title: Text("Carrinho"),
      ),
    ];

    bodies = [
      Center(
        child: Text("Adicionar lista de pedidos"),
      ),
      Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: ListView(
          children: [
            Column(
                children: api.currentUser.cart.map((r) {
              return new CartItem(
                id: r["id"],
                name: r["name"],
                description: r["description"],
                price: r["price"],
                image: "",
                enterprise: r["enterprise"],
                incrementCart: incrementCart,
                decrementCart: decrementCart,
                quantity: r["quantity"],
              );
            }).toList()),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Total: R\$ " + api.currentUser.total.toStringAsFixed(2),
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PlaceOrderScreen()));
                  },
                  child: Text("Finalizar compra"),
                )
              ],
            )
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: appBars[tabIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabIndex,
        onTap: (index) {
          setState(() {
            tabIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Carrinho"),
        ],
      ),
      body: bodies[tabIndex],
    );
  }
}

class CartItem extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final String price;
  final String image;
  final dynamic enterprise;
  final Function incrementCart;
  final Function decrementCart;
  final int quantity;

  CartItem({
    this.id,
    this.name,
    this.description,
    this.price,
    this.image,
    this.enterprise,
    this.incrementCart,
    this.decrementCart,
    this.quantity,
  });

  @override
  _CartItemState createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  @override
  Widget build(BuildContext context) {
    String nameFormatted = this.widget.name;
    String descriptionFormatted = this.widget.description;

    if (nameFormatted.length > 35) {
      nameFormatted = nameFormatted.substring(0, 35 - 3);
      nameFormatted += "...";
    }

    if (descriptionFormatted.length > 60) {
      descriptionFormatted = descriptionFormatted.substring(0, 60 - 3);
      descriptionFormatted += "...";
    }
    return Card(
      elevation: 2,
      child: Container(
        color: Colors.black12,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.white,
              child: (this.widget.image == "")
                  ? Image.asset(
                      "lib/assets/logo.png",
                      width: 100,
                      height: 120,
                      fit: BoxFit.contain,
                    )
                  : Image.network(
                      this.widget.image,
                      width: 100,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
            ),
            Expanded(
              child: Container(
                height: 120,
                margin: EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nameFormatted,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Text(descriptionFormatted),
                    Text("Empresa: " + this.widget.enterprise["name"]),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'R\$ ' +
                                (this.widget.quantity *
                                        double.parse(this.widget.price))
                                    .toStringAsFixed(2),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  this.widget.incrementCart(this);
                                },
                                child: Icon(
                                  Icons.add,
                                  size: 24.0,
                                  color: Colors.black,
                                ),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(horizontal: 5),
                                  child: Text(this.widget.quantity.toString())),
                              GestureDetector(
                                onTap: () {
                                  if (this.widget.quantity > 0) {
                                    this.widget.decrementCart(this);
                                  }
                                },
                                child: Icon(
                                  Icons.remove,
                                  size: 24.0,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ])
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
