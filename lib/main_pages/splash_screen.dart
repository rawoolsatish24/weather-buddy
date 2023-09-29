import 'package:easy_splash_screen/easy_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weatherbuddy/general_pages/master.dart';
import 'package:weatherbuddy/utils/common_classes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Constants.isSoftwareRestarted = true;
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    return EasySplashScreen(
      logo: Image.asset(ImagePaths.appIcon),
      logoWidth: MediaQuery.of(context).size.width - 250,
      backgroundColor: Colors.white,
      loadingText: const Text("Loading, please wait..."),
      navigator: const AppMaster(),
      durationInSeconds: 3,
    );
  }
}
