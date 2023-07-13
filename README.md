# Scoreboard Control App

This is a Flutter application that communicates with an HC-05 Bluetooth module to control a scoreboard's "left and right point" and "timer start/stop" features wirelessly from a mobile device.

## Installation

You can install it from install/android/{your mobile arch}.apk

OR

To install the Scoreboard Control App, you will need to have Flutter installed on your machine. Once Flutter is installed, you can clone this repository and run `flutter pub get` to install the necessary dependencies. You can then run the app on an Android or iOS device using `flutter run`.

## Usage

To use the Scoreboard Control App, follow these steps:

1. Turn on Bluetooth on your mobile device.
2. Power on the HC-05 Bluetooth module.
3. Open the Scoreboard Control App on your mobile device.
4. Tap the "Connect" button to search for and connect to the HC-05 module.
5. Once connected, use the app to control the scoreboard's "left and right point" and "timer start/stop" features.

## Features

The Scoreboard Control App has the following features:

- Left and right point control: Use the app to update the scoreboard's left and right points as needed.
- Timer start/stop: Use the app to start and stop the scoreboard's timer.

## Troubleshooting

If you are having trouble connecting to the HC-05 module, make sure that your mobile device has Bluetooth turned on and that the HC-05 module is powered on and in discoverable mode. If you continue to experience issues, try restarting your mobile device and the HC-05 module.

## Acknowledgments

This app uses the `flutter_bluetooth_serial` package for Bluetooth communication.

## License

This app is licensed under the MIT License.