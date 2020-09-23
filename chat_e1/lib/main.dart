import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'chat.dart';

final ThemeData iOSTheme = new ThemeData(
  primarySwatch: Colors.blue,
  primaryColor: Colors.grey,
  primaryColorBrightness: Brightness.dark,
);

final ThemeData androidTheme = new ThemeData(
  primarySwatch: Colors.blue,
  accentColor: Colors.green,
);

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return new MaterialApp(
      title: "Chat ",
      theme:
          defaultTargetPlatform == TargetPlatform.iOS ? iOSTheme : androidTheme,
      home: new ListViewHandelItem(),

      /// Acá se crea la clase que contiene la lista de los Chat
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
  List<String> items = <String>['Sala 1', 'Games', 'Music'];

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
                      onPressed: () {
                        /// Da instrucciones de qué hacer cuando se presiona el botón
                        Route route =
                            MaterialPageRoute(builder: (bc) => Chat());

                        /// Acá redirecciona al Chat
                        Navigator.of(context).push(route);

                        /// pushea la ruta del Chat
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
