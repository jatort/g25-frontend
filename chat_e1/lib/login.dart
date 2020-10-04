import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return Login();
  }
}

class Login extends State<LoginScreen> {
  String _username;
  String _password;

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
              _buildUsername(),
              _buildPassword(),
              SizedBox(height: 100),
              RaisedButton(
                child: Text(
                  "Entrar",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
                onPressed: () {
                  if (!_formKey.currentState.validate()) {
                    return;
                  }

                  _formKey.currentState.save();

                  print(_username);
                  print(_password);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
