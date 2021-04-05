import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:local_market/screens/authentication/index.dart';
import 'package:local_market/screens/consumer/configurations.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    api = Provider.of<API>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
      body: Center(
        child: Text("Adicionar lista de pedidos, e tela do carrinho"),
      ),
    );
  }
}
