# Scoreboard Control App

The Scoreboard Control App is a Flutter application that enables wireless control of a scoreboard's left board and right board points and timer start/stop functionalities. It achieves this by establishing communication with an HC-05 Bluetooth module, allowing users to operate the scoreboard conveniently from their mobile devices.
## Installation

You can install the app by accessing the install/android/{your mobile arch}.apk file.

Alternatively, you can follow these steps to install the Scoreboard Control App:

1.    Ensure that you have Flutter installed on your machine.
2.    Clone this repository to your local environment.
3.    Run flutter pub get to install the necessary dependencies.
4.    Use flutter run to launch the app on your Android device.


## Features

The Scoreboard Control App offers the following features:

-    Left and right point control: Seamlessly update the scoreboard's left and right points using the app.
-    Timer start/stop: Effortlessly initiate or halt the timer functionality on the scoreboard.

## Troubleshooting

If you are having trouble connecting to the HC-05 module, make sure that your mobile device has Bluetooth turned on and that the HC-05 module is powered on and in discoverable mode. If you continue to experience issues, try restarting your mobile device and the HC-05 module.

Also make sure to enable the bluetooth permission from android prompt.

## Acknowledgments

This app uses the `flutter_bluetooth_serial` package for Bluetooth communication.

## License

This app is licensed under the GPL-3.0 license.