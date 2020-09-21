import 'package:bandnames/pages/home.dart';
import 'package:bandnames/pages/status.dart';
import 'package:bandnames/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
 
void main() => runApp(MyApp());
 
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_)=>SocketService())
      ],
          child: MaterialApp(      
        debugShowCheckedModeBanner: false,
        home: HomePage(),
        initialRoute: "home",
        routes :{
          'home':(_) =>HomePage(),
          'status':(_) =>StatusPage(),
        }
      ),
    );
  }
}