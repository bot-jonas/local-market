import 'package:flutter/material.dart';
import 'package:local_market/screens/authentication/index.dart';
import 'package:local_market/screens/enterprise/configurations.dart';
import 'package:local_market/screens/enterprise/inventory.dart';
import 'package:provider/provider.dart';
import 'package:local_market/utils/api.dart';

enum OptionsMenu { configurations, logout }

class EnterpriseScreen extends StatefulWidget {
  @override
  _EnterpriseScreenState createState() => _EnterpriseScreenState();
}

class _EnterpriseScreenState extends State<EnterpriseScreen> {
  API api;
  var orders = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    api = Provider.of<API>(context);
  }

  bool snackbarLocked = false;

  void handleCancel(id) async {
    if (!snackbarLocked) {
      snackbarLocked = true;

      var data = await api.cancelOrder(id: id);

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
        setState(() {
          initialized = false;
        });
      }
    }
  }

  void handleClose(id) async {
    if (!snackbarLocked) {
      snackbarLocked = true;

      var data = await api.closeOrder(id: id);

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
        setState(() {
          initialized = false;
        });
      }
    }
  }

  bool initialized = false;

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      api.getEnterpriseOrders().then((data) => {
            setState(() {
              orders = data["orders"];
            })
          });

      initialized = true;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("Empresa"),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EnterpriseInventoryScreen()));
              },
              child: Icon(
                Icons.inventory,
                size: 24.0,
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
      body: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: RefreshIndicator(
          onRefresh: () async {
            var data = await api.getEnterpriseOrders();
            setState(() {
              orders = data["orders"];
            });
          },
          child: ListView(
            children: [
              Text(
                "Meus pedidos",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Column(
                children: orders
                    .map((o) => OrderItem(
                          id: o["id"],
                          consumerName: o["consumerName"],
                          paymentMethod: o["paymentMethod"],
                          status: o["status"],
                          total: o["total"],
                          handleCancel: handleCancel,
                          handleClose: handleClose,
                        ))
                    .toList(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class OrderItem extends StatelessWidget {
  final String id;
  final String consumerName;
  final String total;
  final String paymentMethod;
  final String status;
  final Function handleCancel;
  final Function handleClose;

  OrderItem({
    this.id,
    this.consumerName,
    this.total,
    this.paymentMethod,
    this.status,
    this.handleCancel,
    this.handleClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Pedido #$id",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                (status == "ORDERED")
                    ? Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "Cancelar",
                                style: TextStyle(color: Colors.red),
                              ),
                              IconButton(
                                  onPressed: () {
                                    handleCancel(this.id);
                                  },
                                  icon: Icon(
                                    Icons.close,
                                    color: Colors.red,
                                  ))
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                "Aceitar",
                                style: TextStyle(color: Colors.green),
                              ),
                              IconButton(
                                  onPressed: () {
                                    handleClose(this.id);
                                  },
                                  icon: Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ))
                            ],
                          ),
                        ],
                      )
                    : Container()
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text("Consumidor: $consumerName"),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child:
                  Text("Valor: R\$ " + double.parse(total).toStringAsFixed(2)),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text("Método de pagamento: $paymentMethod"),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text("Status: $status"),
            ),
          ],
        ),
      ),
    );
  }
}
