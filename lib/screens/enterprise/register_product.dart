import 'package:flutter/material.dart';
import 'package:local_market/screens/authentication/index.dart';
import 'package:provider/provider.dart';
import 'package:local_market/utils/api.dart';

class ProductRegisterScreen extends StatefulWidget {
  @override
  _ProductRegisterScreenState createState() => _ProductRegisterScreenState();
}

class _ProductRegisterScreenState extends State<ProductRegisterScreen> {
  API api;
  TextEditingController nameField = new TextEditingController();
  TextEditingController descriptionField = new TextEditingController();
  TextEditingController priceField = new TextEditingController();

  bool snackbarLocked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    api = Provider.of<API>(context);
  }

  void handleSave() async {
    FocusScope.of(context).unfocus();

    if (!snackbarLocked) {
      snackbarLocked = true;

      var data = await api.registerProduct(
        name: nameField.text,
        description: descriptionField.text,
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AuthenticationScreen()),
        );
      } else {
        nameField.text = "";
        descriptionField.text = "";
        priceField.text = "";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget form = Column(
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
              controller: descriptionField),
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
              controller: priceField),
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
      appBar: AppBar(
        title: Text("Registrar produto"),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        width: double.infinity,
        child: Column(
          children: [form],
        ),
      ),
    );
  }
}
