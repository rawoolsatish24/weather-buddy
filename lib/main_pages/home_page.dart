import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weatherbuddy/utils/common_classes.dart';
import 'package:weatherbuddy/utils/common_methods.dart';
import 'package:weatherbuddy/utils/permissions.dart';

class HomePage extends StatefulWidget {
  Function callback;
  HomePage(this.callback);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoaded = false;
  var size;

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    _isLoaded = false;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      if(Constants.isSoftwareRestarted) {
        EasyLoading.show(status: "Loading...");
        Constants.isSoftwareRestarted = false;
        await Constants.dbHelper.loadWeather();
        if(Weather.curWeatherData.position == "N/A" || Weather.futureForecast.isEmpty) { Constants.dbHelper.clearWeatherData(); }
        else {
          EasyLoading.dismiss();
          setState(() {});
          return;
        }
      }
      await loadData();
    });
  }

  Future<void> loadData({bool refreshPage = false}) async {
    if(Constants.curPosition == null) {
      Position? curPosition = await getCurrentPosition();
      if(curPosition != null) {
        Constants.curPosition = CoOrdinates(curPosition.longitude, curPosition.latitude);
        await fetchWeatherData();
      }
    } else { await fetchWeatherData(); }
    if(Constants.appActivePage == "home") { setState(() {}); }
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        EasyLoading.show(status: "Refreshing data...");
        await loadData(refreshPage: true);
      },
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8, right: 8,),
            child: Container(
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                border: Border.all(width: 4, color: Application.curCardTheme.borderColor),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Application.curCardTheme.backColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      DateFormat('dd MMM, yyyy').format(Weather.curWeatherData.date),
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8,),
                      child: Text(
                        Weather.curWeatherData.location,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              // Image.asset(ImagePaths.weatherSunny, height: 125.0, width: 125.0,),
                              // (Weather.curWeatherData.imagePath != "N/A")
                              //   ? Image.network(Weather.curWeatherData.imagePath, height: 125.0, width: 125.0, fit: BoxFit.cover,)
                              //   : Container(),
                              (Weather.curWeatherData.imagePath != "N/A")
                                ? CachedNetworkImage(
                                  height: 125.0,
                                  width: 125.0,
                                  fit: BoxFit.cover,
                                  imageUrl: Weather.curWeatherData.imagePath,
                                  placeholder: (context, url) => const CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => const Icon(Icons.image_not_supported_outlined),
                                )
                                : Container(),
                              Text(
                                Weather.curWeatherData.condition,
                                style: const TextStyle(color: Colors.white, fontSize: 18),
                                textAlign: TextAlign.center,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  DBConstants.isCelsius = (DBConstants.isCelsius) ? false : true;
                                  if(DBConstants.isCelsius) { Constants.dbHelper.updateSetting("ISCELSIUS", "TRUE"); }
                                  else { Constants.dbHelper.updateSetting("ISCELSIUS", "FALSE"); }
                                  setState(() {});
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8,),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        (DBConstants.isCelsius) ? Weather.curWeatherData.celsius : Weather.curWeatherData.fahrenheit,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36),
                                        textAlign: TextAlign.center,
                                      ),
                                      Transform.translate(
                                        offset: const Offset(0, -7),
                                        child: const Text(
                                          "o",
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      Text(
                                        (DBConstants.isCelsius) ? "C" : "F",
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  getWeatherData("Max. Temp", (DBConstants.isCelsius) ? Weather.curWeatherData.maxCelsius : Weather.curWeatherData.maxFahrenheit),
                                  Transform.translate(
                                    offset: const Offset(0, -7),
                                    child: const Text(
                                      "o",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  getWeatherData("Min. Temp", (DBConstants.isCelsius) ? Weather.curWeatherData.minCelsius : Weather.curWeatherData.minFahrenheit),
                                  Transform.translate(
                                    offset: const Offset(0, -7),
                                    child: const Text(
                                      "o",
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              getWeatherData("Humidity", Weather.curWeatherData.humidity),
                              getWeatherData("Cloud", Weather.curWeatherData.cloud),
                              getWeatherData("Wind (kmph)", Weather.curWeatherData.windKMPH),
                              getWeatherData("Wind (mph)", Weather.curWeatherData.windMPH),
                              getWeatherData("Wind Degree", Weather.curWeatherData.windDegree),
                              getWeatherData("Wind Direction", Weather.curWeatherData.windDirection),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 8, right: 8,),
            child: IntrinsicHeight(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [for(int z = 0; z < Weather.futureForecast.length; z++) Padding(
                    padding: const EdgeInsets.all(0.5),
                    child: Container(
                      width: 80,
                      decoration: BoxDecoration(
                        border: Border.all(width: 2, color: WeatherCards.weatherCards.borderColor),
                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                        color: WeatherCards.weatherCards.backColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              DateFormat('EEEE').format(Weather.futureForecast[z].date).substring(0, 3),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              DateFormat('dd/MM').format(Weather.futureForecast[z].date),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(color: Colors.lightGreen, thickness: 2,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  (DBConstants.isCelsius) ? Weather.futureForecast[z].maxCelsius : Weather.futureForecast[z].maxFahrenheit,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                                Transform.translate(
                                  offset: const Offset(0, -6),
                                  child: const Text(
                                    "o",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                            Divider(color: Colors.lightGreen, thickness: 2,),
                            Expanded(
                              // child: Image.asset(ImagePaths.weatherCloudy),
                              // child: Image.network(Weather.futureForecast[z].imagePath),
                              child: CachedNetworkImage(
                                imageUrl: Weather.futureForecast[z].imagePath,
                                placeholder: (context, url) => const CircularProgressIndicator(),
                                errorWidget: (context, url, error) => const Icon(Icons.image_not_supported_outlined),
                              ),
                            ),
                            Text(
                              Weather.futureForecast[z].condition,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold,),
                              textAlign: TextAlign.center,
                            ),
                            const Divider(color: Colors.lightGreen, thickness: 2,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  (DBConstants.isCelsius) ? Weather.futureForecast[z].minCelsius : Weather.futureForecast[z].minFahrenheit,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                  textAlign: TextAlign.center,
                                ),
                                Transform.translate(
                                  offset: const Offset(0, -6),
                                  child: const Text(
                                    "o",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  )],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
