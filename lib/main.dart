import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_blue/quick_blue.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/scheduler.dart' show timeDilation;

bool connected = false; // Status of Bluetooth connection

class ScoreboardScreen extends StatefulWidget {
  @override
  _ScoreboardScreenState createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  List<BluetoothDeviceUI> devices = [
    BluetoothDeviceUI(
      name: 'Device 1',
      uiElements: [
        BluetoothUIElement(
            type: UIElementType.integer, label: 'Score', value: 0),
        BluetoothUIElement(
            type: UIElementType.string, label: 'Team', value: 'Team A'),
      ],
    ),
    BluetoothDeviceUI(
      name: 'Device 2',
      uiElements: [
        BluetoothUIElement(
            type: UIElementType.integer, label: 'Score', value: 0),
        BluetoothUIElement(
            type: UIElementType.timer, label: 'Game Timer', value: 0),
      ],
    ),
  ];

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
      darkTheme: ThemeData(
        brightness: _brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: _brightness,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: _brightness,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: _brightness,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.latoTextTheme(
            Theme.of(context).textTheme), // Use 'Lato' font
        primarySwatch: Colors.deepPurple,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.lato().fontFamily, // Use 'Lato' font
          ),
        ),
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Scoreboard'), actions: [
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
          )
        ]),
        body: ListView(
          children: [
            BluetoothConnectionOption(),
            Divider(),
            ...devices
                .map((device) => BluetoothDeviceContainer(device: device))
                .toList(),
          ],
        ),
      ),
    );
  }
}

class BluetoothConnectionOption extends StatefulWidget {
  @override
  _BluetoothConnectionOptionState createState() =>
      _BluetoothConnectionOptionState();
}

class _BluetoothConnectionOptionState extends State<BluetoothConnectionOption> {
  bool expanded = false;
  List<BlueScanResult> nearbyDevices = [];
  bool isBluetoothEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBluetoothEnabled();
  }

  Future<void> _checkBluetoothEnabled() async {
    isBluetoothEnabled = await QuickBlue.isBluetoothAvailable();
    setState(() {});
  }

  void _startScan() {
    QuickBlue.startScan();
    QuickBlue.scanResultStream.listen((device) {
      if (!nearbyDevices.contains(device)) {
        setState(() {
          nearbyDevices.add(device);
        });
      }
    });
  }

  void _stopScan() {
    QuickBlue.stopScan();
  }

  @override
  void dispose() {
    _stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _checkBluetoothEnabled();
    return Column(
      children: [
        ListTile(
          title: Text('Bluetooth Connection'),
          trailing: _buildBluetoothIcon(),
          onTap: () {
            setState(() {
              expanded = !expanded;
              if (expanded) {
                _startScan();
              } else {
                _stopScan();
              }
            });
          },
        ),
        if (expanded)
          Column(
            children: [
              if (!isBluetoothEnabled)
                ListTile(
                  title: Text('Bluetooth is turned off'),
                  onTap: () {
                    // Handle enabling Bluetooth
                    // QuickBlue.instance.enableBluetooth();
                  },
                ),
              if (isBluetoothEnabled)
                Column(
                  children: nearbyDevices
                      .map(
                        (device) => ListTile(
                          title: Text(device.name),
                          onTap: () {
                            // Handle connecting to the selected Bluetooth device
                            // You can use the 'device' object for connection logic
                          },
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildBluetoothIcon() {
    if (isBluetoothEnabled) {
      return Icon(Icons.bluetooth_connected);
    } else {
      return Icon(Icons.bluetooth_disabled);
    }
  }
}

class BluetoothDeviceUI {
  final String name;
  final List<BluetoothUIElement> uiElements;

  BluetoothDeviceUI({required this.name, required this.uiElements});
}

enum UIElementType { integer, string, timer }

class BluetoothUIElement {
  final UIElementType type;
  final String label;
  dynamic value;

  BluetoothUIElement(
      {required this.type, required this.label, required this.value});
}

class BluetoothDeviceContainer extends StatefulWidget {
  final BluetoothDeviceUI device;

  BluetoothDeviceContainer({required this.device});

  @override
  _BluetoothDeviceContainerState createState() =>
      _BluetoothDeviceContainerState();
}

class _BluetoothDeviceContainerState extends State<BluetoothDeviceContainer>
    with SingleTickerProviderStateMixin {
  bool expanded = false;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(widget.device.name),
          onTap: () {
            setState(() {
              expanded = !expanded;
              if (expanded) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            });
          },
        ),
        SizeTransition(
          sizeFactor: _animation,
          child: Column(
            children: widget.device.uiElements
                .map((element) => buildUIElement(element))
                .toList(),
          ),
        ),
        Divider(),
      ],
    );
  }

  Widget buildUIElement(BluetoothUIElement element) {
    switch (element.type) {
      case UIElementType.integer:
        return ListTile(
          title: Text(element.label),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    element.value -= 1;
                  });
                },
              ),
              Text('${element.value}'),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    element.value += 1;
                  });
                },
              ),
            ],
          ),
        );
      case UIElementType.string:
        return ListTile(
          title: Text(element.label),
          trailing: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => EditStringDialog(value: element.value),
              ).then((newValue) {
                if (newValue != null) {
                  setState(() {
                    element.value = newValue;
                  });
                }
              });
            },
            child: Text('${element.value}'),
          ),
        );
      case UIElementType.timer:
        return ListTile(
          title: Text(element.label),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  setState(() {
                    element.value -= 1;
                  });
                },
              ),
              Text('${element.value}'),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    element.value += 1;
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.play_arrow),
                onPressed: () {
                  // Start timer logic
                },
              ),
              IconButton(
                icon: Icon(Icons.stop),
                onPressed: () {
                  // Stop timer logic
                },
              ),
            ],
          ),
        );
    }
  }
}

class EditStringDialog extends StatefulWidget {
  final String value;

  const EditStringDialog({required this.value});

  @override
  _EditStringDialogState createState() => _EditStringDialogState();
}

class _EditStringDialogState extends State<EditStringDialog> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.value);
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit String'),
      content: TextFormField(
        controller: _textEditingController,
        autofocus: true,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(
          fontSize: 16.0,
          color: Colors.black87,
        ),
      ),
      actions: [
        TextButton.icon(
          icon: Icon(Icons.cancel),
          label: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton.icon(
          icon: Icon(Icons.save),
          label: Text('Save'),
          onPressed: () {
            final newValue = _textEditingController.text;
            Navigator.pop(context, newValue);
          },
        ),
      ],
    );
  }
}

void main() {
  runApp(ScoreboardScreen());
}
