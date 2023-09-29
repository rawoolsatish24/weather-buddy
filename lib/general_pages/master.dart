import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:weatherbuddy/general_pages/drawer.dart';
import 'package:weatherbuddy/main_pages/home_page.dart';
import 'package:weatherbuddy/main_pages/search_page.dart';
import 'package:weatherbuddy/utils/common_classes.dart';

class AppMaster extends StatefulWidget {
  const AppMaster({Key? key}) : super(key: key);

  @override
  State<AppMaster> createState() => _AppMasterState();
}

class _AppMasterState extends State<AppMaster> {
  late Widget curActivePage;

  @override
  void initState() {
    super.initState();
    try { resetHomePage(); } catch (ex) { EasyLoading.showError(Constants.appErrorMessage); }
    setState(() {});
  }

  void resetHomePage() {
    Constants.curMenuIndex = 0;
    Constants.appActivePage = "home";
    Constants.curActivePage = "Dashboard";
    curActivePage = HomePage(callback);
  }

  void callback(Widget nextPage) { setState(() { curActivePage = nextPage; }); }

  Future<bool> backPressed() async {
    try {
      if(Constants.isDrawerActive) { Constants.isDrawerActive = false; Navigator.pop(context); }
      else if(Constants.appActivePage == "home") {
        return (await showDialog(
          context: context,
          useSafeArea: true,
          barrierDismissible: true,
          builder: (context) =>
              BasicDialogAlert(
                title: const Text("Confirm exit!", style: TextStyle(fontSize: 20),),
                content: const Text("Do you really want to exit the app?",
                  style: TextStyle(fontSize: 17),),
                actions: <Widget>[
                  BasicDialogAction(
                    title: Text("No", style: TextStyle(fontSize: 20, color: Application.appPrimaryColor),),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  BasicDialogAction(
                    title: Text("Yes", style: TextStyle(fontSize: 20, color: Application.appPrimaryColor),),
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                  ),
                ],
              ),
        )) ?? false;
      }
      else {
        setState(() {
          resetHomePage();
        });
      }
    } catch (ex) { EasyLoading.showError(Constants.appErrorMessage); }
    setState(() {});
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: backPressed,
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: (Constants.appActivePage != "home") ? Container() : FloatingActionButton(
          elevation: 5,
          onPressed: () async {
            setState(() {
              Constants.appActivePage = "search";
              Constants.curActivePage = "Search location";
              curActivePage = SearchPage(callback);
            });
          },
          backgroundColor: Application.appPrimaryColor,
          child: const Icon(Icons.search_outlined, size: 30, color: Colors.white,),
        ),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.yellow,),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: Application.appLinearGradient,
            ),
          ),
          title: Row(
            children: [
              Expanded(child: Text(Constants.curActivePage, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white,),)),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: backPressed,
                    child: const Icon(
                      Icons.exit_to_app_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ],
          ),
          titleSpacing: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(4),
          child: curActivePage,
        ),
        drawer: AppDrawer(callback),
        drawerScrimColor: Colors.black54.withOpacity(0.7),
      ),
    );
  }
}
