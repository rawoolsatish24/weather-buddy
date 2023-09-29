import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:package_info/package_info.dart';
import 'package:weatherbuddy/utils/common_classes.dart';
import 'package:weatherbuddy/utils/common_methods.dart';
import 'general_pages/master.dart';
import 'main_pages/splash_screen.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(WeatherBuddy());
  configLoading();
}

class WeatherBuddy extends StatefulWidget {
  @override
  _WeatherBuddyState createState() => _WeatherBuddyState();
}

class _WeatherBuddyState extends State<WeatherBuddy> {
  late BuildContext curContext;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      try {
        Application.appPackageInfo = await PackageInfo.fromPlatform();
        await resetApplication();
      } catch (ex) {
        print(ex.toString());
        EasyLoading.showError(Constants.appErrorMessage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    curContext = context;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather Buddy',
      initialRoute: '/',
      builder: EasyLoading.init(),
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const AppMaster(),
      },
    );
  }
}