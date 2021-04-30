import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'dart:math';
import 'dart:async';

class BTServicesProvider extends ChangeNotifier {
  List<BluetoothDevice> _scannedDevice = [];
  BluetoothDevice _connectedDevice;
  bool _keepScanning;
  bool _isScanning;
  var _subscription;
  FlutterBlue flutterBlue = FlutterBlue.instance;
  bool _inRange = false;

  List<BluetoothDevice> get scannedDevices => _scannedDevice;

  bool get isScanning => _isScanning;

  bool get inRange => _inRange;

  void startTimer() {
    Timer(Duration(seconds: 7), backgroundScan);
  }

  void backgroundScan() {
    flutterBlue.startScan(timeout: Duration(seconds: 2));
    _subscription = flutterBlue.scanResults.listen((results) {
      // do something with scan results
      if (_keepScanning != null && _keepScanning) {
        for (ScanResult r in results) {
          if (r.device.name != null &&
              r.device.name.length > 0 &&
              r.device.name == "WGX_iBeacon") {
            print('${r.device.name} found! rssi: ${r.rssi}');
            var distance = getDistance(r.rssi);
            print('distance: $distance m');
            if (distance < 10) {
              _inRange = true;
              notifyListeners();
            }
          }
        }
      }
    });
    if (_keepScanning != null && _keepScanning) {
      startTimer();
    }
    flutterBlue.stopScan();
  }

  void startBackgroundScan() {
    _keepScanning = true;
    backgroundScan();
  }

  void startScan() {
    _scannedDevice = [];
    _isScanning = true;
    notifyListeners();
    try {
      flutterBlue.startScan(timeout: Duration(seconds: 6)).then(
        (value) {
          _isScanning = false;
          notifyListeners();
        },
      );
    } catch (error) {
      print("errore nella scansione");
    }
    _subscription = flutterBlue.scanResults.listen(
      (results) {
        for (ScanResult r in results) {
          if (!_scannedDevice.contains(r.device) &&
              r.device.name.trim().length != 0) {
            _scannedDevice.add(r.device);
            notifyListeners();
          }
        }
      },
    );
  }

  // considering -59 db as basic power
  double getDistance(int rssi) {
    return pow(10, ((-59.0 - rssi)) / (10 * 2));
  }

  // doesn't work if a timeout is set
  void stopScan() {
    _subscription.cancel();
    flutterBlue.stopScan();
  }

  Future<void> connect(BluetoothDevice device) async {
    _connectedDevice = device;
    notifyListeners();
    return;
    // return device.connect();
  }

  Future<void> disconnect() async {
    if (_connectedDevice != null) {
      _connectedDevice = null;
      notifyListeners();
      return;
      // return await _connectedDevice.disconnect();
    }
  }

  void resetResults() {
    _inRange = false;
    _keepScanning = false;
    _scannedDevice = [];
    notifyListeners();
  }
}
