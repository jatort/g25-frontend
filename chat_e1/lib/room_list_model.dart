import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'dart:convert';
import './user.dart';
import './Message.dart';
import './room.dart';

class RoomListModel extends Model {
  List<Room> rooms = [
    Room('IronMan', '111'),
    Room('Captain America', '222'),
    Room('Antman', '333'),
  ];
  List<User> users = [
    User('IronMan', '111'),
    User('Captain America', '222'),
    User('Antman', '333'),
  ];

  User currentUser;
  Room currentRoom;
  List<Room> roomList = List<Room>();
  List<User> friendList = List<User>();
  List<Message> messages = List<Message>();
  SocketIO socketIO;

  void init() {
    currentUser = users[0];
    currentRoom = rooms[0];
    roomList = rooms;
    friendList =
        users.where((user) => user.userID != currentUser.userID).toList();

    socketIO = SocketIOManager().createSocketIO(
        'https://fluchat.herokuapp.com', '/',
        query: 'userID=${currentUser.userID}');
    socketIO.init();

    socketIO.subscribe('receive_message', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      messages
          .add(Message(data['content'], data['senderChatID'], data['roomID']));
      notifyListeners();
    });

    socketIO.subscribe('receive_add_room', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      roomList.add(Room(data['name'], data['roomID']));
      notifyListeners();
    });

    socketIO.connect();
  }

  void sendMessage(String text, String receiverChatID) {
    messages.add(Message(text, currentUser.userID, receiverChatID));
    socketIO.sendMessage(
      'send_message',
      json.encode({
        'receiverChatID': receiverChatID,
        'senderChatID': currentUser.userID,
        'content': text,
      }),
    );
    notifyListeners();
  }

  void addRoom(String name, String roomID) {
    roomList.add(Room(name, roomID));
    socketIO.sendMessage(
      'send_add_room',
      json.encode({
        'name': name,
        'roomID': roomID,
      }),
    );
    notifyListeners();
  }

  List<Message> getMessagesForRoomID(String roomID) {
    return messages.where((msg) => msg.roomID == roomID).toList();
  }
}
