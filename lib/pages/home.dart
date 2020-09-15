import 'dart:io';

import 'package:bandnames/models/band.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Gustavo Cerati', votes: 5),
    Band(id: '2', name: 'Cafe tacvba', votes: 110),
    Band(id: '3', name: 'Placebo', votes: 50),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          title: Text('Bandas', style: TextStyle(color: Colors.black87)),
          backgroundColor: Colors.white,
        ),
        body: ListView.builder(
            itemCount: bands.length,
            itemBuilder: (context, i) => _bandTile(bands[i])),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add), elevation: 1, onPressed: addNewBand));
  }

  Widget _bandTile(Band band) {
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (DismissDirection direction) {
        print('direction $direction');
        print('id ${band.id}');
        //Borrar desde el server
      },
      background: Container(
          padding: EdgeInsets.only(left: 10.0),
          color: Colors.red,
          child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ))),
      direction: DismissDirection.startToEnd,
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0, 2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text(
          '${band.votes}',
          style: TextStyle(fontSize: 20),
        ),
        onTap: () {
          print(band.name);
        },
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();
    if (Platform.isIOS) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Nuevo nombre banda"),
              content: TextField(
                controller: textController,
              ),
              actions: <Widget>[
                MaterialButton(
                    textColor: Colors.blue,
                    child: Text("Agregar"),
                    elevation: 5,
                    onPressed: () => addBandToList(textController.text))
              ],
            );
          });
    }

    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text("Nueva banda"),
            content: CupertinoTextField(
              controller: textController,
            ),
            actions: <Widget>[
              CupertinoDialogAction(
                child: Text("Agregar"),
                onPressed: () => addBandToList(textController.text),
                isDefaultAction: true,
              ),
              CupertinoDialogAction(
                child: Text("Cancelar"),
                onPressed: () => Navigator.pop(context),
                isDestructiveAction: true,
              )
            ],
          );
        });
  }

  void addBandToList(String name) {
    print(name);
    if (name.length > 1) {
      this
          .bands
          .add(new Band(id: DateTime.now().toString(), name: name, votes: 0));
      setState(() {});
    }

    Navigator.pop(context);
  }
}
