import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import './ChatPage.dart';
import './ChatRoom.dart';
import './ChatModel.dart';

class AllChatsPage extends StatefulWidget {
  @override
  _AllChatsPageState createState() => _AllChatsPageState();
}

class _AllChatsPageState extends State<AllChatsPage> {
  String _newChatRoom;

  final nameChatController = TextEditingController(
    text: "",
  );
  @override
  void initState() {
    super.initState();
    ScopedModel.of<ChatModel>(context, rebuildOnChange: false).init();
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
