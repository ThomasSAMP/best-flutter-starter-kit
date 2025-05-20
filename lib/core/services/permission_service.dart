import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/logger.dart';

@lazySingleton
class PermissionService {
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e, stackTrace) {
      AppLogger.error('Error requesting camera permission', e, stackTrace);
      return false;
    }
  }

  Future<bool> requestPhotosPermission() async {
    try {
      final status = await Permission.photos.request();
      return status.isGranted;
    } catch (e, stackTrace) {
      AppLogger.error('Error requesting photos permission', e, stackTrace);
      return false;
    }
  }

  Future<bool> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      return status.isGranted;
    } catch (e, stackTrace) {
      AppLogger.error('Error requesting location permission', e, stackTrace);
      return false;
    }
  }

  Future<bool> requestNotificationPermission() async {
    try {
      final status = await Permission.notification.request();
      return status.isGranted;
    } catch (e, stackTrace) {
      AppLogger.error(
        'Error requesting notification permission',
        e,
        stackTrace,
      );
      return false;
    }
  }

  Future<bool> requestStoragePermission() async {
    try {
      final status = await Permission.storage.request();
      return status.isGranted;
    } catch (e, stackTrace) {
      AppLogger.error('Error requesting storage permission', e, stackTrace);
      return false;
    }
  }

  Future<bool> checkPermissionStatus(Permission permission) async {
    try {
      final status = await permission.status;
      return status.isGranted;
    } catch (e, stackTrace) {
      AppLogger.error('Error checking permission status', e, stackTrace);
      return false;
    }
  }

  Future<void> openAppSettings() async {
    try {
      await openAppSettings();
    } catch (e, stackTrace) {
      AppLogger.error('Error opening app settings', e, stackTrace);
    }
  }
}
