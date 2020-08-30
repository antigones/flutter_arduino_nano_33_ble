import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
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
      home: MyHomePage(title: 'Arduino Temperature'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FlutterReactiveBle _ble = FlutterReactiveBle();
  StreamSubscription _subscription;
  StreamSubscription<ConnectionStateUpdate> _connection;
  int temperature;
  String temperatureStr = "Hello";

  void _disconnect() async {
    _subscription?.cancel();
    if (_connection != null) {
      await _connection.cancel();
    }
  }

  void _connectBLE() {
    setState(() {
      temperatureStr = 'Loading';
    });
    _disconnect();
    _subscription = _ble.scanForDevices(
        withServices: [],
        scanMode: ScanMode.lowLatency,
        requireLocationServicesEnabled: true).listen((device) {
      if (device.name == 'Nano33BLESENSE') {
        print('Nano33BLESENSE found!');
        _connection = _ble
            .connectToDevice(
          id: device.id,
        )
            .listen((connectionState) async {
          // Handle connection state updates
          print('connection state:');
          print(connectionState.connectionState);
          if (connectionState.connectionState ==
              DeviceConnectionState.connected) {
            final characteristic = QualifiedCharacteristic(
                serviceId: Uuid.parse("181A"),
                characteristicId: Uuid.parse("2A6E"),
                deviceId: device.id);
            final response = await _ble.readCharacteristic(characteristic);
            print(response);
            setState(() {
              temperature = response[0];
              temperatureStr = temperature.toString() + '°';
            });
            _disconnect();
            print('disconnected');
          }
        }, onError: (dynamic error) {
          // Handle a possible error
          print(error.toString());
        });
      }
    }, onError: (error) {
      print('error!');
      print(error.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xffffdf6f), Color(0xffeb2d95)])),
        child: Center(
          child: Text(
            temperatureStr,
            style: GoogleFonts.anton(
                textStyle: Theme.of(context)
                    .textTheme
                    .headline1
                    .copyWith(color: Colors.white)),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _connectBLE,
        tooltip: 'Increment',
        backgroundColor: Color(0xFF74A4BC),
        child: Icon(Icons.loop),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
