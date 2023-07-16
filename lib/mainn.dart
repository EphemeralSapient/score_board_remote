import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

BuildContext? _context;

void snackbar(String text) {
  ScaffoldMessenger.of(_context!).showSnackBar(SnackBar(content: Text(text)));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Brightness _brightness = Brightness.light;

  void _toggleBrightness() {
    setState(() {
      _brightness =
          _brightness == Brightness.light ? Brightness.dark : Brightness.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Score board control',
      theme: ThemeData(
        brightness: _brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: _brightness,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: _brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: _brightness,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: Stack(
        children: [
          Scaffold(
            appBar: AppBar(
              title: const Text('Control Interface'),
              actions: [
                PopupMenuButton<Brightness>(
                  onSelected: (brightness) {
                    setState(() {
                      _brightness = brightness;
                    });
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: Brightness.light,
                      child: Text('Light theme'),
                    ),
                    const PopupMenuItem(
                      value: Brightness.dark,
                      child: Text('Dark theme'),
                    ),
                  ],
                ),
              ],
            ),
            body: const ControlInterface(),
          ),
        ],
      ),
    );
  }
}

class ControlInterface extends StatefulWidget {
  const ControlInterface({super.key});

  @override
  _ControlInterfaceState createState() => _ControlInterfaceState();
}

class _ControlInterfaceState extends State<ControlInterface> {
  BluetoothConnection? connection;
  bool isConnected = false;
  List<int> points = [0, 0]; // initialize with two zeros
  int time = 0;
  bool isRunning = false;

  void connectToDevice() async {
    BluetoothDevice selectedDevice = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const DiscoveryPage(),
      ),
    );

    await BluetoothConnection.toAddress(selectedDevice.address)
        .then((_connection) {
      snackbar('Connected to the device');
      setState(() {
        connection = _connection;
        isConnected = true;
      });
    }).catchError((error) {
      snackbar('Cannot connect, exception occurred | $error');
      debugPrint(error);
    });
  }

  void check() {
    if (isConnected == false) {
      snackbar("Device is not connected!");
    } else if (isRunning == false) {
      snackbar("Scoreboard is not running!");
    }
  }

  void addPointLeft() {
    if (isConnected && isRunning) {
      connection!.output.add(ascii.encode('l+'));
      setState(() {
        points[0]++;
        snackbar("+1 left points");
      });
    } else {
      check();
    }
  }

  void subtractPointLeft() {
    if (isConnected && isRunning) {
      connection!.output.add(ascii.encode('l-'));
      setState(() {
        points[0]--;
        snackbar("-1 left points");
      });
    } else {
      check();
    }
  }

  void addPointRight() {
    if (isConnected && isRunning) {
      connection!.output.add(ascii.encode('r+'));
      setState(() {
        points[1]++;
        snackbar("+1 right points");
      });
    } else {
      check();
    }
  }

  void subtractPointRight() {
    if (isConnected && isRunning) {
      connection!.output.add(ascii.encode('r-'));
      setState(() {
        points[1]--;
        snackbar("-1 right points");
      });
    } else {
      check();
    }
  }

  void addTime() {
    if (isConnected && isRunning) {
      connection!.output.add(ascii.encode('t+'));
      setState(() {
        time++;
        snackbar("+1 sec");
      });
    } else {
      check();
    }
  }

  void subtractTime() {
    if (isConnected && isRunning) {
      connection!.output.add(ascii.encode('t-'));
      setState(() {
        time--;
        snackbar("-1 sec");
      });
    } else {
      check();
    }
  }

  void startGame() {
    if (isConnected && isRunning) {
      connection!.output.add(ascii.encode('s'));
      setState(() {
        isRunning = true;
        snackbar("Stopped the timer");
      });
    } else {
      check();
    }
  }

  void stopGame() {
    if (isConnected && isRunning) {
      connection!.output.add(ascii.encode('x'));
      setState(() {
        isRunning = false;
        snackbar("Started the timer");
      });
    } else {
      check();
    }
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isConnected ? 'Connected' : 'Not connected',
                  style: TextStyle(
                    color: isConnected ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 20),
                Text(
                  isRunning ? 'Running' : 'Not running',
                  style: TextStyle(
                    color: isRunning ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text(
                      'Left',
                      style: TextStyle(fontSize: 24),
                    ),
                    Text(
                      '${points[0]}',
                      style: const TextStyle(fontSize: 32),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: addPointLeft,
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: subtractPointLeft,
                          child: const Icon(Icons.remove),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Right',
                      style: TextStyle(fontSize: 24),
                    ),
                    Text(
                      '${points[1]}',
                      style: const TextStyle(fontSize: 32),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: addPointRight,
                          child: const Icon(Icons.add),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: subtractPointRight,
                          child: const Icon(Icons.remove),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Time: $time sec',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: startGame,
                  child: const Text('Start'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: stopGame,
                  child: const Text('Stop'),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: connectToDevice,
        child: const Icon(Icons.bluetooth),
      ),
    );
  }
}

class DiscoveryPage extends StatefulWidget {
  const DiscoveryPage({super.key});

  @override
  _DiscoveryPageState createState() => _DiscoveryPageState();
}

class _DiscoveryPageState extends State<DiscoveryPage> {
  List<BluetoothDiscoveryResult> results = [];

  bool isDiscovering = false;

  void startDiscovery() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    // Check if the permissions have been granted
    if (statuses[Permission.bluetoothScan] == PermissionStatus.granted &&
        statuses[Permission.bluetooth] == PermissionStatus.granted &&
        statuses[Permission.location] == PermissionStatus.granted) {
      setState(() {
        results.clear();
        isDiscovering = true;
        snackbar("Search operation begun");
      });

      FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
        setState(() {
          results.add(result);
        });
      }, onDone: () {
        setState(() {
          isDiscovering = false;
          snackbar("Search operation completed");
        });
      });
    } else {
      snackbar("Please enable the permission to search");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a device'),
      ),
      body: ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          BluetoothDiscoveryResult result = results[index];
          return ListTile(
            title: Text(result.device.name ?? 'Unknown device'),
            subtitle: Text(result.device.address),
            trailing: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(result.device);
              },
              child: const Text('Connect'),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: startDiscovery,
        child: const Icon(Icons.search),
      ),
    );
  }
}
