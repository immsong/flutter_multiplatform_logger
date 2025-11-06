import 'dart:io';

import 'package:logging/logging.dart';
import 'package:logging_appenders/logging_appenders.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:stack_trace/stack_trace.dart';

import './logger_config.dart';

/// Formats log messages with time, level, and location info.
class CustomLogFormatter extends LogRecordFormatter {
  const CustomLogFormatter();

  @override
  StringBuffer formatToStringBuffer(LogRecord rec, StringBuffer sb) {
    final time = rec.time.toIso8601String();
    final level = rec.level.name.padRight(7);
    final loggerName = rec.loggerName.padRight(15);

    sb.write('$time [$level] $loggerName - ${rec.message}');

    // Add where the log was called from
    if (rec.error == null && rec.stackTrace == null) {
      try {
        final frames = Chain.current().traces.first.frames;
        // Skip internal logger frames, find the real caller
        final frame = frames.firstWhere(
          (frame) =>
              frame.package != null &&
              frame.package != "flutter_multiplatform_logger" &&
              frame.package != "logging_appenders" &&
              frame.package != "logging" &&
              (frame.package == LoggerConfig.packageName ||
                  frame.library.startsWith('file:')),
          orElse: () => frames.first,
        );
        sb.write('\n\t at ${frame.uri}:${frame.line}:${frame.column}');
      } catch (e) {
        // If that fails, use basic location info
        final frame = Frame.caller(4);
        sb.write('\n\t at ${frame.uri}:${frame.line}:${frame.column}');
      }
    }

    // Add error and stack trace if exists
    if (rec.error != null) {
      sb.write('\nError: ${rec.error}');
    }
    if (rec.stackTrace != null) {
      sb.write('\nStack: ${rec.stackTrace}');
    }

    return sb;
  }
}

/// Logger for native platforms (Android, iOS, Desktop).
/// Saves logs to files and rotates them automatically.
class FlutterMultiplatformLogger {
  /// Start the logger.
  ///
  /// **Important**: Use `await` before this!
  ///
  /// Example:
  ///
  /// void main() async {
  ///   WidgetsFlutterBinding.ensureInitialized();
  ///
  ///   await FlutterMultiplatformLogger.init(
  ///     maxFileSizeBytes: 5 * 1024 * 1024,  // 5MB
  ///     maxBackupCount: 20,
  ///   );
  ///
  ///   final logger = Logger('MyApp');
  ///   logger.info('App started!');
  ///
  ///   runApp(MyApp());
  /// }
  static Future<void> init({
    int? maxFileSizeBytes,
    int? maxBackupCount,
    Duration? rotateCheckInterval,
    String? logDirName,
    String? logFileName,
  }) async {
    // Set up config with settings
    await LoggerConfig.initialize(
      maxFileSizeBytes: maxFileSizeBytes,
      maxBackupCount: maxBackupCount,
      rotateCheckInterval: rotateCheckInterval,
      logDirName: logDirName,
      logFileName: logFileName,
    );
    Logger.root.level = Level.ALL;

    // Find where to save logs
    Directory logDir;
    if (Platform.isAndroid) {
      final documentsDir = await getApplicationDocumentsDirectory();
      logDir = Directory(
        path.join(
          documentsDir.path,
          LoggerConfig.packageName,
          LoggerConfig.logDirName,
        ),
      );
    } else {
      final appDataDir = Directory.current;
      logDir = Directory(path.join(appDataDir.path, LoggerConfig.logDirName));
    }

    if (!await logDir.exists()) {
      await logDir.create(recursive: true);
    }

    // Create file logger with rotation
    final now = DateTime.now();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final rotatingFile = RotatingFileAppender(
      baseFilePath: path.join(
        logDir.path,
        '${LoggerConfig.logFileName}_$dateStr.log',
      ),
      rotateAtSizeBytes: LoggerConfig.maxFileSizeBytes,
      keepRotateCount: LoggerConfig.maxBackupCount,
      rotateCheckInterval: LoggerConfig.rotateCheckInterval,
      formatter: const CustomLogFormatter(),
    );

    // Create console logger
    final console = PrintAppender(formatter: const CustomLogFormatter());

    // Connect loggers
    Logger.root.onRecord.listen((record) {
      rotatingFile.handle(record);
      if (record.level >= Level.INFO) {
        console.handle(record);
      }
    });
  }
}
