import 'package:flutter/material.dart';
import 'package:local_market/screens/consumer/index.dart';
import 'package:local_market/screens/enterprise/index.dart';
import 'package:provider/provider.dart';
import 'package:local_market/utils/api.dart';

class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  API api;
  TextEditingController emailField = TextEditingController();
  TextEditingController passwordField = TextEditingController();
  bool register = false;
  bool isEnterprise = false;
  bool snackbarLocked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    api = Provider.of<API>(context);
  }

  void handleAccess() async {
    FocusScope.of(context).unfocus();

    if (!snackbarLocked) {
      snackbarLocked = true;
      if (!register) {
        // Login
        var data = await api.authenticate(
            email: emailField.text, password: passwordField.text);

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
              duration: const Duration(seconds: 1),
              content: Text(data["message"]),
            ))
            .closed
            .then((reason) {
          snackbarLocked = false;
        });

        if (data["OK"]) {
          // Trigger redirect
          setState(() {});
        }
      } else {
        // Register
        var data = await api.register(
            email: emailField.text,
            password: passwordField.text,
            userType: isEnterprise ? 'e' : 'c');

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
              duration: const Duration(seconds: 1),
              content: Text(data["message"]),
            ))
            .closed
            .then((reason) {
          snackbarLocked = false;
        });

        if (data["OK"]) {
          // Trigger redirect
          setState(() {});
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIXME: Corrigir esse hack no futuro...
    if (api.currentUser != null) {
      var nextScreen;
      if (api.currentUser.userType == "c") {
        nextScreen = ConsumerScreen();
      } else if (api.currentUser.userType == "e") {
        nextScreen = EnterpriseScreen();
      }

      Future.delayed(Duration(milliseconds: 1), () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
          (Route<dynamic> route) => false,
        );
      });

      return Container(
        color: Colors.white,
      );
    }

    Widget logo = Flexible(
      flex: 3,
      child: Image.asset(
        "lib/assets/logo.png",
        width: 200,
      ),
    );
    Widget form = Flexible(
      flex: 2,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 5),
            child: TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(10),
                hintText: "Email",
              ),
              controller: emailField,
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 5),
            child: TextField(
              enableSuggestions: false,
              obscureText: true,
              autocorrect: false,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(10),
                hintText: "Senha",
              ),
              controller: passwordField,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Logar"),
              SizedBox(
                height: 30,
                child: Switch(
                  value: register,
                  onChanged: (newValue) {
                    setState(() {
                      register = newValue;
                    });
                  },
                ),
              ),
              Text("Cadastre-se"),
            ],
          ),
          (register)
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Usuário"),
                    SizedBox(
                      height: 30,
                      child: Switch(
                        value: isEnterprise,
                        onChanged: (newValue) {
                          setState(() {
                            isEnterprise = newValue;
                          });
                        },
                      ),
                    ),
                    Text("Empresa"),
                  ],
                )
              : Container(),
          Container(
            margin: EdgeInsets.only(top: 5),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: handleAccess,
                child: Text("ACESSAR", style: TextStyle(fontSize: 20)),
              ),
            ),
          )
        ],
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            logo,
            form,
          ],
        ),
      ),
    );
  }
}
