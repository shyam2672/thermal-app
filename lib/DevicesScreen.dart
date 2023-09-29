import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class AvailableDevicesScreen extends StatefulWidget {
  const AvailableDevicesScreen({super.key});

  @override
  _AvailableDevicesScreenState createState() => _AvailableDevicesScreenState();
}

class _AvailableDevicesScreenState extends State<AvailableDevicesScreen> {
  Set<DeviceIdentifier> seen = {};
  late StreamSubscription<List<ScanResult>> subscription;

  @override
  void initState() {
    super.initState();
    FlutterBluePlus.startScan();
    subscription = FlutterBluePlus.scanResults.listen(
      (results) {
        for (ScanResult r in results) {
          if (seen.contains(r.device.id) == false) {
            print('${r.device.id}: "${r.device.name}" found! rssi: ${r.rssi}');
            seen.add(r.device.id);
          }
        }
      },
      onError: (e) => print(e),
    );
  }

  @override
  void dispose() {
    FlutterBluePlus.stopScan();
    subscription.cancel();
    super.dispose();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      device.connectionState.listen((BluetoothConnectionState state) async {
        if (state == BluetoothConnectionState.disconnected) {
          try {
            await device.connect(); // Reconnect
            await device.discoverServices(); // Re-discover services
            // Cancel subscriptions to characteristics if needed
          } catch (e) {
            print('Error while reconnecting: $e');
          }
        }
      });

      await device.connect();
      print(device.localName);
      // Re-discover services after connection
      await device.discoverServices();
    } catch (e) {
      // Handle connection error
      print('Error connecting to device: $e');
      throw e;
    }
  }

  Future<void> disconnectFromDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
    } catch (e) {
      // Handle disconnection error
      print('Error disconnecting from device: $e');
    }
  }

  void _onDeviceTileTap(BuildContext context, BluetoothDevice device) async {
    try {
      await connectToDevice(device);
      // print("connected");
      // print("FUCK");

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DeviceDataScreen(device: device),
        ),
      );
    } catch (e) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Connection Error'),
          content: Text('Unable to connect to device. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Available Devices'),
      ),
      body: StreamBuilder<List<ScanResult>>(
        stream: FlutterBluePlus.scanResults,
        initialData: [],
        builder: (context, snapshot) {
          final results = snapshot.data ?? [];
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final r = results[index];
              return ListTile(
                title: Text(r.device.name ?? 'Unknown Device'),
                subtitle: Text(r.device.id.toString()),
                onTap: () {
                  _onDeviceTileTap(context, r.device);

                  print('Tapped on device: ${r.device.name}');
                },
              );
            },
          );
        },
      ),
    );
  }
}

class DeviceDataScreen extends StatelessWidget {
  final BluetoothDevice device;

  DeviceDataScreen({required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //   appBar: AppBar(
        //     // title: Text(device.name),
        //   ),
        //   body: StreamBuilder<List<int>>(
        //     stream: device.,
        //     builder: (context, snapshot) {
        //       if (snapshot.connectionState == ConnectionState.active) {
        //         if (snapshot.hasData) {
        //           // Process and display received data
        //           final data = snapshot.data!;
        //           return Center(
        //             child: Text('Received Data: $data'),
        //           );
        //         } else {
        //           return Center(
        //             child: Text('No Data Received'),
        //           );
        //         }
        //       } else {
        //         return Center(
        //           child: CircularProgressIndicator(),
        //         );
        //       }
        //     },
        //   ),
        );
  }
}
