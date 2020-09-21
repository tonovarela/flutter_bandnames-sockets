import 'dart:io';

import 'package:bandnames/models/band.dart';
import 'package:bandnames/services/socket_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [];

  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('activeBands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List).map((band) => Band.fromMap(band)).toList();
    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('activeBands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          actions: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10),
              child: socketService.serverStatus == ServerStatus.Online
                  ? Icon(Icons.check_circle, color: Colors.green[300])
                  : Icon(Icons.offline_bolt, color: Colors.red),
            )
          ],
          title: Text('Bandas', style: TextStyle(color: Colors.black87)),
          backgroundColor: Colors.white,
        ),
        body: Column(
          children: <Widget>[
            bands.length > 0 ? _showGraph() : Center(),
            Expanded(
              child: ListView.builder(
                  itemCount: bands.length,
                  itemBuilder: (context, i) => _bandTile(bands[i])),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add), elevation: 1, onPressed: addNewBand));
  }

  Widget _bandTile(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    return Dismissible(
      key: UniqueKey(),
      onDismissed: (_) =>
          socketService.socket.emit('delete-band', {"id": band.id}),
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
        onTap: () => socketService.socket.emit('vote', {'id': band.id}),
      ),
    );
  }

  addNewBand() {
    final textController = new TextEditingController();
    if (Platform.isIOS) {
      showDialog(
          context: context,
          builder: (_) {
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
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (name.length > 1) {
      socketService.socket.emit('add-band', {"name": name});
    }
    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = new Map();
    bands.forEach((band) {
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    return Container(
        width: double.infinity,
        padding:EdgeInsets.only(top:20),
        height: 200,
        child: PieChart(
            dataMap: dataMap,
            chartType:ChartType.ring ,
            chartValuesOptions: ChartValuesOptions(
              showChartValueBackground: true,
              decimalPlaces: 2,
              showChartValues: true,
              showChartValuesInPercentage: true,
              showChartValuesOutside: false,
            )));
  }
}
