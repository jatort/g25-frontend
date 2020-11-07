import 'package:http/http.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'dart:convert';
import 'dart:io';
import './ChatRoom.dart';
import './Message.dart';

class ChatModel extends Model {
  String data;
  var _respuesta;
  String url_localhost = 'http://10.0.2.2:3000/api/v1/chats';
  String url_api_server = 'http://34.229.56.163:3000/api/v1/chats';
  String url_api_server_nuevo =
      'https://arqui-example.tk/api/v1/chats'; //USANDO
  String url_api_server_cache = 'https://arqui-e1-with-cache.tk/api/v1/chats';
  String url_api_server_auth = 'http://67.202.62.192:3000/api/v1/chats';
  List _messagesApi;

  Future _sendMessageToApi(String idChat, String token, String mensaje) async {
    String url = "$url_localhost/$idChat/messages";
    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-type": "application/x-www-form-urlencoded",
      HttpHeaders.authorizationHeader: "Bearer $token",
    };
    Map<String, dynamic> body = {"message[body]": mensaje};

    Response response = await post(url,
        headers: headers, body: body, encoding: Encoding.getByName("utf-8"));

    var respuesta = json.decode(response.body);

    return respuesta['data']['message'];
  }

  Future _sendChatroomToApi(String nameChat, String token) async {
    String url = url_localhost;
    Map<String, String> headers = {
      "Accept": "application/json",
      "Content-type": "application/x-www-form-urlencoded",
      HttpHeaders.authorizationHeader: "Bearer $token",
    };
    Map<String, dynamic> body = {"chat[title]": nameChat};

    Response response = await post(url,
        headers: headers, body: body, encoding: Encoding.getByName("utf-8"));

    var respuesta = json.decode(response.body);

    return respuesta['data']['chat'];
  }

  List<ChatRoom> chatrooms = [];

  String currentUser;
  List<ChatRoom> chatRoomList = List<ChatRoom>();
  List<Message> messages = List<Message>();
  SocketIO socketIO;

  void init() {
    chatRoomList = chatrooms.toList();

    socketIO = SocketIOManager()
        .createSocketIO('https://servere1chat.herokuapp.com', '/');
    socketIO.init();

    socketIO.subscribe('receive_message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      messages.add(Message(data['content'], data['senderChatID'],
          data['receiverChatID'], data['timeMsg']));
      notifyListeners();
    });

    socketIO.subscribe('receive_room', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      chatRoomList.add(ChatRoom(data['name'], data['chatID']));
      notifyListeners();
    });

    socketIO.subscribe('receive_notification', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      messages.add(Message(data['content'], data['senderChatID'],
          data['receiverChatID'], data['timeMsg']));
      notifyListeners();
    });

    socketIO.connect();
  }

  void sendMessage(
    String username,
    String text,
    String receiverChatID,
    String token,
  ) async {
    String user = "null";
    final textList = text.split(" ");
    textList.forEach((element) {
      if (element[0] == "@") {
        user = element.substring(1);
      }
    });

    if (user != "null") {
      var now = new DateTime.now().toString();
      messages.add(Message(text, username, receiverChatID, now));
      socketIO.sendMessage(
        'send_notification',
        json.encode({
          'receiverChatID': receiverChatID,
          'senderChatID': username,
          'content': text,
          'privateUser': user,
          'timeMsg': now,
        }),
      );
      notifyListeners();
    } else {
      var respuesta = await _sendMessageToApi(receiverChatID, token, text);
      String timeMsg = respuesta['created_at'].toString();
      messages.add(Message(text, username, receiverChatID, timeMsg));
      socketIO.sendMessage(
        'send_message',
        json.encode({
          'receiverChatID': receiverChatID,
          'senderChatID': username,
          'content': text,
          'timeMsg': timeMsg,
        }),
      );
      notifyListeners();
    }
  }

  void sendRoom(String nameChat, String token) async {
    var respuesta = await _sendChatroomToApi(nameChat, token);
    chatRoomList.add(ChatRoom(nameChat, respuesta['id'].toString()));

    socketIO.sendMessage(
      'send_room',
      json.encode({
        'name': nameChat,
        'chatID': respuesta['id'].toString(),
      }),
    );
    notifyListeners();
  }

  List<Message> getMessagesForChatID(String chatID) {
    List<Message> msgs = List<Message>();
    messages.forEach((element) {
      if (element.text.contains("@")) {
        final elementWordList = element.text.split(" ");
        int notificationCounter = 0;
        elementWordList.forEach((word) {
          if (word[0] == "@") {
            notificationCounter += 1;
            if (element.senderID == currentUser) {
              msgs.add(element);
            }
          }
        });
        if (notificationCounter == 0) {
          msgs.add(element);
        }
      } else {
        msgs.add(element);
      }
    });

    return msgs.where((msg) => msg.receiverID == chatID).toList();
  }

  List<ChatRoom> getChatRooms() {
    return chatRoomList;
  }
}
