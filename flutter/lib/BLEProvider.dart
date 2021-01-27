import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:provider/provider.dart';
class BLEProvider with ChangeNotifier  {
  FlutterReactiveBle _ble;
  StreamSubscription _subscription;
  StreamSubscription<ConnectionStateUpdate> _connection;
  String _message;

  BLEProvider(FlutterReactiveBle ble) {
    _ble = ble;
    _connectBLE();
  }

  void _connectBLE()  {

    _message = "Loading";
    notifyListeners();
    _subscription?.cancel();
    _subscription = _ble.scanForDevices(
        withServices: [],
        scanMode: ScanMode.lowLatency,
        requireLocationServicesEnabled: true).listen((device) async {
      if (device.name == 'Nano33BLESENSE') {
        print('Nano33BLESENSE found!');
        if (_connection != null) {
          await _connection.cancel();
        }

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
            _ble.subscribeToCharacteristic(characteristic).listen((data) {
              // code to handle incoming data
              print(data);
              _message = data[0].toString()+ '°';
              notifyListeners();
              /*setState(() {
                temperature = data[0];
                temperatureStr = temperature.toString() + '°';
              });*/
            }, onError: (dynamic error) {
              // code to handle errors
              print('error subscribing characteristic!');
              print(error.toString());
             /* setState(() {
                temperatureStr = error.toString();
              });*/
            });
           // print('disconnected');
          }
        }, onError: (dynamic error) {
          // Handle a possible error
          print('error connecting!');
          print(error.toString());
         /* setState(() {
            temperatureStr = error.toString();
          });*/
        });
      }
    }, onError: (error) {
      print('error scanning!');
      print(error.toString());
      /*setState(() {
        temperatureStr = error.toString();
      });*/
    });

  }

  void _disconnect() async {
    _subscription?.cancel();
    if (_connection != null) {
      await _connection.cancel();
    }
  }

  String get message => _message;
  StreamSubscription get bleSubscription => _subscription;
}