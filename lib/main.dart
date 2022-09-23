import 'package:band_names/services/socket_services.dart';
import 'package:flutter/material.dart';

import 'package:band_names/pages/home.dart';
import 'package:band_names/pages/status.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SocketService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Band Names',
        initialRoute: 'home',
        routes: {
          "home": (BuildContext context) => HomePage(),
          "status": (BuildContext context) => StatusPage(),
        },
      ),
    );
  }
}
