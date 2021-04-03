import 'package:flutter/material.dart';
import 'package:local_market/screens/authentication/index.dart';
import 'package:local_market/screens/enterprise/configurations.dart';
import 'package:provider/provider.dart';
import 'package:local_market/utils/api.dart';

enum OptionsMenu { configurations, logout }

class EnterpriseScreen extends StatefulWidget {
  @override
  _EnterpriseScreenState createState() => _EnterpriseScreenState();
}

class _EnterpriseScreenState extends State<EnterpriseScreen> {
  API api;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    api = Provider.of<API>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Empresa"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () {},
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
                              EnterpriseConfigurationsScreen()));
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
      body: Container(),
    );
  }
}
