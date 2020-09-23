import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';



final ThemeData iOSTheme = new ThemeData(
  primarySwatch: Colors.blue,
  primaryColor: Colors.grey,
  primaryColorBrightness: Brightness.dark,
);

final ThemeData androidTheme = new ThemeData(
  primarySwatch: Colors.blue,
  accentColor: Colors.green,
);

const String defaultUserName = "Juan";

void main() => runApp(new MyApp());


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return new MaterialApp(
      title: "Chat ",
      theme: defaultTargetPlatform == TargetPlatform.iOS
          ? iOSTheme
          : androidTheme,
      home: new ListViewHandelItem(), /// Acá se crea la clase que contiene la lista de los Chat
    );
  }
}

ListViewHandelItemState chatsPage;

class ListViewHandelItem extends StatefulWidget {
  @override
  ListViewHandelItemState createState() {
    chatsPage = ListViewHandelItemState();
    return chatsPage;
  }
}

/// https://here4you.tistory.com/185
class ListViewHandelItemState extends State<ListViewHandelItem> {
  List<String> items = <String> ['Sala 1', 'Games', 'Music'];

  final nameChatController = TextEditingController(
    text: "",
  );

  @override
  void dispose() {
    nameChatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat List")),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Dismissible(
                  key: Key(item),
                  direction: DismissDirection.startToEnd,
                  child: ListTile(
                    title: Text(item),
                    trailing: IconButton(
                      icon: Icon(Icons.send),
                      color: Colors.blue,
                      onPressed: () { /// Da instrucciones de qué hacer cuando se presiona el botón
                        Route route = MaterialPageRoute(builder: (bc) => Chat(item)); /// Acá redirecciona al Chat
                        Navigator.of(context).push(route); /// pushea la ruta del Chat
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(
            color: Colors.blue,
            height: 5,
            indent: 10,
            endIndent: 10,
          ),
          Padding(
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
                            items.add(nameChatController.text);
                          }
                        });
                        nameChatController.clear();
                      },
                    ),
                  ),
                ),
                RaisedButton(
                  child: new Text("New Chat Room",
                    style: TextStyle(
                    color: Colors.white,
                  ),
                  ),
                  color: Colors.green,
                  onPressed: () {
                    setState(() {
                      if (nameChatController.text != "") {
                        items.add(nameChatController.text);
                      }
                    });
                    nameChatController.clear();
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// https://github.com/tensor-programming/dart_flutter_chat_app

class Chat extends StatefulWidget {
  final String room;

  Chat(this.room);

  @override
  State createState() => new ChatWindow(room);
}

class ChatWindow extends State<Chat> with TickerProviderStateMixin {
  final List<Msg> _messages = <Msg>[];
  final TextEditingController _textController = new TextEditingController();
  final String _room;
  bool _isWriting = false;

  ChatWindow(this._room);

  @override
  Widget build(BuildContext ctx) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Nombre Sala: ${_room}"),
        elevation:
        Theme.of(ctx).platform == TargetPlatform.iOS ? 0.0 : 6.0,
      ),
      body: new Column(children: <Widget>[
        new Flexible(
            child: new ListView.builder(
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
              reverse: true,
              padding: new EdgeInsets.all(6.0),
            )),
        new Divider(height: 1.0),
        new Container(
          child: _buildComposer(),
          decoration: new BoxDecoration(color: Colors.white),
        ),
      ]),
    );
  }


  Widget _buildComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 9.0),
          child: new Row(
            children: <Widget>[
              new Flexible(
                child: new TextField(
                  controller: _textController,
                  onChanged: (String txt) {
                    setState(() {
                      _isWriting = txt.length > 0;
                    });
                  },
                  onSubmitted: _submitMsg,
                  decoration:
                  new InputDecoration.collapsed(hintText: "Enter a message"),
                ),
              ),
              new Container(
                  margin: new EdgeInsets.symmetric(horizontal: 3.0),
                  child: Theme.of(context).platform == TargetPlatform.iOS
                      ? new CupertinoButton(
                      child: new Text("Submit"),
                      onPressed: _isWriting ? () => _submitMsg(_textController.text)
                          : null
                  )
                      : new IconButton(
                    icon: new Icon(Icons.send),
                    onPressed: _isWriting
                        ? () => _submitMsg(_textController.text)
                        : null,
                  )
              ),
            ],
          ),
          decoration: Theme.of(context).platform == TargetPlatform.iOS
              ? new BoxDecoration(
              border:
              new Border(top: new BorderSide(color: Colors.red))) :
          null
      ),
    );
  }

  void _submitMsg(String txt) {
    _textController.clear();
    setState(() {
      _isWriting = false;
    });
    Msg msg = new Msg(
      txt: txt,
      animationController: new AnimationController(
          vsync: this,
          duration: new Duration(milliseconds: 800)
      ),
    );
    setState(() {
      _messages.insert(0, msg);
    });
    msg.animationController.forward();
  }

  @override
  void dispose() {
    for (Msg msg in _messages) {
      msg.animationController.dispose();
    }
    super.dispose();
  }

}

class Msg extends StatelessWidget {
  Msg({this.txt, this.animationController});
  final String txt;
  final AnimationController animationController;
  @override
  Widget build(BuildContext ctx) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
          parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
              margin: const EdgeInsets.only(right: 18.0)
            ),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text('${defaultUserName}:   [${new DateTime.now()}]',
                      style: Theme.of(ctx).textTheme.subtitle1),
                  new Container(
                    margin: const EdgeInsets.only(top: 6.0),
                    child: new Text(txt),
                  ),
                ],
              ),
            ),
          ],
        ),
        color: Colors.indigo[100],
    padding: EdgeInsets.symmetric(
    vertical: 12,
    horizontal: 0,
        ),
      ),
    );
  }
}