import 'package:flutter/foundation.dart';
import 'dart:io' as io;

class ApiConfig {
  static String get baseUrl {
    // Para entornos web usamos localhost
    if (kIsWeb) return 'http://localhost:3000/api';
    
    try {
      // Para emuladores Android 10.0.2.2 equivale a localhost
      if (io.Platform.isAndroid) {
        return 'http://10.0.2.2:3000/api';
      }
    } catch (_) {}
    
    // Fallback multiplataforma (iOS Simulator, desktop, etc.)
    return 'http://localhost:3000/api';
  }
}
