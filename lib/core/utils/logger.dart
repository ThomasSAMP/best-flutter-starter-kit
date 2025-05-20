import 'package:logger/logger.dart';
import '../config/env_config.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
    level: EnvConfig.instance.enableLogging ? Level.verbose : Level.nothing,
  );

  static void verbose(dynamic message) {
    if (EnvConfig.instance.enableLogging) {
      _logger.v(message);
    }
  }

  static void debug(dynamic message) {
    if (EnvConfig.instance.enableLogging) {
      _logger.d(message);
    }
  }

  static void info(dynamic message) {
    if (EnvConfig.instance.enableLogging) {
      _logger.i(message);
    }
  }

  static void warning(dynamic message) {
    if (EnvConfig.instance.enableLogging) {
      _logger.w(message);
    }
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (EnvConfig.instance.enableLogging) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  static void wtf(dynamic message) {
    if (EnvConfig.instance.enableLogging) {
      _logger.wtf(message);
    }
  }
}