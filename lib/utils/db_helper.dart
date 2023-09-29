import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/utils/utils.dart';
import 'package:weatherbuddy/utils/common_classes.dart';
import 'package:weatherbuddy/utils/common_methods.dart';

class DatabaseHelper {
  late Database curActiveDatabase;
  late Directory dbDirectory;
  late String path, query, tmpStr, tmpStr1;
  final dbVersion = 1;
  late int intCounts;

  DatabaseHelper.privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper.privateConstructor();

  Future connectToDatabase() async {
    dbDirectory = await getApplicationDocumentsDirectory();
    path = join(dbDirectory.path, Application.appDBName);
    curActiveDatabase = await openDatabase(path, version: dbVersion);
  }

  Future<void> resetDatabase() async {
    await instance.connectToDatabase();
    await curActiveDatabase.close();
    await deleteDatabase(path);
  }

  Future updateSetting(String settingName, String settingValue) async {
    query = "delete from SETTING where Name = '$settingName';";
    await sqlQuery(query, ["SETTING"]);
    query = "insert into SETTING (Name, Value) values('$settingName', '$settingValue');";
    await sqlQuery(query, ["SETTING"]);
  }

  Future updateWeather() async {
    if(Weather.curWeatherData.position != "N/A") {
      await clearWeatherData();
      query = "insert into CURRENTWEATHER (Position, Location, Date, MaxCelsius, MinCelsius, MaxFahrenheit, MinFahrenheit, Condition, Celsius, Fahrenheit, Humidity, Cloud, WindKMPH, WindMPH, WindDegree, WindDirection, ImagePath) values('${Weather.curWeatherData.position}', '${Weather.curWeatherData.location}', '${Weather.curWeatherData.date}', '${Weather.curWeatherData.maxCelsius}', '${Weather.curWeatherData.minCelsius}', '${Weather.curWeatherData.maxFahrenheit}', '${Weather.curWeatherData.minFahrenheit}', '${Weather.curWeatherData.condition}', '${Weather.curWeatherData.celsius}', '${Weather.curWeatherData.fahrenheit}', '${Weather.curWeatherData.humidity}', '${Weather.curWeatherData.cloud}', '${Weather.curWeatherData.windKMPH}', '${Weather.curWeatherData.windMPH}', '${Weather.curWeatherData.windDegree}', '${Weather.curWeatherData.windDirection}', '${Weather.curWeatherData.imagePath}');";
      await sqlQuery(query, ["CURRENTWEATHER"]);
      for (int z = 0; z < Weather.futureForecast.length; z++) {
        var curData = Weather.futureForecast[z];
        query = "insert into FUTUREWEATHER (Id, Date, Condition, MaxCelsius, MinCelsius, MaxFahrenheit, MinFahrenheit, ImagePath) values('${z + 1}', '${curData.date}', '${curData.condition}', '${curData.maxCelsius}', '${curData.minCelsius}', '${curData.maxFahrenheit}', '${curData.minFahrenheit}', '${curData.imagePath}');";
        await sqlQuery(query, ["FUTUREWEATHER"]);
      }
    }
  }

  Future clearWeatherData() async {
    query = "delete from FUTUREWEATHER;";
    await sqlQuery(query, ["FUTUREWEATHER"]);
    query = "delete from CURRENTWEATHER;";
    await sqlQuery(query, ["CURRENTWEATHER"]);
  }

  Future loadWeather() async {
    Weather.futureForecast = [];
    List<Map<String, dynamic>> sqlSelectResult = await curActiveDatabase.query('CURRENTWEATHER');
    if(sqlSelectResult.isNotEmpty) {
      List<String> lsCurPosition = sqlSelectResult[0]["Position"].toString().split(",");
      Constants.curPosition = CoOrdinates(double.parse(lsCurPosition[1]), double.parse(lsCurPosition[0]));
      Weather.curWeatherData = WeatherData(
        sqlSelectResult[0]["Position"],
        sqlSelectResult[0]["Location"],
        DateTime.parse(sqlSelectResult[0]["Date"]),
        sqlSelectResult[0]["MaxCelsius"],
        sqlSelectResult[0]["MinCelsius"],
        sqlSelectResult[0]["MaxFahrenheit"],
        sqlSelectResult[0]["MinFahrenheit"],
        sqlSelectResult[0]["Condition"],
        sqlSelectResult[0]["Celsius"],
        sqlSelectResult[0]["Fahrenheit"],
        sqlSelectResult[0]["Humidity"],
        sqlSelectResult[0]["Cloud"],
        sqlSelectResult[0]["WindKMPH"],
        sqlSelectResult[0]["WindMPH"],
        sqlSelectResult[0]["WindDegree"],
        sqlSelectResult[0]["WindDirection"],
        sqlSelectResult[0]["ImagePath"]
      );
    }
    sqlSelectResult = await curActiveDatabase.query('FUTUREWEATHER', orderBy: 'Id');
    for (int z = 0; z < sqlSelectResult.length; z++) {
      var curData = sqlSelectResult[z];
      Weather.futureForecast.add(
        FutureWeatherData(
          DateTime.parse(curData["Date"]),
          curData["Condition"],
          curData["MaxCelsius"],
          curData["MinCelsius"],
          curData["MaxFahrenheit"],
          curData["MinFahrenheit"],
          curData["ImagePath"]
        )
      );
    }
  }

  Future checkDefaultTables() async {
    if(await checkIfTableExists("SETTING") == false) { createSetting(); }
    if(await checkIfTableExists("FUTUREWEATHER") == false) { createFutureWeather(); }
    if(await checkIfTableExists("CURRENTWEATHER") == false) { createCurrentWeather(); }
  }

  Future<bool> checkIfTableExists(String strTableName) async {
    query = "Select count(*) from sqlite_master Where type = 'table' and name = '$strTableName';";
    intCounts = await sqlCounter(query, ["sqlite_master"]);
    if(intCounts == 0) { return false; } else { return true; }
  }

  Future checkSetting() async {
    DBConstants.isCelsius = await checkResetTheme("ISCELSIUS", "TRUE");
    DBConstants.noOfFutureDays = await checkResetTheme("NOOFDAYS", "5");
  }

  Future<dynamic> checkResetTheme(String settingName, String defaultValue) async {
    String curMode;
    query = "Select count(*) from SETTING where Name = '$settingName';";
    intCounts = await sqlCounter(query, ["SETTING"]);
    if(intCounts == 0) {
      query = "insert into SETTING (Name, Value) values('$settingName', '$defaultValue');";
      await sqlQuery(query, ["SETTING"]);
      curMode = defaultValue;
    }
    else {
      query = "Select Value from SETTING where Name = '$settingName';";
      curMode = await sqlScalar(query, ["SETTING"]);
    }
    switch (settingName) {
      case "NOOFDAYS":
        return int.parse(curMode);
      default:
        return (curMode == defaultValue);
    }
  }

  Future createSetting() async {
    await curActiveDatabase.execute (
      '''
        Create Table SETTING (
          ID Integer Primary Key,
          Name Text Not Null,
          Value Text Not Null
        )
      '''
    );
  }

  Future createFutureWeather() async {
    await curActiveDatabase.execute (
      '''
        Create Table FUTUREWEATHER (
          Id Integer Primary Key,
          Date Text Not Null,
          Condition Text Not Null,
          MaxCelsius Text Not Null,
          MinCelsius Text Not Null,
          MaxFahrenheit Text Not Null,
          MinFahrenheit Text Not Null,
          ImagePath Text Not Null
        )
      '''
    );
  }

  Future createCurrentWeather() async {
    await curActiveDatabase.execute (
      '''
        Create Table CURRENTWEATHER (
          Position Text Not Null,
          Location Text Not Null,
          Date Text Not Null,
          MaxCelsius Text Not Null,
          MinCelsius Text Not Null,
          MaxFahrenheit Text Not Null,
          MinFahrenheit Text Not Null,
          Condition Text Not Null,
          Celsius Text Not Null,
          Fahrenheit Text Not Null,
          Humidity Text Not Null,
          Cloud Text Not Null,
          WindKMPH Text Not Null,
          WindMPH Text Not Null,
          WindDegree Text Not Null,
          WindDirection Text Not Null,
          ImagePath Text Not Null
        )
      '''
    );
  }

  Future<String> sqlScalar(String query, List<String> tblNames) async {
    try {
      var sqlSelectResult = await curActiveDatabase.rawQuery(query);
      if(sqlSelectResult.isEmpty) { return ""; } else { return sqlSelectResult[0].values.elementAt(0).toString(); }
    } catch(ex) { print(ex.toString()); await dbMisMatch(tblNames); return ""; }
  }

  Future<int> sqlCounter(String query, List<String> tblNames) async {
    try {
      var result = firstIntValue(await curActiveDatabase.rawQuery(query));
      return (result != null) ? result : -1;
    } catch(ex) { await dbMisMatch(tblNames); return -1; }
  }

  Future<List<Map<String, dynamic>>> sqlQuery(String query, List<String> tblNames) async {
    try { return await curActiveDatabase.rawQuery(query); }
    catch(ex) { await dbMisMatch(tblNames); return []; }
  }

  Future<void> dbMisMatch(List<String> tblNames) async {
    if(tblNames.isNotEmpty) {
      for(int z = 0; z < tblNames.length; z++) {
        try {
          if(tblNames[z] != "sqlite_master") { await curActiveDatabase.rawQuery("drop table ${tblNames[z]};"); }
        } catch(ex) {}
      }
      await resetApplication();
      EasyLoading.showInfo("Applying New Updates");
      SystemNavigator.pop();
    }
  }
}