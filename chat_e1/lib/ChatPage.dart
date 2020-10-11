import 'dart:core';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_icons/flutter_icons.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import './User.dart';
import './Message.dart';
import './ChatModel.dart';
import 'Images.dart';

class ChatPage extends StatefulWidget {
  final ChatRoom chatroom;
  final Map currentUser;
  ChatPage(this.chatroom, this.currentUser);
  @override
  _ChatPageState createState() => _ChatPageState(chatroom, currentUser);
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController textEditingController = TextEditingController();
  String _message;
  ChatRoom chatroom;
  Map currentUser;

  _ChatPageState(this.chatroom, this.currentUser);

  //String _username;

  String url_localhost = 'http://10.0.2.2:3000/api/v1/chats';
  String url_api_server = 'http://34.229.56.163:3000/api/v1/chats';
  List _messagesApi = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _getMessagesFromApi().then((value) => {
          _messagesApi = value,
        });
    super.initState();
    
  }

  Future _getMessagesFromApi() async {
    String idChat = chatroom.chatID;
    String token = currentUser['data']['user']['auth_token'];
    //String url = "$url_api_server/$idChat";
    String url = 'http://192.168.1.87/api/v1/chats/$idChat';
    print(url);
    print(token);
    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-type": "application/x-www-form-urlencoded",
      HttpHeaders.authorizationHeader: "Bearer $token",
    };
    final response = await http.get(url, headers: headers);
    var convertDataToJson = json.decode(response.body);

    var messagesApi = convertDataToJson['data']['messages'];

    print(messagesApi);

    List msgApi = [];

    if (messagesApi != null) {
      messagesApi.forEach((mensaje) => msgApi.add(Message(mensaje['body'],
          mensaje['user_id'].toString(), mensaje['chat_id'].toString())));
    }
    print(msgApi);
    return msgApi;
  }

  //aqui movi la funcion del chatmodel para aca, convierte la lista de mensajes
  //a objetos Messages

  //Api obtiene los mensajes de la sala de chat

  Widget buildSingleMessage(Message message) {
    if (message.text.substring(0, 4) == 'http'){
      return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(margin: const EdgeInsets.only(right: 18.0)),
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text('${message.senderID}:   [${new DateTime.now()}]'),
                new Container(
                  margin: const EdgeInsets.only(top: 6.0),
                  child: new Image.network(message.text, width: 350,),
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
    );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(margin: const EdgeInsets.only(right: 18.0)),
          new Expanded(
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Text('${message.senderID}:   [${new DateTime.now()}]'),
                new Container(
                  margin: const EdgeInsets.only(top: 6.0),
                  child: new Text(message.text),
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
    );

    ///
    Container(
      alignment: message.senderID == widget.chatroom.chatID
          ? Alignment.centerLeft
          : Alignment.centerRight,
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.all(10.0),
      child: Text(message.text),
    );

    ///
  }

  // Widget Beno para username
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

  Widget buildChatList() {
    print('entrando a build....');
    print("_messageApi en el buildchatlist: $_messagesApi");
    //print(_messagesApi);
    return ScopedModelDescendant<ChatModel>(
      builder: (context, child, model) {
        List<Message> messagesFromSocket =
            model.getMessagesForChatID(widget.chatroom.chatID);

        _messagesApi.forEach((element) {
          messagesFromSocket.insert(0, element);
        });

        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          child: ListView.builder(
            itemCount: messagesFromSocket.length,
            itemBuilder: (BuildContext context, int index) {
              return buildSingleMessage(messagesFromSocket[index]);
            },
          ),
        );
      },
    );
  }
  var _result;
  _navigateUploadImage(BuildContext context) async {
    _result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Images()),
          );
    //print(_result);
    
  }
  Widget buildChatArea() {
    return ScopedModelDescendant<ChatModel>(
      builder: (context, child, model) {
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
                          _buildMessage(),
                        ],
                      ),
                    ),
                  ),

                  //BOTON SUBMIT MENSAJE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RaisedButton(
                          child: Icon(
                              MaterialIcons.add_a_photo,
                              size: 35,
                            ),
                          onPressed: () async{
                            await _navigateUploadImage(context);
                            // Se recorre la lista de imagenes y se envia un mensaje por cada url
                            if (_result != null){
                              String _username =
                                widget.currentUser['data']['user']['username'];
                              _result.forEach((image) => 
                              model.sendMessage(
                                _username,
                                image,
                                widget.chatroom.chatID,
                                widget.currentUser['data']['user']['auth_token'])
                              );
                            }                             
                          }),
                      new Spacer(),
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
                            String _username =
                                widget.currentUser['data']['user']['username'];
                            model.sendMessage(
                                _username,
                                _message,
                                widget.chatroom.chatID,
                                widget.currentUser['data']['user']['auth_token']);
                            _formKey.currentState.reset();
                            //_submitMsg(_message, _username);
                          }),
                    ],
                  ),
                ],
              ),
              decoration: Theme.of(context).platform == TargetPlatform.iOS
                  ? new BoxDecoration(
                      border:
                          new Border(top: new BorderSide(color: Colors.red)))
                  : null),
        );

        ///
        return Container(
          child: Row(
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextField(
                  controller: textEditingController,
                ),
              ),
              SizedBox(width: 10.0),
              FloatingActionButton(
                onPressed: () {
                  String _username =
                      widget.currentUser['data']['user']['username'];
                  model.sendMessage(
                      _username,
                      textEditingController.text,
                      widget.chatroom.chatID,
                      widget.currentUser['data']['user']['auth_token']);
                  textEditingController.text = '';
                },
                elevation: 0,
                child: Icon(Icons.send),
              ),
            ],
          ),
        );

        ///
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getMessagesFromApi(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Future hasn't finished yet, return a placeholder
          return Text('Loading');
        }
        return Scaffold(
          appBar: AppBar(
            title: Text("Nombre sala: ${widget.chatroom.name}"),
            elevation:
                Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 6.0,
          ),
          body: Column(
            children: <Widget>[
              buildChatList(),
              new Divider(height: 1.0),
              new Container(
                child: buildChatArea(),
                decoration: new BoxDecoration(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}

/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Nombre sala: ${widget.chatroom.name}"),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 6.0,
      ),
      body: Column(
        children: <Widget>[
          buildChatList(),
          new Divider(height: 1.0),
          new Container(
            child: buildChatArea(),
            decoration: new BoxDecoration(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
*/
