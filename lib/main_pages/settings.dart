import 'package:flutter/material.dart';
import 'package:weatherbuddy/utils/common_classes.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  void initState() {
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Card(
              elevation: 5,
              shadowColor: Application.appPrimaryColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Temperature type", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: GestureDetector(
                              onTap: () async {
                                DBConstants.isCelsius = true;
                                Constants.dbHelper.updateSetting("ISCELSIUS", "TRUE");
                                setState(() {});
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: DBConstants.isCelsius ? Application.appPrimaryLightColor : Colors.white,
                                  border: Border.all(color: DBConstants.isCelsius ? Application.appPrimaryColor : Colors.grey,),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Center(
                                    child: Text("Celsius",
                                      style: TextStyle(
                                        color: (DBConstants.isCelsius) ? Application.appPrimaryColor : Colors.grey,
                                        fontWeight: (DBConstants.isCelsius) ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: GestureDetector(
                              onTap: () async {
                                DBConstants.isCelsius = false;
                                Constants.dbHelper.updateSetting("ISCELSIUS", "FALSE");
                                setState(() {});
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: (DBConstants.isCelsius == false) ? Application.appPrimaryLightColor : Colors.white,
                                  border: Border.all(color: (DBConstants.isCelsius == false) ? Application.appPrimaryColor : Colors.grey,),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Center(
                                    child: Text("Fahrenheit",
                                      style: TextStyle(
                                        color: (DBConstants.isCelsius == false) ? Application.appPrimaryColor : Colors.grey,
                                        fontWeight: (DBConstants.isCelsius == false) ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Card(
              elevation: 5,
              shadowColor: Application.appPrimaryColor,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("No. of future days forecast", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                    Slider(
                      activeColor: Application.appPrimaryColor,
                      value: DBConstants.noOfFutureDays.toDouble(),
                      min: 5,
                      max: 10,
                      divisions: 5,
                      label: DBConstants.noOfFutureDays.toString(),
                      onChanged: (double newValue) {
                        setState(() {
                          DBConstants.noOfFutureDays = newValue.round();
                          setState(() {});
                        });
                      },
                      onChangeEnd: (double newValue) {
                        setState(() {
                          Constants.dbHelper.updateSetting("NOOFDAYS", DBConstants.noOfFutureDays.toString());
                          setState(() {});
                        });
                      },
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
