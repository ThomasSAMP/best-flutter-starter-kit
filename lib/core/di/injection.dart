// IMPORTANT: Pour faire fonctionner ce fichier, vous devez éxecuter une commande qui génère injection.config.dart
// flutter pub run build_runner build --delete-conflicting-outputs

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init', // Important: doit correspondre au nom dans .config.dart
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() async => getIt.init();