import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import './ChatPage.dart';
import './ChatRoom.dart';
import './ChatModel.dart';

class AllChatsPage extends StatefulWidget {
  final Map usuario;

  AllChatsPage(this.usuario);

  @override
  _AllChatsPageState createState() => _AllChatsPageState(usuario);
}

class _AllChatsPageState extends State<AllChatsPage> {
  String _newChatRoom;

  final nameChatController = TextEditingController(
    text: "",
  );

  List _rooms;

  Future<String> fetchRooms() async {

  final token = "2iO2NMu-Iw-QU0G_BwZZUg";
  String url = 'http://192.168.0.7:3000/api/v1/chats';

  Map<String, String> headers = {"Accept": "application/json", "Content-type": "application/x-www-form-urlencoded", HttpHeaders.authorizationHeader: "Bearer $token",};
  Map<String, dynamic> body = {"user[email]": "nmaturana7@uc.cl", "user[password]": "colegio", "user[username]": "nmaturana7", "user[password_confirmation]": "colegio"};
  //Map<String, dynamic> body = {"sign_in[email]": "Hello", "sign_in[password]": "body text"};
  //var json = {"sign_in[email]": "Hello", "sign_in[password]": "body text"};

  final response = await http.get(url,  headers: headers);

  setState((){
    var convertDataToJson = json.decode(response.body);
    print(convertDataToJson);
    _rooms = convertDataToJson['data']['chats'];
  });

  if (response.statusCode == 200) {
    return 'success';
  } else {
    throw Exception('Failed to load chat rooms');
  }
}


  Map currentUser;
  _AllChatsPageState(this.currentUser);

  @override
  void initState() {
    super.initState();
    ScopedModel.of<ChatModel>(context, rebuildOnChange: false).init();
    fetchRooms();
  }

  void chatRoomClicked(ChatRoom chatroom) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return ChatPage(chatroom);
        },
      ),
    );
  }

  Widget buildAllChatList() {
    return ScopedModelDescendant<ChatModel>(
      builder: (context, child, model) {
        if (_rooms != null){
          _rooms.forEach((room) => model.chatRoomList.add(ChatRoom(room['title'], room['id'].toString())));
        }

        List<ChatRoom> chatrooms = model.getChatRooms();
        
        return Column(
          children: [
            Expanded(
              flex: 5,
              child: ListView.builder(
                itemCount: chatrooms.length,
                itemBuilder: (BuildContext context, int index) {
                  // ChatRoom chatroom = model.chatRoomList[index];
                  return ListTile(
                    title: Text(chatrooms[index].name),
                    onTap: () => chatRoomClicked(chatrooms[index]),
                  );
                },
              ),
            ),
            Expanded(flex: 1, child: _buildNewChatroomForm()),
          ],
        );
      },
    );
  }

  Widget _buildRoomForm() {
    return TextFormField(
      decoration: InputDecoration(labelText: "Message"),
      // ignore: missing_return
      validator: (String value) {
        if (value.isEmpty) {
          return "Message is Required";
        }
      },
      onSaved: (String value) {
        _newChatRoom = value;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Chats'),
      ),
      body: buildAllChatList(),
    );
  }

  Widget _buildNewChatroomForm() {
    return ScopedModelDescendant<ChatModel>(builder: (context, child, model) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Row(
          children: <Widget>[
            Text("Chat Name:"),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: nameChatController,
                  onSubmitted: (text) {
                    setState(() {
                      if (nameChatController.text != "") {
                        model.sendRoom(
                            nameChatController.text, nameChatController.text);
                      }
                    });
                    nameChatController.clear();
                  },
                ),
              ),
            ),
            RaisedButton(
              child: new Text(
                "New Chat Room",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              color: Colors.green,
              onPressed: () {
                setState(() {
                  if (nameChatController.text != "") {
                    model.sendRoom(
                        nameChatController.text, nameChatController.text);
                  }
                });
                nameChatController.clear();
              },
            )
          ],
        ),
      );
    });
  }
}
