import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'app_localizations.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._();
  factory UpdateService() => _instance;
  UpdateService._();

  bool _isFirebaseInitialized() {
    try {
      Firebase.app();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Verifica si hay actualizaciones forzadas y muestra un diálogo de bloqueo si la versión local es obsoleta.
  Future<void> checkForUpdates(BuildContext context) async {
    if (!_isFirebaseInitialized()) {
      debugPrint("UpdateService: Firebase no está activo. Omitiendo verificación de versión.");
      return;
    }

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      
      // Configurar intervalos mínimos y tiempos de espera
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      await remoteConfig.setDefaults(const {
        'min_version': '1.0.0',
        'store_url': 'https://play.google.com/store',
      });

      // Fetch y activación
      await remoteConfig.fetchAndActivate();

      final minVersion = remoteConfig.getString('min_version');
      final storeUrl = remoteConfig.getString('store_url');

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      debugPrint("UpdateService: Versión actual: $currentVersion. Versión mínima requerida: $minVersion");

      if (_isVersionOlder(currentVersion, minVersion)) {
        if (context.mounted) {
          _showForceUpdateDialog(context, storeUrl);
        }
      }
    } catch (e) {
      debugPrint("UpdateService: Error al verificar actualizaciones: $e");
    }
  }

  // Compara si la versión actual es más antigua que la requerida
  bool _isVersionOlder(String current, String minimum) {
    try {
      final currentParts = current.split('+')[0].split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final minimumParts = minimum.split('+')[0].split('.').map((e) => int.tryParse(e) ?? 0).toList();

      final maxLen = currentParts.length > minimumParts.length ? currentParts.length : minimumParts.length;
      for (int i = 0; i < maxLen; i++) {
        final currentPart = i < currentParts.length ? currentParts[i] : 0;
        final minimumPart = i < minimumParts.length ? minimumParts[i] : 0;
        if (currentPart < minimumPart) return true;
        if (currentPart > minimumPart) return false;
      }
    } catch (e) {
      debugPrint("UpdateService: Error al comparar versiones: $e");
    }
    return false;
  }

  void _showForceUpdateDialog(BuildContext context, String storeUrl) {
    final local = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: "ForceUpdate",
      pageBuilder: (context, anim1, anim2) {
        return WillPopScope(
          onWillPop: () async => false, // Bloquear el botón físico atrás en Android
          child: Scaffold(
            backgroundColor: isDark ? const Color(0xFF1C110C) : const Color(0xFFF5E6D3),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.system_update_rounded,
                      size: 90,
                      color: Color(0xFF4A7C44),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      local.get('update_required'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      local.get('update_desc'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A7C44),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      onPressed: () async {
                        final uri = Uri.parse(storeUrl);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } else {
                          debugPrint("UpdateService: No se pudo abrir la URL de la tienda: $storeUrl");
                        }
                      },
                      child: Text(
                        local.get('update_btn'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
