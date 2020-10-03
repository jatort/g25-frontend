import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
import 'dart:convert';

import './User.dart';
import './Message.dart';
import './room.dart';

class RoomsModel extends Model {
  List<Room> testRooms = [
    Room('room1', '111'),
    Room('room2', '222'),
    Room('room3', '333'),
    Room('room4', '444'),
    Room('room5', '555'),
  ];

  User currentUser = User('testUser1', '123');
  List<Room> roomList = List<Room>();
  List<Message> messages = List<Message>();
  SocketIO socketIO;

  void init() {
    socketIO = SocketIOManager().createSocketIO(
        'https://fluchat.herokuapp.com', '/',
        query: 'userID=${currentUser.userID}');
    socketIO.init();

    socketIO.subscribe('receive_room', (jsonData) {
      Map<String, dynamic> data = json.decode(jsonData);
      roomList.add(Room(data['name'], data['roomID']));
      notifyListeners();
    });

    socketIO.connect();
  }

  void sendRoom(String name, String roomID) {
    roomList.add(Room(name, roomID));
    socketIO.sendMessage(
      'send_room',
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
