import 'package:flutter/material.dart';
import 'package:local_market/screens/authentication/index.dart';
import 'package:provider/provider.dart';
import 'package:local_market/utils/api.dart';

class ProductUpdateScreen extends StatefulWidget {
  final int id;
  final String name;
  final String description;
  final double price;
  final String image;

  ProductUpdateScreen(
      {this.id, this.name, this.description, this.price, this.image});

  @override
  _ProductUpdateScreenState createState() => _ProductUpdateScreenState();
}

class _ProductUpdateScreenState extends State<ProductUpdateScreen> {
  API api;
  TextEditingController nameField;
  TextEditingController descriptionField;
  TextEditingController priceField;

  bool snackbarLocked = false;

  @override
  void initState() {
    super.initState();

    nameField = new TextEditingController(text: this.widget.name);
    descriptionField = new TextEditingController(text: this.widget.description);
    priceField = new TextEditingController(
        text: (this.widget.price > 0) ? this.widget.price.toString() : "");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    api = Provider.of<API>(context);
  }

  void handleDelete() async {
    FocusScope.of(context).unfocus();

    if (!snackbarLocked) {
      snackbarLocked = true;

      var data = await api.deleteProduct(id: this.widget.id.toString());

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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AuthenticationScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        Navigator.pop(context);
      }
    }
  }

  void handleSave() async {
    FocusScope.of(context).unfocus();

    if (!snackbarLocked) {
      snackbarLocked = true;

      var data = await api.updateProduct(
        id: this.widget.id.toString(),
        name: nameField.text,
        description: descriptionField.text,
        image: "",
        price: priceField.text,
      );

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
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AuthenticationScreen()),
          (Route<dynamic> route) => false,
        );
      } else if (!data["OK"]) {
        api.currentUser.products
            .removeWhere((p) => p["id"] == this.widget.id.toString());
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var form = Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(10),
              hintText: "Nome produto",
            ),
            controller: nameField,
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(10),
              hintText: "Descrição",
            ),
            controller: descriptionField,
          ),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(10),
              hintText: "Preço",
            ),
            controller: priceField,
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 5),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: handleSave,
              child: Text("SALVAR",
                  style: TextStyle(fontSize: 14, color: Colors.white)),
            ),
          ),
        )
      ],
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Editar produto"),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Excluir produto",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  // ignore: deprecated_member_use
                  RaisedButton(
                    onPressed: handleDelete,
                    child: Text(
                      "Excluir",
                      style: TextStyle(color: Colors.white),
                    ),
                    color: Colors.redAccent,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(
                "Atualizar produto",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            form,
          ],
        ),
      ),
    );
  }
}
