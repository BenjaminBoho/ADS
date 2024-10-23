import 'package:flutter/material.dart';
import 'package:weather_icons/weather_icons.dart';

IconData? getWeatherIcon(String? weatherCondition) {
  switch (weatherCondition) {
    case '晴れ':
    case '晴':
      return WeatherIcons.day_sunny;
    case '曇り':
    case '曇':
      return WeatherIcons.cloudy;
    case '雨':
      return WeatherIcons.rain;
    case '雪':
      return WeatherIcons.snow;
    case '強風':
      return WeatherIcons.strong_wind;
    case 'その他':
      return null;
    default:
      return null;
  }
}