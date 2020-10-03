import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'dart:convert';

import './User.dart';
import './Message.dart';

class ChatModel extends Model {
  List<ChatRoom> users = [
    ChatRoom('IronMan', '111'),
    ChatRoom('Captain America', '222'),
    ChatRoom('Antman', '333'),
    ChatRoom('Hulk', '444'),
    ChatRoom('Thor', '555'),
  ];

  ChatRoom currentUser;
  List<ChatRoom> friendList = List<ChatRoom>();
  List<Message> messages = List<Message>();
  SocketIO socketIO;

  void init() {
    currentUser = users[1];
    friendList =
        users.where((user) => user.chatID != currentUser.chatID).toList();

    socketIO = SocketIOManager().createSocketIO(
        'https://fluchat.herokuapp.com/', '/',
        query: 'chatID=${currentUser.chatID}');
    socketIO.init();

    socketIO.subscribe('receive_message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      messages.add(Message(
          data['content'], data['senderChatID'], data['receiverChatID']));
      notifyListeners();
    });

    socketIO.connect();
  }

  void sendMessage(String text, String receiverChatID) {
    messages.add(Message(text, currentUser.chatID, receiverChatID));
    socketIO.sendMessage(
      'send_message',
      json.encode({
        'receiverChatID': receiverChatID,
        'senderChatID': currentUser.chatID,
        'content': text,
      }),
    );
    notifyListeners();
  }

  List<Message> getMessagesForChatID(String chatID) {
    return messages
        .where((msg) => msg.senderID == chatID || msg.receiverID == chatID)
        .toList();
  }
}