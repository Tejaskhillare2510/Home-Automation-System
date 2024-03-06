// ignore_for_file: prefer_const_constructors
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:wifi_iot/wifi_iot.dart';
import 'package:wifi_scan/wifi_scan.dart';

///  Main WifiScreen Class
class WifiScreen extends StatefulWidget {
  const WifiScreen({super.key});

  @override
  State<StatefulWidget> createState() => WifiScreenState();
}

/// WifiScreen State Class
class WifiScreenState extends State<WifiScreen> {
  String _screenState = 'loading';

// initialize accessPoints and subscription
  List<WiFiAccessPoint> accessPoints = [];
  StreamSubscription<List<WiFiAccessPoint>>? subscription;

  void _startListeningToScannedResults() async {
    // check platform support and necessary requirements
    final can =
        await WiFiScan.instance.canGetScannedResults(askPermissions: true);
    switch (can) {
      case CanGetScannedResults.yes:
        // listen to onScannedResultsAvailable stream
        subscription =
            WiFiScan.instance.onScannedResultsAvailable.listen((results) {
          // update accessPoints
          log('Can get the result');
          setState(() {
            _screenState = 'Enabled';
            accessPoints = results;
          });
        });
        // ...
        break;

      case (CanGetScannedResults.noLocationServiceDisabled):
        await Location().requestService();
        setState(() {
          _screenState = 'loading';
        });

      default:
        log('Error while getting the result');
    }
  }

// make sure to cancel subscription after you are done
  @override
  dispose() {
    super.dispose();
    subscription?.cancel();
  }

  @override
  void initState() {
    _startListeningToScannedResults();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    checkWifiState();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Wifi Networks'),
        ),
        body: _screenState == 'loading'
            ? Center(
                child: CircularProgressIndicator(),
              )
            : _screenState == 'DISABLED'
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.wifi_off,
                          size: 100,
                          color: Colors.red,
                        ),
                        Text(
                          'WiFi is disabled',
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {});
                            WiFiForIoTPlugin.setEnabled(true,
                                shouldOpenSettings: true);
                          },
                          child: Text(
                            'Enable WiFi',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )
                : StreamBuilder(
                    stream: WiFiScan.instance.onScannedResultsAvailable,
                    builder: (context, snapshot) {
                      return ListView.builder(
                        itemCount: snapshot.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          return InkWell(
                              child: ListTile(
                                  title: Text(
                                    snapshot.data![index].ssid,
                                    // style: TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Column(
                                    children: [
                                      // Text('Bssid : ${snapshot.data![index].level}')
                                    ],
                                  )),
                              onTap: () async {
                                WiFiForIoTPlugin.disconnect();

                                await WiFiForIoTPlugin.connect(
                                  snapshot.data![index].ssid,
                                  withInternet: false,
                                  // security: NetworkSecurity.WPA,
                                  password: 'ece@123ece',
                                );
                                WiFiForIoTPlugin.forceWifiUsage(true);
                              });
                        },
                      );
                    }));
  }

  void checkWifiState() async {
    if (await WiFiForIoTPlugin.isEnabled()) {
      setState(() {
        _screenState = 'ENABLED';
      });
    } else {
      setState(() {
        _screenState = 'DISABLED';
      });
    }
  }
}
