import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import './ChatRoom.dart';
import './Message.dart';

class ChatModel extends Model {

  String data;
  var _respuesta;

  Future<String> getJsonData() async {

    final token = "2iO2NMu-Iw-QU0G_BwZZUg";
    String url = 'http://192.168.0.7:3000/api/v1/chats';
    Map<String, String> headers = {"Accept": "application/json", "Content-type": "application/x-www-form-urlencoded", HttpHeaders.authorizationHeader: "Bearer $token",};
    Map<String, dynamic> body = {"user[email]": "nmaturana7@uc.cl", "user[password]": "colegio", "user[username]": "nmaturana7", "user[password_confirmation]": "colegio"};
    //Map<String, dynamic> body = {"sign_in[email]": "Hello", "sign_in[password]": "body text"};
    //var json = {"sign_in[email]": "Hello", "sign_in[password]": "body text"};

    final response = await http.get(url,  headers: headers);
    //print(response.body);
    if (response.statusCode == 200) {
      var convertDataToJson = json.decode(response.body);
      data = convertDataToJson['messages'];
    }
    

    return "Success";
}
  List<ChatRoom> chatrooms = [
    ChatRoom('IronMan', '111'),
    ChatRoom('Captain America', '222'),
    ChatRoom('Antman', '333'),
    ChatRoom('Hulk', '444'),
    ChatRoom('Thor', '555'),
  ];

  String currentUser;
  List<ChatRoom> chatRoomList = List<ChatRoom>();
  List<Message> messages = List<Message>();
  SocketIO socketIO;

  void init() {
    currentUser = "Oscar";
    chatRoomList = chatrooms.toList();

    socketIO =
        SocketIOManager().createSocketIO('https://fluchat.herokuapp.com', '/');
    socketIO.init();

    socketIO.subscribe('receive_message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      messages.add(Message(
          data['content'], data['senderChatID'], data['receiverChatID']));
      notifyListeners();
    });

    socketIO.subscribe('receive_room', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      chatRoomList.add(ChatRoom(data['name'], data['chatID']));
      notifyListeners();
    });

    socketIO.connect();
  }

  void sendMessage(String username, String text, String receiverChatID) {
    messages.add(Message(text, currentUser, receiverChatID));
    socketIO.sendMessage(
      'send_message',
      json.encode({
        'receiverChatID': receiverChatID,
        'senderChatID': currentUser,
        'content': text,
      }),
    );
    notifyListeners();
  }

  void sendRoom(String name, String chatID) {
    chatRoomList.add(ChatRoom(name, chatID));
    socketIO.sendMessage(
      'send_room',
      json.encode({
        'name': name,
        'chatID': chatID,
      }),
    );
    notifyListeners();
  }

  List<Message> getMessagesForChatID(String chatID) {
    return messages.where((msg) => msg.receiverID == chatID).toList();
  }

  List<ChatRoom> getChatRooms() {
    return chatRoomList;
  }
}
