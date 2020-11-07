import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'AllChatsPage.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Login();
  }
}

class Login extends State<LoginScreen> {
  String _email;
  String _password;
  String messageNotice = "";
  Map<String, dynamic> data;
  String url_localhost = 'http://10.0.2.2:3000/api/v1/sign_in';
  String url_api_server = 'http://34.229.56.163:3000/api/v1/sign_in';
  String url_api_server_nuevo = 'https://arqui-example.tk/api/v1/sign_in';
  String url_api_server_cache = 'https://arqui-e1-with-cache.tk/api/v1/sign_in';
  String url_api_server_auth = 'http://67.202.62.192:3000/api/v1/sign_in';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    data = {};
  }

  Future _signIn(Map<String, String> datosUsuario) async {
    String url = url_localhost;

    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-type": "application/x-www-form-urlencoded"
    };
    Map<String, dynamic> body = {
      "sign_in[email]": datosUsuario['email'],
      "sign_in[password]": datosUsuario['password']
    };

    Response response = await post(url,
        headers: headers, body: body, encoding: Encoding.getByName("utf-8"));

    var respuesta = json.decode(response.body);

    if (response.statusCode == 200) {
      return respuesta;
    } else {
      return respuesta;
    }
  }

  Widget _buildEmail() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Email"),

      // ignore: missing_return
      validator: (String value) {
        if (value.isEmpty) {
          return "Email es requerido";
        }

        if (!RegExp(
                r"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?")
            .hasMatch(value)) {
          return "Por favor ingrese un Email válido";
        }

        return null;
      },
      onSaved: (String value) {
        _email = value;
      },
    );
  }

  Widget _buildPassword() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Contraseña"),
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      // ignore: missing_return
      validator: (String value) {
        if (value.isEmpty) {
          return "Contraseña es requerida";
        }
      },
      onSaved: (String value) {
        _password = value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[400],
        title: Text("Entra con tu Cuenta de Usuario"),
      ),
      body: Container(
        margin: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildEmail(),
              _buildPassword(),
              SizedBox(height: 50),
              RaisedButton(
                child: Text(
                  "Entrar",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
                onPressed: () async {
                  if (!_formKey.currentState.validate()) {
                    return;
                  }

                  _formKey.currentState.save();

                  Map<String, String> datosUsuario = {
                    "email": _email,
                    "password": _password
                  };

                  var respuestaUsuario = await _signIn(datosUsuario);

                  _formKey.currentState.reset();

                  if (respuestaUsuario['is_success']) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) {
                          return AllChatsPage(respuestaUsuario);
                        },
                      ),
                    );
                  } else {
                    setState(() {
                      messageNotice = "Este usuario no existe";
                    });
                  }
                },
              ),
              SizedBox(
                height: 15,
              ),
              Text(messageNotice),
            ],
          ),
        ),
      ),
    );
  }
}
