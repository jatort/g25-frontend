import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

import './ChatPage.dart';
import './User.dart';
import './ChatModel.dart';

class AllChatsPage extends StatefulWidget {
  @override
  _AllChatsPageState createState() => _AllChatsPageState();
}

class _AllChatsPageState extends State<AllChatsPage> {
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
        return ListView.builder(
          itemCount: model.chatRoomList.length,
          itemBuilder: (BuildContext context, int index) {
            ChatRoom chatroom = model.chatRoomList[index];
            return ListTile(
              title: Text(chatroom.name),
              onTap: () => chatRoomClicked(chatroom),
            );
          },
        );
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
}