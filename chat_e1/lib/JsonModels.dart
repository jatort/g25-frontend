class RoomsJson {
  final String messages;
  final bool is_success;
  Data data;

  RoomsJson({this.messages, this.is_success, this.data});

  factory RoomsJson.fromJson(Map<String, dynamic> json) {
    return RoomsJson(
      messages: json['messages'],
      is_success: json['is_success'],
      data: Data.fromJson(json['data']),
    );
  }
}

class Data {
  List<Room> chats;

  Data({this.chats});

  factory Data.fromJson(Map<String, dynamic> json) {
    var list = json['chats'] as List;
    List<Room> roomList = list.map((i) => 
    Room.fromJson(i)).toList();

    return Data(
      //chats: Room.fromJson(json['chats']),

      chats: roomList,
    );
  }
}

class Room {
  final int id;
  final String title;

  Room({this.id, this.title});

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      title: json['title'],
    );
  }
}