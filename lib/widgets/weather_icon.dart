import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

IconData? getWeatherIcon(String? weatherCondition) {
  if (kDebugMode) {
    print("Weather condition received: $weatherCondition");
  }
  switch (weatherCondition) {
    case 'Sunny':
      return WeatherIcons.day_sunny;
    case 'Cloudy':
      return WeatherIcons.cloudy;
    case 'Rain':
      return WeatherIcons.rain;
    case 'Snow':
      return WeatherIcons.snow;
    case 'StrongWind':
      return WeatherIcons.strong_wind;
    case 'Others':
      return null;
    default:
      return null;
  }
}