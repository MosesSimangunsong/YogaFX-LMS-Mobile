class AppConfig {
  const AppConfig({
    required this.apiBaseUrl,
    required this.mobileApiPrefix,
    required this.connectTimeoutMs,
    required this.receiveTimeoutMs,
    required this.enableNetworkLogs,
  });

  factory AppConfig.fromEnvironment() {
    return AppConfig(
      apiBaseUrl: _normalizeBaseUrl(
        const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://10.0.2.2:8000',
        ),
      ),
      mobileApiPrefix: _normalizePrefix(
        const String.fromEnvironment(
          'MOBILE_API_PREFIX',
          defaultValue: '/api/mobile/v1',
        ),
      ),
      connectTimeoutMs: const int.fromEnvironment(
        'CONNECT_TIMEOUT_MS',
        defaultValue: 15000,
      ),
      receiveTimeoutMs: const int.fromEnvironment(
        'RECEIVE_TIMEOUT_MS',
        defaultValue: 15000,
      ),
      enableNetworkLogs: const bool.fromEnvironment(
        'ENABLE_NETWORK_LOGS',
        defaultValue: true,
      ),
    );
  }

  final String apiBaseUrl;
  final String mobileApiPrefix;
  final int connectTimeoutMs;
  final int receiveTimeoutMs;
  final bool enableNetworkLogs;

  String resolvePath(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return '$mobileApiPrefix$normalizedPath';
  }

  static String _normalizeBaseUrl(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }

  static String _normalizePrefix(String value) {
    if (value.isEmpty) {
      return '';
    }

    final withLeadingSlash = value.startsWith('/') ? value : '/$value';
    return withLeadingSlash.endsWith('/')
        ? withLeadingSlash.substring(0, withLeadingSlash.length - 1)
        : withLeadingSlash;
  }
}