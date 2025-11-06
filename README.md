# Flutter Multiplatform Logger

A simple logging package that works everywhere - Web, Android, iOS, Linux, macOS, and Windows.

## Features

- 🌐 Works on all platforms
- 📝 Saves logs to files (native platforms only)
- 🔄 Automatic file rotation when size limit reached
- 📍 Shows where each log was called from
- ⚙️ Easy to customize

## Installation

``` yaml
dependencies:
  flutter_multiplatform_logger: ^1.0.0
```
  
## Quick Start

``` dart
import 'package:flutter_multiplatform_logger/flutter_multiplatform_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Start the logger (IMPORTANT: use await!)
  await FlutterMultiplatformLogger.init();
  
  // Use it
  final logger = Logger('MyApp');
  logger.info('App started!');
  
  runApp(MyApp());
}
```

## Custom Settings

``` dart
await FlutterMultiplatformLogger.init(
  maxFileSizeBytes: 5 * 1024 * 1024,  // 5MB per file
  maxBackupCount: 20,                  // Keep 20 old files
  logDirName: 'my_logs',              // Custom folder name
);
```

## Platform Differences

- **Native (Android/iOS/Desktop)**: Saves logs to files with rotation
- **Web**: Only prints to console (browsers don't allow file access)

## Log Output Example

``` txt
2025-11-06T17:08:14.939937 [INFO   ] Main            - Application started!
	 at package:example/main.dart:7:18
2025-11-06T17:09:56.203908 [INFO   ] MyHomePage      - Increment button pressed 0 times
	 at package:example/main.dart:66:13
2025-11-06T17:09:56.385305 [INFO   ] MyHomePage      - Increment button pressed 1 times
	 at package:example/main.dart:66:13
2025-11-06T17:09:56.576151 [INFO   ] MyHomePage      - Increment button pressed 2 times
	 at package:example/main.dart:66:13
```

## Additional information

- [GitHub Repository](https://github.com/immsong/flutter_multiplatform_logger)
- [Issue Tracker](https://github.com/immsong/flutter_multiplatform_logger/issues)
- [Documentation](https://github.com/immsong/flutter_multiplatform_logger#readme)