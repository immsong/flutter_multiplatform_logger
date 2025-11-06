import 'package:logging/logging.dart';
import 'package:logging_appenders/logging_appenders.dart';
import 'package:stack_trace/stack_trace.dart';

import './logger_config.dart';

/// Formats log messages for web console.
/// Same format as native but only prints to console.
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

/// Logger for web platform.
/// Only prints to browser console (no file saving on web).
class FlutterMultiplatformLogger {
  /// Start the logger for web.
  /// 
  /// **Important**: Use `await` before this!
  /// 
  /// Note: Settings like file size don't work on web since we can't save files.
  static Future<void> init() async {
    await LoggerConfig.initialize();
    Logger.root.level = Level.ALL;

    final console = PrintAppender(formatter: const CustomLogFormatter());
    Logger.root.onRecord.listen(console.handle);
  }
}