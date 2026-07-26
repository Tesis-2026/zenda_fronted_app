import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricStatus {
  const BiometricStatus({
    required this.deviceSupported,
    required this.hasEnrolledBiometrics,
    required this.enabled,
    required this.availableBiometrics,
    this.email,
  });

  final bool deviceSupported;
  final bool hasEnrolledBiometrics;
  final bool enabled;
  final List<BiometricType> availableBiometrics;
  final String? email;

  bool get canEnable => deviceSupported && hasEnrolledBiometrics;
  bool get canAuthenticate => enabled && canEnable;

  String get methodLabel {
    if (availableBiometrics.contains(BiometricType.face)) {
      return 'biometria facial';
    }
    return 'huella digital';
  }

  String? get maskedEmail {
    final value = email?.trim();
    if (value == null || value.isEmpty || !value.contains('@')) return value;
    final parts = value.split('@');
    final name = parts.first;
    final domain = parts.sublist(1).join('@');
    final visibleName = name.length <= 2 ? name : name.substring(0, 2);
    return '$visibleName***@$domain';
  }
}

class BiometricAuthService {
  BiometricAuthService({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? storage,
  }) : _localAuth = localAuth ?? LocalAuthentication(),
       _storage = storage ?? const FlutterSecureStorage();

  static const _enabledKey = 'zenda.biometric.enabled';
  static const _emailKey = 'zenda.biometric.email';

  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _storage;

  Future<BiometricStatus> getStatus() async {
    final enabled = await isEnabled();
    final email = await _storage.read(key: _emailKey);

    try {
      final deviceSupported = await _localAuth.isDeviceSupported();
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final available = canCheckBiometrics
          ? await _localAuth.getAvailableBiometrics()
          : const <BiometricType>[];

      return BiometricStatus(
        deviceSupported: deviceSupported && canCheckBiometrics,
        hasEnrolledBiometrics: available.isNotEmpty,
        enabled: enabled,
        availableBiometrics: available,
        email: email,
      );
    } on LocalAuthException {
      return BiometricStatus(
        deviceSupported: false,
        hasEnrolledBiometrics: false,
        enabled: enabled,
        availableBiometrics: const [],
        email: email,
      );
    }
  }

  Future<bool> isEnabled() async {
    return (await _storage.read(key: _enabledKey)) == 'true';
  }

  Future<bool> authenticate({required String reason}) async {
    final status = await getStatus();
    if (!status.canEnable) return false;

    try {
      return _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );
    } on LocalAuthException {
      return false;
    }
  }

  Future<void> enableForUser(String email) async {
    await Future.wait([
      _storage.write(key: _enabledKey, value: 'true'),
      _storage.write(key: _emailKey, value: email),
    ]);
  }

  Future<void> disable() async {
    await Future.wait([
      _storage.delete(key: _enabledKey),
      _storage.delete(key: _emailKey),
    ]);
  }
}
