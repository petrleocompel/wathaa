import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wathaa/weatherWidget.dart';
import 'package:weather/weather.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supercharged/supercharged.dart';
import 'package:flutter/services.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp() : super();

  @override
  _MyAppState createState() => _MyAppState();
  // This widget is the root of your application.

}

class _MyAppState extends State<MyApp> {
  bool dark = false;

  void _toggleTheme() {
    setState(() {
      dark = !dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wathaa',
      theme: this.dark
          ? ThemeData.dark()
          : ThemeData.light().copyWith(
              backgroundColor: Colors.blue,
              textTheme: ThemeData.light().textTheme.apply(
                    bodyColor: Colors.white,
                    displayColor: Colors.white,
                  )),
      home: MyHomePage(themeToggle: this._toggleTheme),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Function themeToggle;
  MyHomePage({Key? key, required this.themeToggle}) : super(key: key);

  @override
  _MyHomePageState createState() =>
      _MyHomePageState(themeToggle: this.themeToggle);
}

class _MyHomePageState extends State<MyHomePage> {
  final Function themeToggle;
  DateTime refreshDate = DateTime.now();
  _MyHomePageState({required this.themeToggle}) : super();
  WeatherFactory wf = new WeatherFactory(dotenv.env['OPENWEATHER_API_KEY']!,
      language: Language.CZECH);
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(hours: 1), (Timer t) => refreshWeather());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<List<Weather>> updateWeather() async {
    return await wf.fiveDayForecastByLocation(
        49.695290435089184, 13.253240470640165);
  }

  void refreshWeather() {
    setState(() {
      refreshDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    Color? themeColor = Theme.of(context).textTheme.bodyText1!.color;
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        toolbarTextStyle: TextStyle(color: themeColor),
        actionsIconTheme: Theme.of(context).iconTheme,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Center(
              child: Text(
            DateFormat.Hms().format(this.refreshDate.toLocal()),
          )),
          IconButton(
            onPressed: this.refreshWeather,
            tooltip: 'Refresh',
            icon: Icon(Icons.refresh),
          ),
          IconButton(
              tooltip: 'Change theme',
              icon: Icon(Icons.brightness_medium),
              onPressed: () => this.themeToggle())
        ],
      ),
      body: Container(
        child: FutureBuilder<List<Weather>>(
          key: Key(this.refreshDate.toString()),
          future: updateWeather(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Weather>> snapshot) {
            if (snapshot.hasError) {
              return Column(
                children: [
                  Text("Chyba načtení"),
                  Text(snapshot.error.toString())
                ],
              );
            } else if (snapshot.hasData) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TodayWeatherWidget(snapshot.data!.first),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: IterableSC(snapshot.data!)
                            .withoutFirst()
                            .groupBy((element) =>
                                element.date!.day.toString() +
                                "-" +
                                element.date!.month.toString() +
                                "-" +
                                element.date!.year.toString())
                            .map((key, value) => MapEntry(key, value.first))
                            .values
                            .map((weather) => WeatherWidget(weather))
                            .toList())
                  ]);
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
