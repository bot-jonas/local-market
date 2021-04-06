import 'package:flutter/material.dart';
import 'package:local_market/screens/authentication/index.dart';
import 'package:local_market/screens/enterprise/register_product.dart';
import 'package:local_market/screens/enterprise/update_product.dart';
import 'package:provider/provider.dart';
import 'package:local_market/utils/api.dart';

class EnterpriseInventoryScreen extends StatefulWidget {
  @override
  _EnterpriseInventoryScreenState createState() =>
      _EnterpriseInventoryScreenState();
}

class _EnterpriseInventoryScreenState extends State<EnterpriseInventoryScreen> {
  API api;

  bool snackbarLocked = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    api = Provider.of<API>(context);
    snackbarLocked = true;
    api.getProducts().then((data) {
      if (api.currentUser == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
              duration: const Duration(seconds: 1),
              content: Text(data["message"]),
            ))
            .closed
            .then((reason) {
          snackbarLocked = false;
        });
        Future.delayed(Duration(milliseconds: 1), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => AuthenticationScreen()),
            (Route<dynamic> route) => false,
          );
        });
      } else {
        // Trigger to redraw
        Future.delayed(Duration(milliseconds: 1), () {
          setState(() {});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Inventário"), actions: [
        Padding(
          padding: EdgeInsets.only(right: 20.0),
          child: GestureDetector(
            onTap: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProductRegisterScreen()));
              setState(() {});
            },
            child: Icon(
              Icons.add,
              size: 24.0,
            ),
          ),
        ),
      ]),
      body: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                "Produtos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                  children: api.currentUser.products
                      .map(
                        (p) => InventoryItem(
                          id: int.parse(p["id"]),
                          name: p["name"],
                          description: p["description"],
                          price: double.parse(p["price"]),
                          image: p["image"],
                          iAmBack: () {
                            setState(() {});
                          },
                        ),
                      )
                      .toList()
                      .cast<InventoryItem>()),
            )
          ],
        ),
      ),
    );
  }
}

class InventoryItem extends StatefulWidget {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;
  final Function iAmBack;

  InventoryItem(
      {this.id,
      this.name,
      this.description,
      this.price,
      this.image,
      this.iAmBack});

  @override
  _InventoryItemState createState() => _InventoryItemState();
}

class _InventoryItemState extends State<InventoryItem> {
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
                          onTap: () async {
                            await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProductUpdateScreen(
                                          id: this.widget.id,
                                          name: this.widget.name,
                                          description: this.widget.description,
                                          price: this.widget.price,
                                          image: this.widget.image,
                                        )));
                            this.widget.iAmBack();
                          },
                          child: Icon(
                            Icons.edit,
                            size: 24.0,
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
