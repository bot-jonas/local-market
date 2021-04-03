import 'package:flutter/material.dart';
import 'package:local_market/screens/authentication/index.dart';
import 'package:provider/provider.dart';
import 'package:local_market/utils/authentication.dart';

class EnterpriseScreen extends StatefulWidget {
  @override
  _EnterpriseScreenState createState() => _EnterpriseScreenState();
}

class _EnterpriseScreenState extends State<EnterpriseScreen> {
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
        title: Text("Empresa"),
      ),
      body: Center(
        child: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            auth.logout();

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AuthenticationScreen()),
            );
          },
        ),
      ),
    );
  }
}
