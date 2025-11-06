import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_multiplatform_logger/flutter_multiplatform_logger.dart';
import 'package:flutter_multiplatform_logger/src/logger_config.dart';

void main() {
  group('LoggerConfig', () {
    test('has default values', () {
      expect(LoggerConfig.maxFileSizeBytes, 1024 * 1024);
      expect(LoggerConfig.maxBackupCount, 10);
      expect(LoggerConfig.logDirName, 'logs');
      expect(LoggerConfig.logFileName, 'app');
    });

    test('can update settings', () {
      LoggerConfig.maxFileSizeBytes = 5 * 1024 * 1024;
      expect(LoggerConfig.maxFileSizeBytes, 5 * 1024 * 1024);

      // Reset for other tests
      LoggerConfig.maxFileSizeBytes = 1024 * 1024;
    });

    test('packageName returns unknown before initialization', () {
      expect(LoggerConfig.packageName, 'unknown');
    });
  });

  group('Logger', () {
    test('can create logger instance', () {
      final logger = Logger('TestLogger');
      expect(logger, isNotNull);
      expect(logger.name, 'TestLogger');
    });

    test('logger has default level', () {
      Logger('TestLogger');
      // Logger level is controlled by Logger.root
      expect(Logger.root.level, isNotNull);
    });
  });
}
