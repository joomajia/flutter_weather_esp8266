// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:charts_flutter/flutter.dart' as charts;

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'ESP8266 Data Viewer',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   List<TemperatureData> temperatureDataList1 = [];
//   List<TemperatureData> temperatureDataList2 = [];

//   @override
//   void initState() {
//     super.initState();
//     fetchData1();
//     fetchData2();
//   }

//   Future<void> fetchData1() async {
//     await fetchData('http://192.168.238.152:80/getFile1', temperatureDataList1);
//   }

//   Future<void> fetchData2() async {
//     await fetchData('http://192.168.238.152:80/getFile2', temperatureDataList2);
//   }

//   Future<void> fetchData(String url, List<TemperatureData> dataList) async {
//     try {
//       final response = await http.get(Uri.parse(url));

//       if (response.statusCode == 200) {
//         final List<String> lines = response.body.split('\n');
//         List<TemperatureData> newDataItems = [];

//         for (String line in lines) {
//           List<String> values = line.split(' ');
//           if (values.length == 2) {
//             newDataItems.add(TemperatureData(
//               minutes: int.parse(values[0]),
//               temperature: double.parse(values[1]),
//             ));
//           }
//         }

//         setState(() {
//           dataList.clear();
//           dataList.addAll(newDataItems);
//         });
//       } else {
//         throw Exception(
//             'Failed to load data. Server responded with status code ${response.statusCode}');
//       }
//     } catch (error) {
//       print('Error fetching data: $error');
//     }
//   }

//   List<charts.Series<TemperatureData, String>> _getSeriesData1(List<TemperatureData> dataList) {
//   return [
//     charts.Series(
//       id: "Temperature",
//       data: dataList,
//       domainFn: (TemperatureData series, _) => series.minutes.toString(),
//       measureFn: (TemperatureData series, _) => series.temperature.toInt(),
//       colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
//     )
//   ];
// }

// List<charts.Series<TemperatureData, String>> _getSeriesData2(List<TemperatureData> dataList) {
//   return [
//     charts.Series(
//       id: "Temperature",
//       data: dataList,
//       domainFn: (TemperatureData series, _) => series.minutes.toString(),
//       measureFn: (TemperatureData series, _) => series.temperature,
//     )
//   ];
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Датчик'),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: Container(
//           height: 400,
//           padding: EdgeInsets.all(20),
//           child: Card(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: <Widget>[
//                   Text(
//                     "Температура по минутам (File 1)",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Expanded(
//                     child: charts.BarChart(
//                       _getSeriesData1(temperatureDataList1),
//                       animate: true,
//                       domainAxis: charts.OrdinalAxisSpec(
//                           renderSpec:
//                               charts.SmallTickRendererSpec(labelRotation: 60)),
//                     ),
//                   ),
//                   Text(
//                     "Температура по минутам (File 2)",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   SizedBox(
//                     height: 20,
//                   ),
//                   Expanded(
//                     child: charts.BarChart(
//                       _getSeriesData2(temperatureDataList2),
//                       animate: true,
//                       domainAxis: charts.OrdinalAxisSpec(
//                           renderSpec:
//                               charts.SmallTickRendererSpec(labelRotation: 60)),
//                     ),
//                   ),
//                   ElevatedButton(
//                     onPressed: () {
//                       fetchData1();
//                       fetchData2();
//                     },
//                     child: Text('Получить данные'),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class TemperatureData {
//   final int minutes;
//   final double temperature;

//   TemperatureData({required this.minutes, required this.temperature});
// }
