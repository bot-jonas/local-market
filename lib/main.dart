import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:local_market/utils/api.dart';
import 'package:local_market/screens/authentication/index.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider<API>(
      create: (_) => API.instance,
      child: MaterialApp(
        title: 'Local Market',
        home: AuthenticationScreen(),
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
