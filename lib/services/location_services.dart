import 'package:location/location.dart';

class LocationService {
  Location location = Location();
  late LocationData  _locationdata;

  Future<void> initialize() async{
    bool _serviceEnabled;
    PermissionStatus permissionStatus;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

  }
  Future<double?> getLattitude() async{
    _locationdata = await location.getLocation();
    return _locationdata.latitude;
  }
  Future<double?> getLongitude() async{
    _locationdata = await location.getLocation();
    return _locationdata.longitude;
  }
}