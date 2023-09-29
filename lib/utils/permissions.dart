import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:geolocator/geolocator.dart';

Future<Position?> getCurrentPosition() async {
  LocationPermission permission;
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      EasyLoading.showError("Location services are disabled!");
      return null;
    }
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      EasyLoading.showError("Location permissions are denied!");
      return null;
    }
    else if (permission == LocationPermission.denied) {
      EasyLoading.showError("Location permission denied permanently! Accept permission from mobile settings!");
      return null;
    }
  }
  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}