import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_arduino_nano_33_ble/BLEProvider.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterReactiveBle ble = FlutterReactiveBle();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => BLEProvider(ble)),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {


  int temperature;
  String temperatureStr = "Hello";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xffffdf6f), Color(0xffeb2d95)])),
            child: Center(child: Consumer<BLEProvider>(
              builder: (context, ble, child) {
                return Text(
                  ble.message,
                  style: GoogleFonts.anton(
                      textStyle: Theme.of(context)
                          .textTheme
                          .headline1
                          .copyWith(color: Colors.white)),
                );
              },
            )))
        /*floatingActionButton: FloatingActionButton(
        onPressed: _connectBLE,
        tooltip: 'Increment',
        backgroundColor: Color(0xFF74A4BC),
        child: Icon(Icons.loop),
      ), */ // This trailing comma makes auto-formatting nicer for build methods.
        );
  }
}
