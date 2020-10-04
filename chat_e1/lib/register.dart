import 'package:flutter/material.dart';

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

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
        margin: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildUsername(),
              _buildEmail(),
              _buildPassword(),
              _buildConfirmPassword(),
              SizedBox(height: 100),
              RaisedButton(
                child: Text(
                  "Registrarse",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
                onPressed: () {
                  if (!_formKey.currentState.validate()) {
                    return;
                  }

                  _formKey.currentState.save();

                  print(_username);
                  print(_email);
                  print(_password);
                  print(_confirmpassword);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
