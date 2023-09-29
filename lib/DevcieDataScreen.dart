// class DeviceDataScreen extends StatelessWidget {
//   final BluetoothDevice device;

//   DeviceDataScreen({required this.device});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(device.name),
//       ),
//       body: StreamBuilder<List<int>>(
//         stream: device.receiveStream,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.active) {
//             if (snapshot.hasData) {
//               // Process and display received data
//               final data = snapshot.data!;
//               return Center(
//                 child: Text('Received Data: $data'),
//               );
//             } else {
//               return Center(
//                 child: Text('No Data Received'),
//               );
//             }
//           } else {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
