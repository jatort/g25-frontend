import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './User.dart';
import './Message.dart';
import './ChatModel.dart';

class ChatPage extends StatefulWidget {
  final ChatRoom chatroom;
  ChatPage(this.chatroom);
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController textEditingController = TextEditingController();
  String _message;
  String _username;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Widget buildSingleMessage(Message message) {
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

  Widget buildChatList() {
    return ScopedModelDescendant<ChatModel>(
      builder: (context, child, model) {
        List<Message> messages =
            model.getMessagesForChatID(widget.chatroom.name);

        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          child: ListView.builder(
            itemCount: messages.length,
            itemBuilder: (BuildContext context, int index) {
              return buildSingleMessage(messages[index]);
            },
          ),
        );
      },
    );
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
                        model.sendMessage(
                            _username, _message, widget.chatroom.name);
                        _formKey.currentState.reset();
                        //_submitMsg(_message, _username);
                      }),
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
                  model.sendMessage(_username, textEditingController.text,
                      widget.chatroom.chatID);
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
    return Scaffold(
      appBar: AppBar(
        title: Text("Nombre sala: ${widget.chatroom.name}"),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 6.0,
      ),
      body: ListView(
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
