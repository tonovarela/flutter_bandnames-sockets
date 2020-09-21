import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

enum ServerStatus { Online, OffLine, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  IO.Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;

  IO.Socket get socket => this._socket;
  Function get emit => this._socket.emit;

  SocketService() {
    _initConfig();
  }

  void _initConfig() {
    _socket = IO.io('http://192.168.0.8:3000/', {
      'transports': ['websocket'],
      'autoConnect': true,
    });
    _socket.on('connect', (_) {
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
      print('connect');      
    });

    _socket.on('nuevo-mensaje', (payload) {
      print(payload);
      // print('Nombre: ' + payload['nombre']);
      // print('mensaje :' + payload['mensaje']);
      print(
          payload.containsKey('mensaje2') ? payload['mensaje2'] : 'No existe');
      //socket.emit('msg', 'test');
    });

    _socket.on('event', (data) => print(data));
    _socket.on('disconnect', (_) {
      this._serverStatus = ServerStatus.OffLine;
      notifyListeners();
    });
  }
}
