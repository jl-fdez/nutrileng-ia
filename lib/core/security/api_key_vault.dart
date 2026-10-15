import 'dart:convert';

/// Almacén seguro y ofuscador para la API Key de Gemini.
/// Permite inyección en tiempo de compilación con `--dart-define=GEMINI_API_KEY=...`
/// u ofuscación simétrica en memoria para proteger tokens en el binario.
class ApiKeyVault {
  ApiKeyVault._();

  static final ApiKeyVault instance = ApiKeyVault._();

  // Salt interno para ofuscación XOR de cadenas en memoria
  static const String _vaultSalt = 'NutriLensAI_Secure_Vault_2026_Salt_Key';

  // API Key leída desde el entorno de compilación
  static const String _envApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  String? _customRuntimeKey;

  /// Retorna si el vault contiene una API Key configurada y válida
  bool get hasValidApiKey {
    final key = apiKey;
    return key.isNotEmpty && key.length > 10;
  }

  /// Retorna la API Key actual (prioridad: runtime custom > compile-time env)
  String get apiKey {
    if (_customRuntimeKey != null && _customRuntimeKey!.trim().isNotEmpty) {
      return _customRuntimeKey!.trim();
    }
    return _envApiKey.trim();
  }

  /// Permite establecer una API Key de usuario en tiempo de ejecución (ej. desde Perfil)
  void setCustomKey(String key) {
    _customRuntimeKey = key.trim();
  }

  /// Limpia la clave personalizada y vuelve al valor de entorno
  void clearCustomKey() {
    _customRuntimeKey = null;
  }

  /// Ofuscación reversible usando XOR + Base64 para almacenamiento local seguro
  static String obfuscate(String plainText) {
    if (plainText.isEmpty) return '';
    final plainBytes = utf8.encode(plainText);
    final saltBytes = utf8.encode(_vaultSalt);

    final obfuscated = List<int>.generate(
      plainBytes.length,
      (i) => plainBytes[i] ^ saltBytes[i % saltBytes.length],
    );

    return base64.encode(obfuscated);
  }

  /// Desofuscación reversible
  static String deobfuscate(String encryptedBase64) {
    if (encryptedBase64.isEmpty) return '';
    try {
      final obfuscatedBytes = base64.decode(encryptedBase64);
      final saltBytes = utf8.encode(_vaultSalt);

      final decrypted = List<int>.generate(
        obfuscatedBytes.length,
        (i) => obfuscatedBytes[i] ^ saltBytes[i % saltBytes.length],
      );

      return utf8.decode(decrypted);
    } catch (_) {
      return '';
    }
  }

  /// Muestra una versión enmascarada para la UI (ej. "AIzaSy...4xK9")
  String get maskedApiKey {
    final key = apiKey;
    if (key.isEmpty) return 'No configurada (Modo IA local)';
    if (key.length <= 8) return '••••••••';
    return '${key.substring(0, 6)}••••••••${key.substring(key.length - 4)}';
  }
}
