// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:automation_app/wifiscreen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late final Connectivity connectionObj;
  late final Stream<ConnectivityResult> subscription;
  // List<bool> buttonState = [false, false, false, false];
  bool buttonState = false;
  final numController = TextEditingController();

  // get http => null;

  @override
  void initState() {
    connectionObj = Connectivity();
    subscription = Connectivity().onConnectivityChanged;
    super.initState();
  }

  void showSnackMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          child: Text(message),
        ),
        backgroundColor: color,
      ),
    );
  }

  // Future<void> toggleLed(int i) async {
  //   try {
  //     final response =
  //         await http.get(Uri.parse("http://192.168.4.1/led_${i + 1}"));

  //     if (response.statusCode == 200) {
  //       final jsonResponse = json.decode(response.body);
  //       print(jsonResponse);

  //       showSnackMessage(
  //         context,
  //         "Led turned ${jsonResponse['ledStatus'] == 1 ? "on" : "off"}",
  //         jsonResponse['ledStatus'] == 1 ? Colors.green : Colors.grey,
  //       );
  //       setState(() {
  //         buttonState[i] = jsonResponse["ledStatus"] == 1 ? true : false;
  //       });
  //     } else {
  //       showSnackMessage(
  //         context,
  //         "Unexpected status code: ${response.statusCode}",
  //         Colors.green,
  //       );
  //     }
  //   } catch (e) {
  //     showSnackMessage(context, "Error toggling LED: $e", Colors.red);
  //   }
  // }
  Future<void> toggleButton() async {
    try {
      final response = await http.get(Uri.parse("http://192.168.4.1/button"));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print(jsonResponse);

        showSnackMessage(
          context,
          "button turned ${jsonResponse['buttonStatus'] ? "on" : "off"}",
          jsonResponse['buttonStatus'] ? Colors.green : Colors.grey,
        );
        log(jsonResponse['buttonStatus'].toString());
        setState(() {
          buttonState = jsonResponse["buttonStatus"];
        });
      } else {
        showSnackMessage(
          context,
          "Unexpected status code: ${response.statusCode}",
          Colors.grey,
        );
      }
    } catch (e) {
      showSnackMessage(context, "Error toggling button: $e", Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.wifi),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return WifiScreen();
              }));
            },
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: StreamBuilder<ConnectivityResult>(
            stream: subscription,
            builder: (context, snapshot) {
              if (snapshot.data != ConnectivityResult.wifi) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.red[700]),
                      padding: const EdgeInsets.all(8),
                      child: const Text(
                        "Please connect to wifi",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        toggleButton();
                      },
                      icon: Icon(
                        Icons.lightbulb,
                        size: 100,
                        color: buttonState ? Colors.yellow[700] : Colors.grey,
                      ),
                    ),
                    // IconButton(
                    //   onPressed: () {
                    //     toggleLed(1);
                    //   },
                    //   icon: Icon(
                    //     buttonState[1]
                    //         ? Icons.local_fire_department_outlined
                    //         : Icons.local_fire_department_rounded,
                    //     size: 100,
                    //     color:
                    //         buttonState[1] ? Colors.yellow[700] : Colors.grey,
                    //   ),
                    // ),
                    // IconButton(
                    //   onPressed: () {
                    //     toggleLed(2);
                    //   },
                    //   icon: Icon(
                    //     CupertinoIcons.lightbulb_fill,
                    //     size: 100,
                    //     color:
                    //         buttonState[2] ? Colors.yellow[700] : Colors.grey,
                    //   ),
                    // ),
                    // IconButton(
                    //   onPressed: () {
                    //     toggleLed(3);
                    //   },
                    //   icon: Icon(
                    //     Icons.lightbulb,
                    //     size: 100,
                    //     color:
                    //         buttonState[3] ? Colors.yellow[700] : Colors.grey,
                    //   ),
                    // ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

class FilledButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const FilledButton({
    Key? key,
    required this.onPressed,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
