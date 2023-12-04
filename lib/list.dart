import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;

// void main() {
//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP8266 Data Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}


class TemperatureDataDS18B20 {
  final int minutes;
  final double temperature;

  TemperatureDataDS18B20({required this.minutes, required this.temperature});
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TemperatureDataDS18B20> temperatureDataList1 = [];

  List<TemperatureDataBME280> temperatureDataList2 = [];
  List<PressureDataBME280> pressureDataList2 = [];
  List<HumidityDataBME280> humidityDataList2 = [];

  SensorType selectedSensorType = SensorType.temperature;

  @override
  void initState() {
    super.initState();
    fetchData1();
    fetchData2();
  }

  Future<void> fetchData1() async {
    await fetchDataOne('http://192.168.238.152:80/getFile1', temperatureDataList1);
  }

  Future<void> fetchData2() async {
    await fetchDataTwo('http://192.168.238.152:80/getFile2', temperatureDataList2, pressureDataList2, humidityDataList2);
  }


    Future<void> fetchDataOne(String url, List<TemperatureDataDS18B20> dataList) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<String> lines = response.body.split('\n');
        List<TemperatureDataDS18B20> newDataItems = [];

        for (String line in lines) {
          List<String> values = line.split(' ');
          if (values.length == 2) {
            newDataItems.add(TemperatureDataDS18B20(
              minutes: int.parse(values[0]),
              temperature: double.parse(values[1]),
            ));
          }
        }

        setState(() {
          dataList.clear();
          dataList.addAll(newDataItems);
        });
      } else {
        throw Exception(
            'Failed to load data. Server responded with status code ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }


  Future<void> fetchDataTwo(String url, List<TemperatureDataBME280> temperatureList, List<PressureDataBME280> pressureList, List<HumidityDataBME280> humidityList) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<String> lines = response.body.split('\n');
        List<TemperatureDataBME280> newTemperatureData = [];
        List<PressureDataBME280> newPressureData = [];
        List<HumidityDataBME280> newHumidityData = [];

        for (String line in lines) {
          List<String> values = line.split(' ');
          if (values.length == 3) {
            newTemperatureData.add(TemperatureDataBME280(
              minutes: int.parse(values[0]),
              value: double.parse(values[1]),
            ));
            newPressureData.add(PressureDataBME280(
              minutes: int.parse(values[0]),
              value: double.parse(values[2]),
            ));
            newHumidityData.add(HumidityDataBME280(
              minutes: int.parse(values[0]),
              value: double.parse(values[3]),
            ));
          } else if (values.length == 2) {

            newTemperatureData.add(TemperatureDataBME280(
              minutes: int.parse(values[0]),
              value: double.parse(values[1]),
            ));
          }
        }

        setState(() {
          temperatureList.clear();
          temperatureList.addAll(newTemperatureData);

          pressureList.clear();
          pressureList.addAll(newPressureData);

          humidityList.clear();
          humidityList.addAll(newHumidityData);
        });
      } else {
        throw Exception(
            'Failed to load data. Server responded with status code ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  List<charts.Series<TemperatureDataDS18B20, String>> _getSeriesData1(
      List<TemperatureDataDS18B20> dataList) {
    return [
      charts.Series(
        id: "Temperature",
        data: dataList,
        domainFn: (TemperatureDataDS18B20 series, _) => series.minutes.toString(),
        measureFn: (TemperatureDataDS18B20 series, _) => series.temperature.toInt(),
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
      )
    ];
  }

  List<charts.Series<dynamic, String>> _getSeriesData2(List<dynamic> dataList, SensorType sensorType) {
    String title;
    charts.Color color;
    charts.Series<dynamic, String>? series;

    switch (sensorType) {
      case SensorType.temperature:
        title = 'Temperature';
        color = charts.MaterialPalette.blue.shadeDefault;
        series = charts.Series(
          id: title,
          data: dataList,
          domainFn: (dynamic series, _) => series.minutes,
          measureFn: (dynamic series, _) => series.value.toInt(),
          colorFn: (_, __) => color,
        );
        break;
      case SensorType.pressure:
        title = 'Pressure';
        color = charts.MaterialPalette.red.shadeDefault;
        series = charts.Series(
          id: title,
          data: dataList,
          domainFn: (dynamic series, _) => series.minutes,
          measureFn: (dynamic series, _) => series.value.toInt(),
          colorFn: (_, __) => color,
        );
        break;
      case SensorType.humidity:
        title = 'Влажность';
        color = charts.MaterialPalette.green.shadeDefault;
        series = charts.Series(
          id: title,
          data: dataList,
          domainFn: (dynamic series, _) => series.minutes,
          measureFn: (dynamic series, _) => series.value.toInt(),
          colorFn: (_, __) => color,
        );
        break;
    }

    return [series];
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: Text('Датчик'),
          centerTitle: true,
          bottom: TabBar(
            tabs: [
              Tab(text: 'File 1'),
              Tab(text: 'File 2'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            buildTabView1(temperatureDataList1),
            buildTabView2(temperatureDataList2, pressureDataList2, humidityDataList2),
          ],
        ),
      ),
    );
  }

    Widget buildTabView1(List<TemperatureDataDS18B20> dataList) {
    return Center(
      child: Container(
        height: 400,
        padding: EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Text(
                  "Температура земли",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: charts.BarChart(
                    _getSeriesData1(dataList),
                    animate: true,
                    domainAxis: charts.OrdinalAxisSpec(
                        renderSpec:
                            charts.SmallTickRendererSpec(labelRotation: 60)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    fetchData1(); // or fetchData2() depending on the tab
                  },
                  child: Text('Получить данные'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTabView2(List<TemperatureDataBME280> temperatureList, List<PressureDataBME280> pressureList, List<HumidityDataBME280> humidityList) {
    return Center(
      child: Container(
        height: 400,
        padding: EdgeInsets.all(20),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Показатели: ",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    DropdownButton<SensorType>(
                      value: selectedSensorType,
                      onChanged: (SensorType? newValue) {
                        setState(() {
                          selectedSensorType = newValue!;
                        });
                      },
                      items: SensorType.values.map<DropdownMenuItem<SensorType>>((SensorType value) {
                        return DropdownMenuItem<SensorType>(
                          value: value,
                          child: Text(value.toString().split('.').last),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Expanded(
                  child: charts.BarChart(
                    _getSeriesData2(getSelectedDataList(), selectedSensorType),
                    animate: true,
                    domainAxis: charts.OrdinalAxisSpec(
                      renderSpec: charts.SmallTickRendererSpec(labelRotation: 60),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    fetchData1(); // or fetchData2() depending on the tab
                  },
                  child: Text('Получить данные'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }



  List<dynamic> getSelectedDataList() {
    switch (selectedSensorType) {
      case SensorType.temperature:
        return temperatureDataList2;
      case SensorType.pressure:
        return pressureDataList2;
      case SensorType.humidity:
        return humidityDataList2;
    }
  }
}

enum SensorType {
  temperature,
  pressure,
  humidity,
}

class TemperatureDataBME280 {
  final int minutes;
  final double value;

  TemperatureDataBME280({required this.minutes, required this.value});
}

class PressureDataBME280 {
  final int minutes;
  final double value;

  PressureDataBME280({required this.minutes, required this.value});
}

class HumidityDataBME280 {
  final int minutes;
  final double value;

  HumidityDataBME280({required this.minutes, required this.value});
}
