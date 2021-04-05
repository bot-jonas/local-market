import 'package:flutter/material.dart';
import 'package:local_market/screens/authentication/index.dart';
import 'package:provider/provider.dart';
import 'package:local_market/utils/api.dart';

class ConsumerConfigurationsScreen extends StatefulWidget {
  @override
  _ConsumerConfigurationsScreenState createState() =>
      _ConsumerConfigurationsScreenState();
}

class _ConsumerConfigurationsScreenState
    extends State<ConsumerConfigurationsScreen> {
  API api;
  TextEditingController nameField = new TextEditingController();
  TextEditingController addressField = new TextEditingController();
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

      var data = await api.updateConsumer(
          name: nameField.text, address: addressField.text);

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
        nameField.text = api.currentUser.name;
        addressField.text = api.currentUser.cAddress;
      }
    }
  }

  // FIXME: Change this widget to a stateless
  bool initialized = false;

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      nameField.text = api.currentUser.name;
      addressField.text = api.currentUser.cAddress;
      initialized = true;
    }

    Widget form = Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(10),
              hintText: "Nome",
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
                hintText: "Endereço completo",
              ),
              controller: addressField),
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
        title: Text("Configurações Usuário"),
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
