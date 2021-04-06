import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_market/screens/authentication/index.dart';
import 'package:provider/provider.dart';
import 'package:local_market/utils/api.dart';

class ProductRegisterScreen extends StatefulWidget {
  @override
  _ProductRegisterScreenState createState() => _ProductRegisterScreenState();
}

class _ProductRegisterScreenState extends State<ProductRegisterScreen> {
  API api;
  TextEditingController nameField = new TextEditingController();
  TextEditingController descriptionField = new TextEditingController();
  TextEditingController priceField = new TextEditingController();

  File _image;
  final picker = ImagePicker();
  bool uploading = false;

  bool snackbarLocked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    api = Provider.of<API>(context);
  }

  handleSave() async {
    FocusScope.of(context).unfocus();

    if (!snackbarLocked) {
      snackbarLocked = true;

      // handle upload first, if success then register ...
      String image = "";

      if (_image != null) {
        setState(() {
          uploading = true;
        });

        var upload = await api.uploadImage(image: _image);

        setState(() {
          uploading = false;
        });

        if (upload["OK"]) {
          image = upload["data"]["link"];
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
              duration: const Duration(seconds: 1),
              content: Text(upload["message"]),
            ))
            .closed
            .then((reason) {
          snackbarLocked = false;
        });
      }

      var data = await api.registerProduct(
        name: nameField.text,
        description: descriptionField.text,
        price: priceField.text,
        image: image,
      );

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
        nameField.text = "";
        descriptionField.text = "";
        priceField.text = "";

        setState(() {
          _image = null;
        });
      }
    }
  }

  int MAX_IMAGE_FILE_SIZE_MB = 20;

  getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File file = File(pickedFile.path);
      final len = await file.length();

      if (len < MAX_IMAGE_FILE_SIZE_MB * 1000 * 1000) {
        // 1000 instead of 1024 ...
        setState(() {
          _image = file;
        });
      } else {
        if (!snackbarLocked) {
          snackbarLocked = true;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(
                duration: const Duration(seconds: 1),
                content: Text(
                    "Imagens devem ser menores que ${MAX_IMAGE_FILE_SIZE_MB}MB"),
              ))
              .closed
              .then((reason) {
            snackbarLocked = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget form = Column(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child: TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.all(10),
              hintText: "Nome produto",
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
                hintText: "Descrição",
              ),
              controller: descriptionField),
        ),
        Container(
          margin: EdgeInsets.only(bottom: 5),
          child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(10),
                hintText: "Preço",
              ),
              controller: priceField),
        ),
        Container(
          width: double.infinity,
          margin: EdgeInsets.only(bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              (_image == null)
                  ? Text("Nenhuma imagem selecionada")
                  : Container(
                      color: Colors.black12,
                      child: Image.file(
                        _image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
              (_image == null)
                  ? Container()
                  : ((uploading)
                      ? Text("Uploading...")
                      : RaisedButton(
                          onPressed: () {
                            setState(() {
                              _image = null;
                            });
                          },
                          child: Text("Remover imagem"),
                        ))
            ],
          ),
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
        title: Text("Registrar produto"),
      ),
      body: Container(
        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
        width: double.infinity,
        child: Column(
          children: [form],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Selecionar imagem',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
