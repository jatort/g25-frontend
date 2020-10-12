import 'package:http/http.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import './User.dart';
import './Message.dart';

class ChatModel extends Model {
  String data;
  var _respuesta;
  String url_localhost = 'http://10.0.2.2:3000/api/v1/chats';
  String url_api_server = 'http://34.229.56.163:3000/api/v1/chats';
  List _messagesApi;

  Future<String> _sendMessageToApi(
      String idChat, String token, String mensaje) async {
    //String url = "$url_api_server/$idChat/messages";
    String url = 'http://192.168.0.11/api/v1/chats/$idChat/messages';
    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-type": "application/x-www-form-urlencoded"
    };
    Map<String, dynamic> body = {"message[body]": mensaje};

    Response response = await post(url,
        headers: headers, body: body, encoding: Encoding.getByName("utf-8"));

    var respuesta = json.decode(response.body);

    return respuesta;
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

    socketIO = SocketIOManager()
        .createSocketIO('https://servere1chat.herokuapp.com', '/');
    socketIO.init();

    socketIO.subscribe('receive_message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      messages.add(Message(
          data['content'], data['senderChatID'], data['receiverChatID']));
      notifyListeners();
    });

    socketIO.connect();
  }

  void sendMessage(
      String username, String text, String receiverChatID, String token) {
    messages.add(Message(text, currentUser, receiverChatID));
    //var respuesta = _sendMessageToApi(receiverChatID, token, text);
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

  List<Message> getMessagesForChatID(String chatID) {
    //var respuesta = _getMessagesFromApi(chatID, token);
    return messages.where((msg) => msg.receiverID == chatID).toList();
  }
}
