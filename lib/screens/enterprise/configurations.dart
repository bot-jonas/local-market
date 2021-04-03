import 'package:flutter/material.dart';
import 'package:local_market/screens/authentication/index.dart';
import 'package:provider/provider.dart';
import 'package:local_market/utils/authentication.dart';

class EnterpriseConfigurationsScreen extends StatefulWidget {
  @override
  _EnterpriseConfigurationsScreenState createState() =>
      _EnterpriseConfigurationsScreenState();
}

class _EnterpriseConfigurationsScreenState
    extends State<EnterpriseConfigurationsScreen> {
  Authentication auth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    auth = Provider.of<Authentication>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações Empresa"),
      ),
      body: Container(),
    );
  }
}
