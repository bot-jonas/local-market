import 'package:flutter/material.dart';
import 'package:local_market/screens/authentication/index.dart';
import 'package:provider/provider.dart';
import 'package:local_market/utils/api.dart';

class EnterpriseConfigurationsScreen extends StatefulWidget {
  @override
  _EnterpriseConfigurationsScreenState createState() =>
      _EnterpriseConfigurationsScreenState();
}

class _EnterpriseConfigurationsScreenState
    extends State<EnterpriseConfigurationsScreen> {
  API api;
  TextEditingController nameField = new TextEditingController();
  TextEditingController categoryField = new TextEditingController();
  TextEditingController deliveryTimeField = new TextEditingController();
  TextEditingController deliveryFeeField = new TextEditingController();

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

      var data = await api.updateEnterprise(
          name: nameField.text,
          category: categoryField.text,
          deliveryFee: deliveryFeeField.text,
          deliveryTime: deliveryTimeField.text);

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
        nameField.text = api.currentUser.name;
        categoryField.text = api.currentUser.eCategory;
        deliveryFeeField.text = api.currentUser.eDeliveryFee.toString();
        deliveryTimeField.text = api.currentUser.eDeliveryTime.toString();
      }
    }
  }

  // FIXME: Change this widget to a stateless
  bool initialized = false;

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      nameField.text = api.currentUser.name;
      categoryField.text = api.currentUser.eCategory;
      if (api.currentUser.eDeliveryFee > 0)
        deliveryFeeField.text = api.currentUser.eDeliveryFee.toString();
      if (api.currentUser.eDeliveryTime > 0)
        deliveryTimeField.text = api.currentUser.eDeliveryTime.toString();
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
              hintText: "Nome empresa",
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
                hintText: "Categoria",
              ),
              controller: categoryField),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(10),
                hintText: "Tempo entrega",
              ),
              controller: deliveryTimeField),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(10),
                hintText: "Taxa entrega",
              ),
              controller: deliveryFeeField),
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
        title: Text("Configurações Empresa"),
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
