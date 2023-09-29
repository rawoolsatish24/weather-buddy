import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weatherbuddy/utils/api_network.dart';
import 'package:weatherbuddy/utils/common_classes.dart';
import 'package:weatherbuddy/utils/auto_complete.dart';
import 'package:weatherbuddy/utils/common_methods.dart';
import 'package:weatherbuddy/widgets/location_list_tile.dart';
import 'package:weatherbuddy/main_pages/home_page.dart';

class SearchPage extends StatefulWidget {
  Function callback;
  SearchPage(this.callback);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<AutocompletePrediction> lsPredictions = [];

  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  void placeAutoComplete(String searchQuery) async {
    if(searchQuery == "") {
      lsPredictions = [];
      return;
    }
    Uri googleURI = Uri.https( "maps.googleapis.com", "maps/api/place/autocomplete/json", { "input": searchQuery, "key": Constants.googleAPIKey, } );
    String? response = await APINetwork.fetchURL(googleURI);
    if(response != null) {
      PlaceAutoCompleteResponse result = PlaceAutoCompleteResponse.parseAutoCompleteResult(response);
      if(result.predictions != null) {
        lsPredictions = result.predictions!;
      }
    }
  }

  void returnToHomePage() {
    Constants.curMenuIndex = 0;
    Constants.appActivePage = "home";
    Constants.curActivePage = "Dashboard";
    widget.callback(HomePage(widget.callback));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white38,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Form(
                child: TextFormField(
                  onChanged: (searchQuery) {
                    setState(() {
                      placeAutoComplete(searchQuery);
                    });
                  },
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: "Search your location",
                    prefixIcon: Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Icon(Icons.location_pin,),
                    ),
                  ),
                )
              ),
              Divider(
                height: 4,
                thickness: 4,
                color: Application.appDividerColor,
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: ElevatedButton.icon(
                  onPressed: () {
                    EasyLoading.show(status: "Loading...");
                    Constants.curPosition = null;
                    returnToHomePage();
                  },
                  icon: const Icon(Icons.my_location, size: 16,),
                  label: const Text("Use my current location"),
                  style: ElevatedButton.styleFrom(
                    primary: Application.appPrimaryColor,
                    elevation: 0,
                    fixedSize: const Size(double.infinity, 40),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                ),
              ),
              Divider(
                height: 4,
                thickness: 4,
                color: Application.appDividerColor,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: lsPredictions.length,
                  itemBuilder: (context, index) => LocationListTile(
                    press: () async {
                      if(!Application.adWatched) {
                        EasyLoading.showError("Complete watching ad first to search location");
                        return;
                      }
                      EasyLoading.show(status: "Loading...");
                      List<Location> locations = await locationFromAddress(lsPredictions[index].description!);
                      Constants.curPosition = CoOrdinates(locations[0].longitude, locations[0].latitude);
                      await fetchWeatherData();
                      returnToHomePage();
                    },
                    location: lsPredictions[index].description!,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
