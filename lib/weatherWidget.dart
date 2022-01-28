import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

class TodayWeatherWidget extends StatelessWidget {
  final Weather weather;
  TodayWeatherWidget(this.weather, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Column(
          children: [
            Text(this.weather.temperature!.celsius!.toStringAsFixed(1) + "° C",
                style: Theme.of(context).textTheme.headline4),
            Image.network("https://openweathermap.org/img/wn/" +
                this.weather.weatherIcon! +
                "@4x.png"),
          ],
        ),
        Column(children: [
          Text(weekDay(this.weather.date!.weekday).capitalize(),
              style: Theme.of(context).textTheme.headline5),
          Text(this.weather.areaName!.capitalize()),
          Text(this.weather.weatherDescription!.capitalize(),
              style: Theme.of(context).textTheme.headline5),
        ]),
      ],
    ));
  }
}

class WeatherWidget extends StatelessWidget {
  final Weather weather;
  WeatherWidget(this.weather, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        Text(this.weather.temperature!.celsius!.toStringAsFixed(1) + "° C",
            style: Theme.of(context).textTheme.headline6),
        Text(this.weather.weatherDescription!.capitalize()),
        Text(weekDay(this.weather.date!.weekday).capitalize(),
            style: Theme.of(context).textTheme.subtitle2),
        Image.network("https://openweathermap.org/img/wn/" +
            this.weather.weatherIcon! +
            "@2x.png")
      ]),
    );
  }
}

String weekDay(int weekday) {
  switch (weekday) {
    case DateTime.monday:
      return "pondělí";
    case DateTime.tuesday:
      return "úterý";
    case DateTime.wednesday:
      return "středa";
    case DateTime.thursday:
      return "čtvrtek";
    case DateTime.friday:
      return "pátek";
    case DateTime.saturday:
      return "sobota";
    case DateTime.sunday:
      return "neděle";
    default:
      throw Exception("Invalid week day");
  }
}
