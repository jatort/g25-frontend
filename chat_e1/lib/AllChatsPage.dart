import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import './ChatPage.dart';
import './ChatRoom.dart';
import './ChatModel.dart';
import 'ChatRoom.dart';

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

  List _roomsApi = [];
  Map currentUser;
  _AllChatsPageState(this.currentUser);
  String url_localhost = 'http://10.0.2.2:3000/api/v1/chats';
  String url_api_server = 'http://34.229.56.163:3000/api/v1/chats';
  String url_api_server_nuevo =
      'https://arqui-example.tk/api/v1/chats'; //USANDO
  String url_api_server_cache = 'https://arqui-e1-with-cache.tk/api/v1/chats';
  String url_api_server_auth = 'http://67.202.62.192:3000/api/v1/chats';

  Future _fetchRooms() async {
    final token = currentUser['data']['user']['auth_token'];
    String url = url_localhost;

    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-type": "application/x-www-form-urlencoded",
      HttpHeaders.authorizationHeader: "Bearer $token",
    };

    final response = await http.get(url, headers: headers);

    var convertDataToJson = json.decode(response.body);

    var roomsApi = convertDataToJson['data']['chats'];

    List rmsApi = [];

    if (roomsApi != null) {
      roomsApi.forEach(
          (room) => rmsApi.add(ChatRoom(room['title'], room['id'].toString())));
    }

    _roomsApi = rmsApi;

    return rmsApi;
  }

  @override
  void initState() {
    ScopedModel.of<ChatModel>(context, rebuildOnChange: false).init();
    super.initState();
  }

  void chatRoomClicked(ChatRoom chatroom) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return new ChatPage(chatroom, currentUser);
        },
      ),
    );
  }

  Widget buildAllChatList() {
    return ScopedModelDescendant<ChatModel>(
      builder: (context, child, model) {
        List<ChatRoom> chatroomsFromSocket = List.from(model.getChatRooms());

        List<ChatRoom> chatrooms = [];

        if (chatroomsFromSocket.length == 0) {
          _roomsApi.forEach((element) {
            chatrooms.add(element);
            model.chatRoomList.add(element);
          });
        }

        model.currentUser = currentUser['data']['user']['username'];

        chatroomsFromSocket.forEach((element) {
          chatrooms.add(element);
        });

        return Column(
          children: [
            Expanded(
              flex: 5,
              child: ListView.builder(
                itemCount: chatrooms.length,
                itemBuilder: (BuildContext context, int index) {
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
    return FutureBuilder(
      future: _fetchRooms(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('Loading...');
        }
        return Scaffold(
          appBar: AppBar(
            title: Text('All Chats'),
          ),
          body: buildAllChatList(),
        );
      },
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
                        model.sendRoom(nameChatController.text,
                            currentUser['data']['user']['auth_token']);
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
                    model.sendRoom(nameChatController.text,
                        currentUser['data']['user']['auth_token']);
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
