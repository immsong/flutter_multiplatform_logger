// Platform-specific logger exports.
//
// - Native platforms: Saves logs to files
// - Web: Prints logs to console only
export 'logger_native.dart' if (dart.library.html) 'logger_web.dart';
