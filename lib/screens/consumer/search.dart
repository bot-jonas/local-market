import 'package:flutter/material.dart';
import 'package:local_market/screens/consumer/placeOrder.dart';
import 'package:local_market/utils/api.dart';
import 'package:provider/provider.dart';

class ConsumerSearchScreen extends StatefulWidget {
  @override
  _ConsumerSearchScreenState createState() => _ConsumerSearchScreenState();
}

class _ConsumerSearchScreenState extends State<ConsumerSearchScreen> {
  API api;
  TextEditingController searchController = new TextEditingController();
  List results = [];
  bool snackbarLocked = false;
  int tabIndex = 0;

  var appBars = [];
  var bodies = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    api = Provider.of<API>(context);
  }

  @override
  void initState() {
    super.initState();
  }

  handleSearch() async {
    FocusScope.of(context).unfocus();

    if (!snackbarLocked) {
      snackbarLocked = true;

      var data = await api.search(q: searchController.text);

      if (!data["OK"]) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
              duration: const Duration(seconds: 1),
              content: Text(data["message"]),
            ))
            .closed
            .then((reason) {
          snackbarLocked = false;
        });
      } else {
        setState(() {
          results = data["results"];
          snackbarLocked = false;
        });
      }
    }

    return true;
  }

  void addToCart(item) {
    api.currentUser.cart.add({
      "id": item.widget.id,
      "name": item.widget.name,
      "description": item.widget.description,
      "price": item.widget.price,
      "image": item.widget.image,
      "enterprise_id": item.widget.enterpriseId,
      "quantity": 1
    });

    setState(() {
      item.selected = !item.selected;
    });
  }

  void removeFromCart(item) {
    api.currentUser.cart.removeWhere((p) => p["id"] == item.widget.id);

    setState(() {
      item.selected = !item.selected;
    });
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
      new AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Pesquisar",
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await handleSearch();
            },
            icon: Icon(
              Icons.search,
            ),
          )
        ],
      ),
      new AppBar(
        title: Text("Carrinho"),
      )
    ];
    bodies = [
      new Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: ListView(
          children: results.map((r) {
            return Result(
              id: r["id"],
              name: r["name"],
              description: r["description"],
              price: r["price"],
              image: "",
              enterpriseId: r["enterprise_id"],
              addToCart: addToCart,
              removeFromCart: removeFromCart,
              initialSelected:
                  (api.currentUser.cart.indexWhere((p) => p["id"] == r["id"]) >
                      -1),
            );
          }).toList(),
        ),
      ),
      new Container(
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
                enterpriseId: r["enterprise_id"],
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
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Pesquisar"),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: "Carrinho"),
        ],
      ),
      body: bodies[tabIndex],
    );
  }
}

class Result extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final String price;
  final String image;
  final String enterpriseId;
  final Function addToCart;
  final Function removeFromCart;
  final bool initialSelected;

  Result(
      {this.id,
      this.name,
      this.description,
      this.price,
      this.image,
      this.enterpriseId,
      this.addToCart,
      this.removeFromCart,
      this.initialSelected});

  @override
  _ResultState createState() => _ResultState(selected: this.initialSelected);
}

class _ResultState extends State<Result> {
  bool selected = false;

  _ResultState({this.selected});

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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            nameFormatted,
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            var func = !selected
                                ? widget.addToCart
                                : widget.removeFromCart;

                            func(this);
                          },
                          child: Icon(
                            selected
                                ? Icons.remove_shopping_cart
                                : Icons.add_shopping_cart,
                            size: 24.0,
                            color: selected ? Colors.red : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    Text(descriptionFormatted),
                    Text(
                      'R\$ ' + this.widget.price.toString(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
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

class CartItem extends StatefulWidget {
  final String id;
  final String name;
  final String description;
  final String price;
  final String image;
  final String enterpriseId;
  final Function incrementCart;
  final Function decrementCart;
  final int quantity;

  CartItem({
    this.id,
    this.name,
    this.description,
    this.price,
    this.image,
    this.enterpriseId,
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
