import 'package:flutter/material.dart';
import 'package:local_market/screens/authentication/index.dart';
import 'package:provider/provider.dart';
import 'package:local_market/utils/authentication.dart';

class ConsumerConfigurationsScreen extends StatefulWidget {
  @override
  _ConsumerConfigurationsScreenState createState() =>
      _ConsumerConfigurationsScreenState();
}

class _ConsumerConfigurationsScreenState
    extends State<ConsumerConfigurationsScreen> {
  API auth;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    auth = Provider.of<API>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Configurações Usuário"),
      ),
      body: Container(),
    );
  }
}
