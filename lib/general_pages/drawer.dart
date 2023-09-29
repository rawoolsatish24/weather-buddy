import 'package:flutter/material.dart';
import 'package:weatherbuddy/main_pages/home_page.dart';
import 'package:weatherbuddy/main_pages/settings.dart';
import 'package:weatherbuddy/utils/common_classes.dart';

class AppDrawer extends StatefulWidget {
  late Function callback;
  AppDrawer(this.callback);

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {

  void initState() {
    super.initState();
    Constants.isDrawerActive = true;
  }

  @override
  void dispose() {
    Constants.isDrawerActive = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 500,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 215,
            child: DrawerHeader(
              decoration: BoxDecoration(
                gradient: Application.appLinearGradient,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(ImagePaths.appIcon),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text("Weather Buddy", style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 25,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black,
                            offset: Offset(2, 0),
                          ),
                        ],
                      ),),
                    ),
                    RichText(
                      text: TextSpan(
                        text: "v",
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold,),
                        children: <TextSpan>[
                          TextSpan(
                            text: Application.appPackageInfo!.version,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard,),
            selectedMaterialColor: Application.appSecondaryColor,
            title: const Text("Dashboard", style: TextStyle(fontSize: 20)),
            dense: true,
            horizontalTitleGap: 0,
            onTap: () {
              setState(() {
                Constants.curMenuIndex = 0;
                Constants.appActivePage = "home";
                Constants.curActivePage = "Dashboard";
                widget.callback(HomePage(widget.callback));
                Navigator.pop(context);
              });
            },
            selected: Constants.curMenuIndex == 0 ? true : false,
            subtitle: const Text("Main Screen With Dashboard"),
          ),
          ListTile(
            leading: const Icon(Icons.settings,),
            title: const Text("Settings", style: TextStyle(fontSize: 20)),
            selectedMaterialColor: Application.appSecondaryColor,
            dense: true,
            horizontalTitleGap: 0,
            subtitle: const Text("Set To Make More Friendly"),
            onTap: () async {
              Constants.curMenuIndex = 1;
              Constants.appActivePage = "settings";
              Constants.curActivePage = "Settings";
              widget.callback(const Settings());
              Navigator.pop(context);
              setState(() {});
            },
            selected: Constants.curMenuIndex == 1 ? true : false,
          ),
          ListTile(
            leading: const Icon(Icons.power_settings_new,),
            title: const Text("Exit", style: TextStyle(fontSize: 20)),
            selectedMaterialColor: Application.appSecondaryColor,
            dense: true,
            horizontalTitleGap: 0,
            subtitle: const Text("Close the application"),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
