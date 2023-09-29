import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'db_helper.dart';
import 'dart:math';

class Application {
  static PackageInfo? appPackageInfo;
  static bool adWatched = true;
  static String appDBName = "WEATHER_BUDDY";
  static CustomCard curCardTheme = WeatherCards.lsCardThemes[Constants.objRandom.nextInt(WeatherCards.lsCardThemes.length)];
  static Color appPrimaryColor = const Color.fromARGB(255, 53, 24, 90);
  static Color appPrimaryLightColor = const Color.fromARGB(100, 53, 24, 90);
  static Color appPrimaryTextColor = appPrimaryColor;
  static Color appSecondaryColor = const Color.fromARGB(255, 139, 0, 139);
  static Color appDividerColor = Colors.black12;
  static Color appSecondaryTextColor = appSecondaryColor;
  static LinearGradient appLinearGradient = LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [appSecondaryColor, appPrimaryColor]);
  static TextStyle appHeadingTextStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: appPrimaryTextColor,
    fontSize: 20,
    shadows: const [
      Shadow(
        blurRadius: 10,
        color: Colors.black,
        offset: Offset(2, 0),
      ),
    ],
  );
}

class WeatherData {
  final String position;
  final String location;
  final DateTime date;
  final String maxCelsius;
  final String minCelsius;
  final String maxFahrenheit;
  final String minFahrenheit;
  final String condition;
  final String celsius;
  final String fahrenheit;
  final String humidity;
  final String cloud;
  final String windKMPH;
  final String windMPH;
  final String windDegree;
  final String windDirection;
  final String imagePath;
  WeatherData(this.position, this.location, this.date, this.maxCelsius, this.minCelsius, this.maxFahrenheit, this.minFahrenheit, this.condition, this.celsius, this.fahrenheit, this.humidity, this.cloud, this.windKMPH, this.windMPH, this.windDegree, this.windDirection, this.imagePath);
}

class DBConstants {
  static bool isCelsius = true;
  static int noOfFutureDays = 5;
}

class Weather {
  static String weatherForecastAPIKey = "WEATHER_FORECAST_API_KEY";
  static WeatherData curWeatherData = WeatherData("N/A", "N/A", DateTime.now(), "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A", "N/A");
  static List<FutureWeatherData> futureForecast = [];
}

class Constants {
  static String googleAPIKey = "GOOGLE_API_KEY";
  static DatabaseHelper dbHelper = DatabaseHelper.instance;
  static var decodedData;
  static Random objRandom = Random();
  static int curMenuIndex = 0;
  static CoOrdinates? curPosition;
  static String appActivePage = "home";
  static String curActivePage = "Dashboard";
  static bool isDrawerActive = false;
  static bool isSoftwareRestarted = true;
  static const String appErrorMessage = "Something went wrong! please check the internet and try again later.";
}

class CoOrdinates {
  final double longitude;
  final double latitude;
  CoOrdinates(this.longitude, this.latitude);
}

class ImagePaths {
  static const String appIcon = "assets/images/app_icon.jpg";
  static const String weatherSunny = "assets/images/weather_icons/sunny.gif";
  static const String weatherCloudy = "assets/images/weather_icons/cloudy.gif";
  static const String weatherFog = "assets/images/weather_icons/fog.gif";
  static const String weatherRainy = "assets/images/weather_icons/rainy.gif";
  static const String weatherSnow = "assets/images/weather_icons/snow.gif";
  static const String weatherStorm = "assets/images/weather_icons/storm.gif";
}

class CustomCard {
  final Color backColor;
  final Color borderColor;
  CustomCard(this.backColor, this.borderColor);
}

class WeatherCards {
  static CustomCard weatherCards = CustomCard(Colors.lightGreen.shade200, Colors.lightGreen);
  static CustomCard weatherSunny = CustomCard(const Color.fromARGB(100, 0, 192, 229), const Color.fromARGB(255, 0, 192, 229));
  static CustomCard weatherCloudy = CustomCard(const Color.fromARGB(100, 254, 166, 32), const Color.fromARGB(255, 254, 166, 32));
  static CustomCard weatherSnow = CustomCard(const Color.fromARGB(100, 118, 191, 224), const Color.fromARGB(255, 118, 191, 224));
  static CustomCard weatherRainy = CustomCard(const Color.fromARGB(100, 1, 66, 120), const Color.fromARGB(255, 1, 66, 120));
  static CustomCard weatherFog = CustomCard(const Color.fromARGB(100, 13, 170, 142), const Color.fromARGB(255, 13, 170, 142));
  static CustomCard weatherStorm = CustomCard(const Color.fromARGB(100, 119, 110, 155), const Color.fromARGB(255, 119, 110, 155));
  static List<CustomCard> lsCardThemes = [weatherSunny, weatherCloudy, weatherSnow, weatherRainy, weatherFog, weatherStorm];
}

class FutureWeatherData {
  final DateTime date;
  final String condition;
  final String maxCelsius;
  final String minCelsius;
  final String maxFahrenheit;
  final String minFahrenheit;
  final String imagePath;
  FutureWeatherData(this.date, this.condition, this.maxCelsius, this.minCelsius, this.maxFahrenheit, this.minFahrenheit, this.imagePath);
}