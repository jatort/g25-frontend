/// https://github.com/tensor-programming/dart_flutter_chat_app
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class Chat extends StatefulWidget {
  final String room;

  Chat(this.room);

  @override
  State createState() => new ChatWindow(room);
}

class ChatWindow extends State<Chat> with TickerProviderStateMixin {
  final List<Msg> _messages = <Msg>[];

  String _message;
  String _username;
  final String _room;
  SocketIO socketIO;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ChatWindow(this._room);

  void initState() {
    //Creating the socket
    socketIO = SocketIOManager().createSocketIO(
      'https://fluchat.herokuapp.com/','/',
      query: 'ChatID=${_room}');
    //Call init before doing anything with socket
    socketIO.init();
    //Subscribe to an event to listen to
    socketIO.subscribe('receive_message', (jsonData) {
      //Convert the JSON data received into a Map
      Map<String, dynamic> data = json.decode(jsonData);
      _submitMsg(data['content'], data['senderChatID'], data['receiverChatID']);
    });
    //Connect to the socket
    socketIO.connect();
    super.initState();
  }

  // Widget Beno para username
  Widget _buildUsername() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Username"),
      // ignore: missing_return
      validator: (String value) {
        if (value.isEmpty) {
          return "Username is Required";
        }
      },
      onSaved: (String value) {
        _username = value;
      },
    );
  }

  // Widget Beno para Message
  Widget _buildMessage() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Message"),
      // ignore: missing_return
      validator: (String value) {
        if (value.isEmpty) {
          return "Message is Required";
        }
      },
      onSaved: (String value) {
        _message = value;
      },
    );
  }



  @override
    Widget build(BuildContext ctx) {
      return new Scaffold(
        appBar: new AppBar(
          title: new Text("Nombre Sala: ${_room}"),
          elevation: Theme.of(ctx).platform == TargetPlatform.iOS ? 0.0 : 6.0,
        ),
        body: new Column(children: <Widget>[
          new Flexible(
              child: new ListView.builder(
                itemBuilder: (_, int index) => _messages[index],
                itemCount: _messages.length,
                reverse: true,
                padding: new EdgeInsets.all(6.0),
              )),
          new Divider(height: 1.0),
          new Container(
            child: _buildComposer(),
            decoration: new BoxDecoration(color: Colors.white),
          ),
        ]),
      );
  }

  Widget _buildComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 9.0),
          child: Column(
            children: <Widget>[
              // FORM PARA ENVIAR MENSAJE

              new Container(
                margin: EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildUsername(),
                      _buildMessage(),
                    ],
                  ),
                ),
              ),

              //BOTON SUBMIT MENSAJE
              RaisedButton(
                  child: Text(
                    "Enviar",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () {
                    if (!_formKey.currentState.validate()) {
                      return;
                    }
                    _formKey.currentState.save();

                    _submitMsg(_message, _username, _room);
                    socketIO.sendMessage(
                      'send_message',
                      json.encode({
                        'receiverChatID': _room,
                        'senderChatID': _username,
                        'content': _message,
                      }),
                    );
                    _formKey.currentState.reset();
                    //_submitMsg(_message, _username);
                  }),
            ],
          ),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
                  border: new Border(top: new BorderSide(color: Colors.red)))
              : null),
    );
  }

  void _submitMsg(String txt, String username, String chatroomname) {
    Msg msg = new Msg(
      txt: txt,
      chatroomname: chatroomname,
      username: username,
      animationController: new AnimationController(
          vsync: this, duration: new Duration(milliseconds: 800)),
    );
    setState(() {
      _messages.insert(0, msg);
    });
    msg.animationController.forward();
  }

  @override
  void dispose() {
    for (Msg msg in _messages) {
      msg.animationController.dispose();
    }
    super.dispose();
  }
}

class Msg extends StatelessWidget {
  Msg({this.txt, this.username, this.animationController, this.chatroomname});
  final String txt;
  final String username;
  final String chatroomname;
  final AnimationController animationController;
  @override
  Widget build(BuildContext ctx) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
          parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(margin: const EdgeInsets.only(right: 18.0)),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text('${this.username}:   [${new DateTime.now()}]',
                      style: Theme.of(ctx).textTheme.subtitle1),
                  new Container(
                    margin: const EdgeInsets.only(top: 6.0),
                    child: new Text(txt),
                  ),
                ],
              ),
            ),
          ],
        ),
        color: Colors.indigo[100],
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 0,
        ),
      ),
    );
  }
}
