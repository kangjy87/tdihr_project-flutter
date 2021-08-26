import 'package:flutter/material.dart';
import 'package:wifi_flutter/wifi_flutter.dart';

class FlutterWifiIoT extends StatefulWidget {
  @override
  _FlutterWifiIoTState createState() => _FlutterWifiIoTState();
}

class _FlutterWifiIoTState extends State<FlutterWifiIoT> {
  List<Widget> _platformVersion = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ListView.builder(
            itemBuilder: (context, i) => _platformVersion[i],
            itemCount: _platformVersion.length,
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final noPermissions = await WifiFlutter.promptPermissions();
            if (noPermissions) {
              return;
            }
            final networks = await WifiFlutter.wifiNetworks;
            setState(() {
              _platformVersion = networks
                  .map(
                      (network) => Text("Ssid ${network.ssid} - Strength ${network.rssi} - Secure ${network.isSecure}"))
                  .toList();
            });
          },
        ),
      ),
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('Wifi'),
  //       centerTitle: true,
  //     ),
  //   );
  // }
}
