import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scoreboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Scoreboard'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BluetoothConnection? connection;
  bool connected = false;

  int leftPoints = 0;
  int rightPoints = 0;
  int gameTimeSeconds = 0;
  bool timerRunning = false;

  void _addLeftPoint() {
    setState(() {
      leftPoints++;
      _sendData("L+$leftPoints");
    });
  }

  void _subtractLeftPoint() {
    setState(() {
      leftPoints--;
      if (leftPoints < 0) leftPoints = 0;
      _sendData("L-$leftPoints");
    });
  }

  void _addRightPoint() {
    setState(() {
      rightPoints++;
      _sendData("R+$rightPoints");
    });
  }

  void _subtractRightPoint() {
    setState(() {
      rightPoints--;
      if (rightPoints < 0) rightPoints = 0;
      _sendData("R-$rightPoints");
    });
  }

  void _addTime() {
    setState(() {
      gameTimeSeconds++;
      _sendData("T+$gameTimeSeconds");
    });
  }

  void _subtractTime() {
    setState(() {
      gameTimeSeconds--;
      if (gameTimeSeconds < 0) gameTimeSeconds = 0;
      _sendData("T-$gameTimeSeconds");
    });
  }

  void _startStopTimer() {
    setState(() {
      timerRunning = !timerRunning;
      _sendData("S${timerRunning ? "1" : "0"}");
    });
  }

  void _sendData(String data) async {
    if (connected && connection != null) {
      connection!.output.add(ascii.encode(data));
      await connection!.output.allSent;
    }
  }

  void _connectToDevice() async {
    List<BluetoothDevice> devices = [];

    devices = await FlutterBluetoothSerial.instance.getBondedDevices();

    BluetoothDevice? device;

    for (BluetoothDevice d in devices) {
      if (d.name == "HC05") {
        device = d;
        break;
      }
    }

    if (device != null) {
      BluetoothConnection connection =
          await BluetoothConnection.toAddress(device.address);

      setState(() {
        this.connection = connection;
        connected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text(
                      "Left",
                      style: TextStyle(fontSize: 24.0),
                    ),
                    Text(
                      leftPoints.toString(),
                      style: const TextStyle(fontSize: 48.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _subtractLeftPoint,
                          icon: const Icon(Icons.remove),
                        ),
                        IconButton(
                          onPressed: _addLeftPoint,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      "Right",
                      style: TextStyle(fontSize: 24.0),
                    ),
                    Text(
                      rightPoints.toString(),
                      style: const TextStyle(fontSize: 48.0),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _subtractRightPoint,
                          icon: const Icon(Icons.remove),
                        ),
                        IconButton(
                          onPressed: _addRightPoint,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32.0),
            const Text(
              "Game Time",
              style: TextStyle(fontSize: 24.0),
            ),
            Text(
              "${gameTimeSeconds ~/ 60}:${(gameTimeSeconds % 60).toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 48.0),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _subtractTime,
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: 16.0),
                IconButton(
                  onPressed: _addTime,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _startStopTimer,
              child: Text(
                timerRunning ? "Stop Timer" : "Start Timer",
                style: const TextStyle(fontSize: 24.0),
              ),
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _connectToDevice,
              child: Text(
                connected ? "Connected" : "Connect to Device",
                style: const TextStyle(fontSize: 24.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
