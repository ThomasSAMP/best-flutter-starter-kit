import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/env_config.dart';
import '../utils/logger.dart';
import 'error_service.dart';

@lazySingleton
class UpdateService {
  final ErrorService _errorService;

  // Current Information app
  PackageInfo? _packageInfo;

  // URL to check for updates (replace with your own API)
  final String _updateCheckUrl = 'https://your-api.com/app/updates';

  // Store URLs
  final String _playStoreUrl = 'https://play.google.com/store/apps/details?id=';
  final String _appStoreUrl = 'https://apps.apple.com/app/id';

  UpdateService(this._errorService);

  /// Initialize update service
  Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      AppLogger.info('UpdateService initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize UpdateService', e, stackTrace);
      await _errorService.recordError(e, stackTrace, reason: 'UpdateService initialization failed');
    }
  }

  /// Check if an update is available
  ///
  /// Returns an [UpdateInfo] if an update is available, null otherwise.
  Future<UpdateInfo?> checkForUpdate() async {
    if (_packageInfo == null) {
      await initialize();
    }

    try {
      // In development mode, simulate an available update
      if (EnvConfig.isDevelopment) {
        return _simulateUpdate();
      }

      // In production, actually check for updates
      final response = await http.get(
        Uri.parse(
          '$_updateCheckUrl?version=${_packageInfo!.version}&build=${_packageInfo!.buildNumber}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Check if an update is available
        if (data['update_available'] == true) {
          return UpdateInfo(
            availableVersion: data['version'],
            minRequiredVersion: data['min_required_version'],
            releaseNotes: data['release_notes'],
            updateUrl: data['update_url'],
            forceUpdate: data['force_update'] == true,
          );
        }
      }

      // No updates available
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check for updates', e, stackTrace);
      await _errorService.recordError(e, stackTrace, reason: 'Update check failed');
      return null;
    }
  }

  /// Simulate an available update (for development)
  UpdateInfo _simulateUpdate() {
    final currentVersion = _packageInfo?.version ?? '1.0.0';
    final parts = currentVersion.split('.');
    final major = int.parse(parts[0]);
    final minor = int.parse(parts[1]);
    final patch = int.parse(parts[2]);

    final newVersion = '$major.${minor + 1}.$patch';

    return UpdateInfo(
      availableVersion: newVersion,
      minRequiredVersion: currentVersion,
      releaseNotes: ['• New user interface', '• Improved performance', '• Bug Fixes'],
      updateUrl: '',
      forceUpdate: false,
    );
  }

  /// Open the store to update the application
  Future<bool> openStore() async {
    try {
      final Uri storeUri;

      if (Platform.isAndroid) {
        storeUri = Uri.parse('$_playStoreUrl${_packageInfo!.packageName}');
      } else if (Platform.isIOS) {
        // Replace YOUR_APP_ID with your App Store application ID
        storeUri = Uri.parse('$_appStoreUrl/YOUR_APP_ID');
      } else {
        AppLogger.warning('Platform not supported for app updates');
        return false;
      }

      final canLaunch = await canLaunchUrl(storeUri);
      if (canLaunch) {
        return launchUrl(storeUri, mode: LaunchMode.externalApplication);
      } else {
        AppLogger.warning('Could not launch store URL: $storeUri');
        return false;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to open store', e, stackTrace);
      await _errorService.recordError(e, stackTrace, reason: 'Failed to open store');
      return false;
    }
  }

  /// Check if current version is less than the minimum required version
  bool isVersionOutdated(String currentVersion, String minRequiredVersion) {
    try {
      final current = _parseVersion(currentVersion);
      final required = _parseVersion(minRequiredVersion);

      // Compare versions
      if (current[0] < required[0]) {
        return true; // Major version is lower
      } else if (current[0] == required[0] && current[1] < required[1]) {
        return true; // Minor version is lower
      } else if (current[0] == required[0] &&
          current[1] == required[1] &&
          current[2] < required[2]) {
        return true; // Patch version is lower
      }

      return false; // Current version is equal to or higher than the minimum required version
    } catch (e) {
      AppLogger.error('Failed to compare versions', e);
      return false; // In case of error, assume the version is not outdated
    }
  }

  /// Parse a version in "x.y.z" format into a list [major, minor, patch]
  List<int> _parseVersion(String version) {
    final parts = version.split('.');
    if (parts.length != 3) {
      throw FormatException('Invalid version format: $version');
    }

    return [int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])];
  }

  /// Get the current version of the application
  String get currentVersion => _packageInfo?.version ?? 'Unknown';

  /// Get the current build number of the application
  String get currentBuild => _packageInfo?.buildNumber ?? 'Unknown';
}

/// Class to store update information
class UpdateInfo {
  final String availableVersion;
  final String minRequiredVersion;
  final List<String> releaseNotes;
  final String updateUrl;
  final bool forceUpdate;

  UpdateInfo({
    required this.availableVersion,
    required this.minRequiredVersion,
    required this.releaseNotes,
    required this.updateUrl,
    required this.forceUpdate,
  });
}
