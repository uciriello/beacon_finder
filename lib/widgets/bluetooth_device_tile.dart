import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class BluetoothDeviceTile extends StatelessWidget {
  final BluetoothDevice device;

  BluetoothDeviceTile(this.device);

  @override
  Widget build(BuildContext context) {

    return
     Card(
        elevation: 5,
        margin: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 5,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    device.name,
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  Text(
                    device.id.toString(),
                  ),
                ],
              ),
              Icon(Icons.bluetooth, color: Colors.lightBlue),
            ],
          ),
        ),
    );
  }
}
