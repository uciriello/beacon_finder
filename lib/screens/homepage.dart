import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../providers/global_translations_provider.dart';
import '../providers/bt_services_provider.dart';

// import '../widgets/custom_drawer.dart';
import '../widgets/bluetooth_device_tile.dart';

class MyHomePage extends StatefulWidget {
  static const String routeName = "/homepage";

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  AudioPlayer audioPlayer = AudioPlayer();
  AudioCache audioCache;
  String path = "sample.mp3";

  @override
  void initState() {
    super.initState();
    audioCache = AudioCache(fixedPlayer: audioPlayer);
  }

  @override
  void dispose() {
    audioPlayer.release();
    audioPlayer.dispose();
    super.dispose();
  }

  void playMusic() async {
    await audioCache.play(path);
  }

  void pauseMusic() async {
    await audioPlayer.pause();
  }

  @override
  Widget build(BuildContext context) {
    final btServices = Provider.of<BTServicesProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Ricerca dispositivi"),
      ),
      // drawer: CustomDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => btServices.startScan(),
                  child: Text("Devices"),
                ),
                ElevatedButton(
                  onPressed: () => btServices.startBackgroundScan(),
                  child: Text("Background"),
                ),
                Consumer<BTServicesProvider>(
                  builder: (context, data, _) {
                    if (data.inRange != null && data.inRange) {
                      playMusic();
                    }
                    return ElevatedButton(
                      onPressed: (data.inRange != null && data.inRange)
                          ? () {
                              pauseMusic();
                              btServices.resetResults();
                            }
                          : null,
                      child: Text("Stop"),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<BTServicesProvider>(
              builder: (ctx, bt, _) => Column(
                children: [
                  if (bt.isScanning != null && bt.isScanning)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Scanning..."),
                    ),
                  bt.scannedDevices.length == 0 &&
                          (bt.isScanning == null || !bt.isScanning)
                      ? Text("No devices found, start scanning")
                      : Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Device trovati:",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: bt.scannedDevices.length,
                      itemBuilder: (context, i) {
                        return BluetoothDeviceTile(bt.scannedDevices[i]);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
