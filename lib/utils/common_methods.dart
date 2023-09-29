import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:weatherbuddy/utils/common_classes.dart';
import 'api_network.dart';

Future<void> fetchWeatherData() async {
  try {
    Uri weatherURI = Uri.https( "api.weatherapi.com", "v1/forecast.json", { "q": '${Constants.curPosition!.latitude},${Constants.curPosition!.longitude}', "days": (DBConstants.noOfFutureDays + 1).toString(), "key": Weather.weatherForecastAPIKey, } );
    Constants.decodedData = await APINetwork.fetchURL(weatherURI);
    if(Constants.decodedData == null) {
      EasyLoading.showError(Constants.appErrorMessage);
      return;
    }
    Constants.decodedData = jsonDecode(Constants.decodedData);
    if(Constants.decodedData.toString().contains("location")  && Constants.decodedData.toString().contains("current")) {
      Weather.futureForecast = [];
      var curLocationData = Constants.decodedData["location"];
      var curWeatherData = Constants.decodedData["current"];
      var lsForecastData = Constants.decodedData["forecast"]["forecastday"];
      Weather.curWeatherData = WeatherData(
        "${curLocationData["lat"]},${curLocationData["lon"]}",
        "${curLocationData["name"]}, ${curLocationData["region"]}, ${curLocationData["country"]}",
        DateFormat('yyyy-MM-dd').parse(lsForecastData[0]["date"].toString()),
        lsForecastData[0]["day"]["maxtemp_c"].toString(),
        lsForecastData[0]["day"]["mintemp_c"].toString(),
        lsForecastData[0]["day"]["maxtemp_f"].toString(),
        lsForecastData[0]["day"]["mintemp_f"].toString(),
        curWeatherData["condition"]["text"].toString(),
        curWeatherData["temp_c"].toString(),
        curWeatherData["temp_f"].toString(),
        "${curWeatherData["humidity"]}%",
        "${curWeatherData["cloud"]}%",
        curWeatherData["wind_kph"].toString(),
        curWeatherData["wind_mph"].toString(),
        curWeatherData["wind_degree"].toString(),
        curWeatherData["wind_dir"].toString(),
        "https:${curWeatherData["condition"]["icon"]}",
      );
      for (int z = 1; z < lsForecastData.length; z++) {
        var curData = lsForecastData[z];
        Weather.futureForecast.add(
            FutureWeatherData(
              DateFormat('yyyy-MM-dd').parse(curData["date"].toString()),
              curData["day"]["condition"]["text"].toString(),
              curData["day"]["maxtemp_c"].toString(),
              curData["day"]["mintemp_c"].toString(),
              curData["day"]["maxtemp_f"].toString(),
              curData["day"]["mintemp_f"].toString(),
              "https:${curData["day"]["condition"]["icon"]}",
            )
        );
      }
      await Constants.dbHelper.updateWeather();
      return;
    }
  } catch (ex) { print(ex.toString()); }
  EasyLoading.showError(Constants.appErrorMessage);
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskType = EasyLoadingMaskType.black
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..toastPosition = EasyLoadingToastPosition.center
    ..animationStyle = EasyLoadingAnimationStyle.scale
    ..userInteractions = false
    ..dismissOnTap = false;
}

Future<void> resetApplication() async {
  await Constants.dbHelper.connectToDatabase();
  await Constants.dbHelper.checkDefaultTables();
  await Constants.dbHelper.checkSetting();
}

Widget getWeatherData(String name, String value) {
  return RichText(
    text: TextSpan(
      text: "$name : ",
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold,),
      children: <TextSpan>[
        TextSpan(text: value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.normal,),),
      ],
    ),
  );
}

bool isMovementDone(Position? startPosition, Position endPosition) {
  if(startPosition == null) { return true; }
  return (startPosition.longitude.toStringAsFixed(3) != startPosition.longitude.toStringAsFixed(3) || startPosition.latitude.toStringAsFixed(3) != startPosition.latitude.toStringAsFixed(3));
}

Future<bool> checkInternet() async {
  try {
    final result = await InternetAddress.lookup('Google.Com');
    return (result. isNotEmpty && result[0]. rawAddress. isNotEmpty);
  } on SocketException catch (_) { return false; }
}