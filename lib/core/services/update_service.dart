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

  // Informations sur l'application actuelle
  PackageInfo? _packageInfo;

  // URL pour vérifier les mises à jour (à remplacer par votre propre API)
  final String _updateCheckUrl = 'https://your-api.com/app/updates';

  // URLs des stores
  final String _playStoreUrl = 'https://play.google.com/store/apps/details?id=';
  final String _appStoreUrl = 'https://apps.apple.com/app/id';

  UpdateService(this._errorService);

  /// Initialise le service de mise à jour
  Future<void> initialize() async {
    try {
      _packageInfo = await PackageInfo.fromPlatform();
      AppLogger.info('UpdateService initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize UpdateService', e, stackTrace);
      await _errorService.recordError(e, stackTrace, reason: 'UpdateService initialization failed');
    }
  }

  /// Vérifie si une mise à jour est disponible
  ///
  /// Retourne un [UpdateInfo] si une mise à jour est disponible, null sinon.
  Future<UpdateInfo?> checkForUpdate() async {
    if (_packageInfo == null) {
      await initialize();
    }

    try {
      // En mode développement, simuler une mise à jour disponible
      if (EnvConfig.isDevelopment) {
        return _simulateUpdate();
      }

      // En production, vérifier réellement les mises à jour
      final response = await http.get(
        Uri.parse(
          '$_updateCheckUrl?version=${_packageInfo!.version}&build=${_packageInfo!.buildNumber}',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Vérifier si une mise à jour est disponible
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

      // Aucune mise à jour disponible
      return null;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check for updates', e, stackTrace);
      await _errorService.recordError(e, stackTrace, reason: 'Update check failed');
      return null;
    }
  }

  /// Simule une mise à jour disponible (pour le développement)
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
      releaseNotes: [
        '• Nouvelle interface utilisateur',
        '• Performances améliorées',
        '• Corrections de bugs',
      ],
      updateUrl: '',
      forceUpdate: false,
    );
  }

  /// Ouvre le store pour mettre à jour l'application
  Future<bool> openStore() async {
    try {
      final Uri storeUri;

      if (Platform.isAndroid) {
        storeUri = Uri.parse('$_playStoreUrl${_packageInfo!.packageName}');
      } else if (Platform.isIOS) {
        // Remplacez YOUR_APP_ID par l'ID de votre application sur l'App Store
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

  /// Vérifie si la version actuelle est inférieure à la version minimale requise
  bool isVersionOutdated(String currentVersion, String minRequiredVersion) {
    try {
      final current = _parseVersion(currentVersion);
      final required = _parseVersion(minRequiredVersion);

      // Comparer les versions
      if (current[0] < required[0]) {
        return true; // Major version inférieure
      } else if (current[0] == required[0] && current[1] < required[1]) {
        return true; // Minor version inférieure
      } else if (current[0] == required[0] &&
          current[1] == required[1] &&
          current[2] < required[2]) {
        return true; // Patch version inférieure
      }

      return false; // Version actuelle est égale ou supérieure à la version minimale requise
    } catch (e) {
      AppLogger.error('Failed to compare versions', e);
      return false; // En cas d'erreur, supposer que la version n'est pas obsolète
    }
  }

  /// Parse une version au format "x.y.z" en liste [major, minor, patch]
  List<int> _parseVersion(String version) {
    final parts = version.split('.');
    if (parts.length != 3) {
      throw FormatException('Invalid version format: $version');
    }

    return [int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])];
  }

  /// Obtient la version actuelle de l'application
  String get currentVersion => _packageInfo?.version ?? 'Unknown';

  /// Obtient le numéro de build actuel de l'application
  String get currentBuild => _packageInfo?.buildNumber ?? 'Unknown';
}

/// Classe pour stocker les informations de mise à jour
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
