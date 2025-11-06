import 'package:package_info_plus/package_info_plus.dart';

/// Logger settings.
/// 
/// All settings are static and can be customized during initialization.
class LoggerConfig {
  /// Max log file size before creating a new file (default: 1MB)
  static int maxFileSizeBytes = 1024 * 1024;
  
  /// How many old log files to keep (default: 10)
  static int maxBackupCount = 10;
  
  /// How often to check if files need rotation (default: 1 minute)
  static Duration rotateCheckInterval = Duration(minutes: 1);
  
  /// Folder name for logs (default: 'logs')
  static String logDirName = 'logs';
  
  /// Log file name (default: 'app')
  static String logFileName = 'app';

  /// App package name (loaded automatically)
  static String? _packageName;

  /// Set up the logger.
  /// 
  /// Call this before using the logger. It loads your app's package name
  /// and lets you change settings.
  /// 
  /// Example:
  ///
  /// await LoggerConfig.initialize(
  ///   maxFileSizeBytes: 5 * 1024 * 1024,  // 5MB
  ///   maxBackupCount: 20,
  /// );
  static Future<void> initialize({
    int? maxFileSizeBytes,
    int? maxBackupCount,
    Duration? rotateCheckInterval,
    String? logDirName,
    String? logFileName,
  }) async {
    if (maxFileSizeBytes != null) {
      LoggerConfig.maxFileSizeBytes = maxFileSizeBytes;
    }

    if (maxBackupCount != null) {
      LoggerConfig.maxBackupCount = maxBackupCount;
    }

    if (rotateCheckInterval != null) {
      LoggerConfig.rotateCheckInterval = rotateCheckInterval;
    }

    if (logDirName != null) {
      LoggerConfig.logDirName = logDirName;
    }

    if (logFileName != null) {
      LoggerConfig.logFileName = logFileName;
    }

    // Fetch package name from platform
    final info = await PackageInfo.fromPlatform();
    _packageName = info.packageName;
  }

  /// Returns the application's package name.
  ///
  /// Returns 'unknown' if [initialize] hasn't been called yet.
  static String get packageName => _packageName ?? 'unknown';
}
