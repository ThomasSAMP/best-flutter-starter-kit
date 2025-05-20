// Remplacer la classe AppLogger pour les tests
class MockAppLogger {
  static void verbose(dynamic message) {
    // Ne rien faire dans les tests ou imprimer simplement
    print('VERBOSE: $message');
  }

  static void debug(dynamic message) {
    print('DEBUG: $message');
  }

  static void info(dynamic message) {
    print('INFO: $message');
  }

  static void warning(dynamic message) {
    print('WARNING: $message');
  }

  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    print('ERROR: $message');
    if (error != null) print('ERROR DETAILS: $error');
    if (stackTrace != null) print('STACK: $stackTrace');
  }

  static void wtf(dynamic message) {
    print('WTF: $message');
  }
}
