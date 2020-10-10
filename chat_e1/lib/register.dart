import 'dart:convert';

import 'package:chat_e1/AllChatsPage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

// ignore: must_be_immutable

class RegisterScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Register();
  }
}

class Register extends State<RegisterScreen> {
  String _username;
  String _email;
  String _password;
  String _confirmpassword;
  String _currentpassword;
  String messageNotice = "";
  Map<String, dynamic> data;
  String url_localhost = 'http://10.0.2.2:3000/api/v1/sign_up';
  String url_api_server = 'http://34.229.56.163:3000/api/v1/sign_up';
  String url_api_server_nuevo = 'http://3.91.230.50:3000/api/v1/sign_up';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    data = {};
  }

  Future _signUp(Map<String, String> datosUsuario) async {
    String url = url_api_server_nuevo;
    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-type": "application/x-www-form-urlencoded"
    };
    Map<String, dynamic> body = {
      "user[email]": datosUsuario['email'],
      "user[password]": datosUsuario['password'],
      "user[username]": datosUsuario['username'],
      "user[password_confirmation]": datosUsuario['password_confirmation']
    };
    // make POST request
    Response response = await post(url,
        headers: headers, body: body, encoding: Encoding.getByName("utf-8"));

    var respuesta = json.decode(response.body);
    if (response.statusCode == 200) {
      return respuesta;
    } else {
      return respuesta;
    }
  }

  Widget _buildUsername() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Nombre de Usuario"),

      // ignore: missing_return
      validator: (String value) {
        if (value.isEmpty) {
          return "Nombre de Usuario es requerido";
        }
      },
      onSaved: (String value) {
        _username = value;
      },
    );
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
        } else {
          _currentpassword = value;
        }
      },
      onSaved: (String value) {
        _password = value;
      },
    );
  }

  Widget _buildConfirmPassword() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Confirmar contraseña"),
      keyboardType: TextInputType.visiblePassword,
      obscureText: true,
      // ignore: missing_return
      validator: (String value) {
        if (value.isEmpty) {
          return "Contraseña es requerida";
        }

        if (value != _currentpassword) {
          return "Debe ser igual a la contraseña";
        }
      },
      onSaved: (String value) {
        _confirmpassword = value;
      },
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen[700],
        title: Text("Registro Usuario"),
      ),
      body: Container(
        margin: EdgeInsets.all(40),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildUsername(),
              _buildEmail(),
              _buildPassword(),
              _buildConfirmPassword(),
              SizedBox(height: 50),
              RaisedButton(
                child: Text(
                  "Registrarse",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
                onPressed: () async {
                  if (!_formKey.currentState.validate()) {
                    return;
                  }

                  _formKey.currentState.save();
                  Map<String, String> datosUsuario = {
                    "email": _email,
                    "password": _password,
                    "username": _username,
                    "password_confirmation": _confirmpassword
                  };

                  var respuestaUsuario = await _signUp(datosUsuario);

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
                      messageNotice = "Ocurrio un error al guardar el usuario";
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
