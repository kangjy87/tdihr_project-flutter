import 'package:location_permissions/location_permissions.dart';

Future<bool> checkLocationPermission() async {
  final access = await LocationPermissions().checkPermissionStatus();
  switch (access) {
    case PermissionStatus.unknown:
    case PermissionStatus.denied:
    case PermissionStatus.restricted:
      final permission = await LocationPermissions().requestPermissions(
        permissionLevel: LocationPermissionLevel.locationAlways,
      );

      if (permission == PermissionStatus.granted) {
        return true;
      } else {
        return false;
      }
    case PermissionStatus.granted:
      return true;
    default:
      return false;
  }
}
