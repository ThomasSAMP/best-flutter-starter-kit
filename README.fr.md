# Best Flutter Starter Kit

[![en](https://img.shields.io/badge/lang-en-red.svg)](https://github.com/ThomasSAMP/best-flutter-starter-kit/blob/master/README.md)
[![fr](https://img.shields.io/badge/lang-fr-blue.svg)](https://github.com/ThomasSAMP/best-flutter-starter-kit/blob/master/README.fr.md)

Un template complet et prêt à l'emploi pour développer des applications Flutter professionnelles en un temps record, avec Firebase intégré, gestion d'état Riverpod, navigation avancée et fonctionnalités hors ligne. Idéal pour démarrer rapidement des projets robustes avec authentification, stockage de données, analytics, crashlytics et support multiplateforme.

![Flutter Template](https://d2ms8rpfqc4h24.cloudfront.net/What_is_Flutter_f648a606af.png)

## 📝 Table des matières

- [À propos](#à-propos)
- [Fonctionnalités](#fonctionnalités)
- [Commencer](#commencer)
  - [Prérequis](#prérequis)
  - [Installation](#installation)
  - [Configuration de Firebase](#configuration-de-firebase)
- [Architecture](#architecture)
  - [Structure des dossiers](#structure-des-dossiers)
  - [Gestion d'état](#gestion-détat)
  - [Navigation](#navigation)
- [Services](#services)
  - [Authentication](#authentication)
  - [Firestore](#firestore)
  - [Stockage hors ligne](#stockage-hors-ligne)
  - [Notifications](#notifications)
  - [Analytics](#analytics)
  - [Crashlytics](#crashlytics)
  - [Mises à jour](#mises-à-jour)
- [Widgets](#widgets)
- [Tests](#tests)
- [Déploiement](#déploiement)
  - [Android](#android)
  - [iOS](#ios)
- [Contribution](#contribution)
- [Licence](#licence)
- [Documentation supplémentaire](#doc-sup)
- [Bonnes pratiques](#bonnes-pratiques)
- [Personnalisation](#personnalisation)
- [FAQ](#faq)
- [Performances](#perf)
- [Sécurité](#secu)
- [Analyse de code](#analyse)

## 🚀 À propos <a id='à-propos'></a>

Ce template Flutter est conçu pour accélérer le développement de vos applications en fournissant une base solide avec les meilleures pratiques, une architecture propre et des fonctionnalités prêtes à l'emploi. Il intègre Firebase pour l'authentification, le stockage de données, les notifications et l'analyse, ainsi que des fonctionnalités hors ligne pour une expérience utilisateur optimale.

## ✨ Fonctionnalités <a id='fonctionnalités'></a>

- 🔐 **Authentification complète** - Connexion, inscription et réinitialisation de mot de passe
- 🔄 **Synchronisation hors ligne** - Continuez à utiliser l'application sans connexion Internet
- 🧭 **Navigation avancée** - Utilisation de GoRouter pour une navigation fluide et typée
- 🎨 **Thème personnalisable** - Thèmes clair et sombre avec Material 3
- 📊 **Analytics** - Suivi des événements utilisateur avec Firebase Analytics
- 💾 **Stockage de données** - Utilisation de Firestore, Hive et SharedPreferences
- 🔔 **Notifications push** - Intégration de Firebase Cloud Messaging
- 🐞 **Gestion des erreurs** - Capture et rapport d'erreurs avec Firebase Crashlytics
- 🌐 **Gestion de réseau** - Gestion des requêtes HTTP avec Dio
- 📱 **Responsive** - S'adapte à différentes tailles d'écran
- 🧪 **Tests** - Configuration pour les tests unitaires et d'intégration
- 🔄 **CI/CD** - Intégration continue avec GitHub Actions

## 🏁 Commencer <a id='commencer'></a>

### Prérequis <a id='prérequis'></a>

- [Flutter](https://flutter.dev/docs/get-started/install) (version 3.7.2 ou supérieure)
- [Dart](https://dart.dev/get-dart) (version 3.0.0 ou supérieure)
- [Git](https://git-scm.com/downloads)
- [Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)

### Installation <a id='installation'></a>

1. Clonez ce dépôt :

   ```bash
   git clone https://github.com/yourusername/flutter_template.git your_project_name
   cd your_project_name
   ```

2. Supprimez le lien avec le dépôt Git d'origine :

   ```bash
   rm -rf .git
   git init
   ```

3. Installez les dépendances :

   ```bash
   flutter pub get
   ```

4. Exécutez le générateur de code :

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. Mettez à jour le nom et l'identifiant de l'application :
   - Modifiez `name` et `description` dans `pubspec.yaml`
   - Mettez à jour l'ID de l'application dans `android/app/build.gradle.kts` (cherchez `applicationId`)
   - Mettez à jour le Bundle ID dans Xcode pour iOS

### Configuration de Firebase <a id='configuration-de-firebase'></a>

1. Créez un nouveau projet Firebase sur la [console Firebase](https://console.firebase.google.com/)

2. Installez FlutterFire CLI si ce n'est pas déjà fait :

   ```bash
   dart pub global activate flutterfire_cli
   ```

3. Configurez Firebase pour votre projet :

   ```bash
   flutterfire configure --project=your-firebase-project-id
   ```

   Suivez les instructions pour sélectionner les plateformes (Android, iOS, Web) que vous souhaitez configurer.

4. Cela générera un fichier `lib/core/config/firebase_options.dart` avec vos configurations Firebase.

5. Activez les services Firebase nécessaires dans la console Firebase :

   - Authentication (Email/Password)
   - Cloud Firestore
   - Storage
   - Analytics
   - Crashlytics
   - Cloud Messaging

6. Pour Android, téléchargez le fichier `google-services.json` et placez-le dans `android/app/`.

7. Pour iOS, téléchargez le fichier `GoogleService-Info.plist` et ajoutez-le à votre projet iOS via Xcode.

8. Mettez à jour le fichier `firebase.json` à la racine du projet avec vos identifiants Firebase (vous pouvez vous baser sur `firebase.json.template`).

## 🏗 Architecture <a id='architecture'></a>

Ce template suit une architecture propre et modulaire pour faciliter la maintenance et l'évolutivité.

### Structure des dossiers <a id='structure-des-dossiers'></a>

```
lib/
├── core/                   # Fonctionnalités de base
│   ├── config/             # Configuration de l'application
│   ├── constants/          # Constantes globales
│   ├── di/                 # Injection de dépendances
│   ├── errors/             # Gestion des erreurs
│   ├── models/             # Modèles de base
│   ├── network/            # Configuration réseau
│   ├── providers/          # Providers globaux
│   ├── repositories/       # Repositories de base
│   ├── services/           # Services de l'application
│   └── utils/              # Utilitaires
├── features/               # Fonctionnalités de l'application
│   ├── auth/               # Authentification
│   ├── home/               # Écran d'accueil
│   ├── profile/            # Profil utilisateur
│   ├── settings/           # Paramètres
│   └── ...                 # Autres fonctionnalités
├── routes/                 # Configuration des routes
├── shared/                 # Éléments partagés
│   ├── models/             # Modèles partagés
│   ├── providers/          # Providers partagés
│   ├── repositories/       # Repositories partagés
│   └── widgets/            # Widgets réutilisables
└── theme/                  # Thème de l'application
```

### Gestion d'état <a id='gestion-détat'></a>

Ce template utilise [Riverpod](https://riverpod.dev/) pour la gestion d'état, offrant :

- Une gestion d'état réactive et typée
- Une séparation claire entre la logique métier et l'UI
- Une facilité de test grâce à l'injection de dépendances
- Une gestion des dépendances simplifiée

Exemple d'utilisation :

```dart
// Définition d'un provider
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() => state++;
}

// Utilisation dans un widget
class CounterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('Count: $count');
  }
}
```

### Navigation <a id='navigation'></a>

La navigation est gérée avec [GoRouter](https://pub.dev/packages/go_router), qui offre :

- Une navigation déclarative et typée
- Une gestion des paramètres de route
- Une intégration avec la navigation par onglets
- Un support pour les redirections basées sur l'authentification

Routes principales :

- `/home` - Écran d'accueil
- `/login` - Connexion
- `/register` - Inscription
- `/profile` - Profil utilisateur
- `/settings` - Paramètres

## 🛠 Services <a id='services'></a>

### Authentication <a id='authentication'></a>

Le service d'authentification (`AuthService`) gère :

- Connexion par email/mot de passe
- Inscription
- Réinitialisation de mot de passe
- Déconnexion
- État de connexion

Exemple d'utilisation :

```dart
final authService = getIt<AuthService>();

// Connexion
await authService.signInWithEmailAndPassword('user@example.com', 'password');

// Vérification de l'état de connexion
if (authService.isAuthenticated) {
  // L'utilisateur est connecté
}
```

### Firestore <a id='firestore'></a>

Les repositories (`UserRepository`, `NoteRepository`, `TaskRepository`) gèrent l'interaction avec Firestore :

- Création, lecture, mise à jour et suppression de données
- Synchronisation avec le stockage local
- Gestion des erreurs de connexion

### Stockage hors ligne <a id='stockage-hors-ligne'></a>

Le template inclut une gestion complète du mode hors ligne :

- Stockage local avec SharedPreferences et Hive
- Synchronisation automatique lorsque la connexion est rétablie
- Indicateur de statut de connexion
- File d'attente des opérations en attente

### Notifications <a id='notifications'></a>

Le service de notifications (`NotificationService`) gère :

- Réception des notifications push avec Firebase Cloud Messaging
- Affichage des notifications locales
- Gestion des actions sur les notifications
- Abonnement à des sujets pour des notifications ciblées

### Analytics <a id='analytics'></a>

Le service d'analytics (`AnalyticsService`) permet de :

- Suivre les événements utilisateur
- Enregistrer les écrans visités
- Suivre les conversions
- Définir des propriétés utilisateur

### Crashlytics <a id='crashlytics'></a>

Le service d'erreur (`ErrorService`) gère :

- Capture des erreurs non gérées
- Envoi des rapports d'erreur à Firebase Crashlytics
- Ajout d'informations contextuelles aux rapports
- Journalisation des événements précédant une erreur

### Mises à jour <a id='mises-à-jour'></a>

Le service de mise à jour (`UpdateService`) permet de :

- Vérifier les nouvelles versions de l'application
- Afficher un dialogue de mise à jour
- Rediriger vers le store pour la mise à jour
- Forcer les mises à jour critiques

## 🧩 Widgets <a id='widgets'></a>

Le template inclut de nombreux widgets réutilisables :

- `AppButton` - Bouton personnalisable avec différents styles
- `AppTextField` - Champ de texte avec validation
- `AppScaffold` - Structure de base des écrans avec navigation par onglets
- `CachedImage` - Image mise en cache avec gestion des erreurs
- `LoadingOverlay` - Superposition de chargement
- `ConnectivityIndicator` - Indicateur de statut de connexion
- `SyncManager` - Gestionnaire de synchronisation pour les données hors ligne
- `UpdateDialog` - Dialogue de mise à jour de l'application

## 🧪 Tests <a id='tests'></a>

Le template est configuré pour les tests unitaires et d'intégration :

- Tests unitaires pour les services et repositories
- Tests de widgets pour l'interface utilisateur
- Mocks pour les dépendances externes

Pour exécuter les tests :

```bash
# Tests unitaires
flutter test

# Tests avec couverture
flutter test --coverage
```

## 📦 Déploiement <a id='déploiement'></a>

### Android <a id='android'></a>

1. Mettez à jour la version dans `pubspec.yaml`
2. Créez une clé de signature si vous n'en avez pas déjà une :
   ```bash
   keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
   ```
3. Créez un fichier `android/key.properties` avec vos informations de clé
4. Construisez l'APK ou le bundle App :

   ```bash
   # APK
   flutter build apk --release

   # App Bundle
   flutter build appbundle --release
   ```

### iOS <a id='ios'></a>

1. Mettez à jour la version dans `pubspec.yaml`
2. Ouvrez le projet dans Xcode :
   ```bash
   open ios/Runner.xcworkspace
   ```
3. Configurez les certificats et profils de provisionnement
4. Construisez l'application :
   ```bash
   flutter build ios --release
   ```
5. Archivez et soumettez via Xcode

## 🤝 Contribution <a id='contribution'></a>

Les contributions sont les bienvenues ! Voici comment vous pouvez contribuer :

1. Fork ce dépôt
2. Créez une branche pour votre fonctionnalité (`git checkout -b feature/amazing-feature`)
3. Committez vos changements (`git commit -m 'Add some amazing feature'`)
4. Push vers la branche (`git push origin feature/amazing-feature`)
5. Ouvrez une Pull Request

## 📄 Licence <a id='licence'></a>

Ce projet est sous licence MIT - voir le fichier [LICENSE](LICENSE) pour plus de détails.

---

## 📚 Documentation supplémentaire <a id='doc-sup'></a>

Pour une documentation plus détaillée sur les différents aspects du template, consultez les ressources suivantes :

### Services principaux

#### Connectivité et mode hors ligne

Le service `ConnectivityService` surveille l'état de la connexion internet et notifie les autres composants de l'application. Combiné avec les repositories qui implémentent `OfflineRepositoryBase`, il permet une expérience utilisateur fluide même en l'absence de connexion.

```dart
// Vérifier l'état de la connexion
final connectivityService = getIt<ConnectivityService>();
if (connectivityService.currentStatus == ConnectionStatus.online) {
  // Connecté à Internet
}

// Écouter les changements de connectivité
connectivityService.connectionStatus.listen((status) {
  if (status == ConnectionStatus.online) {
    // La connexion est rétablie
  }
});
```

#### Gestion du cache d'images

Le service `ImageCacheService` offre une gestion avancée du cache d'images :

```dart
final imageCacheService = getIt<ImageCacheService>();

// Précharger des images
await imageCacheService.preloadImages(['https://example.com/image1.jpg', 'https://example.com/image2.jpg']);

// Vider le cache
await imageCacheService.clearCache();

// Obtenir la taille du cache
final cacheSize = await imageCacheService.getCacheSize();
final formattedSize = imageCacheService.formatCacheSize(cacheSize);
```

#### Retour haptique

Le service `HapticService` permet d'ajouter des retours haptiques pour améliorer l'expérience utilisateur :

```dart
final hapticService = getIt<HapticService>();

// Déclencher différents types de retour haptique
hapticService.feedback(HapticFeedbackType.light);
hapticService.feedback(HapticFeedbackType.medium);
hapticService.feedback(HapticFeedbackType.heavy);
hapticService.feedback(HapticFeedbackType.success);
hapticService.feedback(HapticFeedbackType.error);

// Vibration personnalisée
hapticService.customVibration([0, 100, 50, 200]);
```

### Injection de dépendances

Le template utilise [GetIt](https://pub.dev/packages/get_it) et [Injectable](https://pub.dev/packages/injectable) pour l'injection de dépendances :

```dart
// Accéder à un service
final authService = getIt<AuthService>();

// Définir un service injectable
@lazySingleton
class MyService {
  // ...
}

// Initialiser l'injection de dépendances
await configureDependencies();
```

Pour ajouter un nouveau service injectable :

1. Ajoutez l'annotation `@lazySingleton` ou `@injectable` à votre classe
2. Exécutez la commande de génération de code :
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Configuration des environnements

Le template prend en charge différents environnements (développement, staging, production) via la classe `EnvConfig` :

```dart
// Initialiser l'environnement
EnvConfig.initialize(Environment.dev);

// Accéder à la configuration
final apiUrl = EnvConfig.instance.apiUrl;
final enableLogging = EnvConfig.instance.enableLogging;

// Vérifier l'environnement actuel
if (EnvConfig.isDevelopment) {
  // Code spécifique au développement
}
```

Pour ajouter ou modifier des configurations d'environnement, modifiez la classe `EnvConfig` dans `lib/core/config/env_config.dart`.

### Journalisation

Le template inclut un système de journalisation personnalisé via la classe `AppLogger` :

```dart
// Différents niveaux de journalisation
AppLogger.debug('Message de débogage');
AppLogger.info('Information');
AppLogger.warning('Avertissement');
AppLogger.error('Erreur', exception, stackTrace);
```

La journalisation est automatiquement désactivée en production pour des performances optimales.

## 🧠 Bonnes pratiques <a id='bonnes-pratiques'></a>

### Gestion d'état

- Utilisez les providers Riverpod pour la gestion d'état globale
- Préférez les `StateNotifierProvider` pour les états complexes
- Utilisez `ref.watch()` pour observer les changements d'état
- Utilisez `ref.read()` pour les actions ponctuelles

### Navigation

- Définissez toutes les routes dans `lib/routes/app_router.dart`
- Utilisez les méthodes du `NavigationService` pour la navigation
- Implémentez des redirections basées sur l'authentification

### Modèles de données

- Créez des modèles immuables avec des méthodes `copyWith()`
- Implémentez `toJson()` et `fromJson()` pour la sérialisation
- Utilisez `freezed` pour les modèles complexes

### UI

- Utilisez les widgets personnalisés du template pour la cohérence
- Suivez les guidelines Material Design 3
- Testez sur différentes tailles d'écran pour assurer la responsivité

## 🔧 Personnalisation <a id='personnalisation'></a>

### Thème

Le thème de l'application est défini dans `lib/theme/app_theme.dart`. Vous pouvez personnaliser :

- Les couleurs primaires et secondaires
- Les styles de texte
- Les formes des composants
- Les animations
- Les thèmes clair et sombre

```dart
// Exemple de personnalisation du thème
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    primary: Color(0xFF6200EE), // Votre couleur primaire
    // ...autres couleurs
  ),
  // ...autres personnalisations
);
```

### Icône et splash screen

Pour personnaliser l'icône de l'application et l'écran de démarrage :

1. Remplacez les fichiers dans `assets/icons/` et `assets/images/`
2. Exécutez les commandes suivantes :

```bash
# Générer les icônes de l'application
flutter pub run flutter_launcher_icons:main

# Générer l'écran de démarrage
flutter pub run flutter_native_splash:create
```

Les configurations pour ces outils se trouvent dans `pubspec.yaml`.

## 🤔 FAQ <a id='faq'></a>

### Comment ajouter un nouveau service ?

1. Créez une nouvelle classe dans `lib/core/services/`
2. Ajoutez l'annotation `@lazySingleton` ou `@injectable`
3. Exécutez le générateur de code
4. Accédez au service via `getIt<VotreService>()`

### Comment ajouter une nouvelle route ?

Ajoutez une nouvelle route dans `lib/routes/app_router.dart` :

```dart
GoRoute(
  path: '/votre-route',
  name: 'votre-route',
  pageBuilder: (context, state) =>
    const NoTransitionPage(child: VotreEcran(), name: 'VotreEcran'),
),
```

### Comment gérer les mises à jour de l'application ?

Le service `UpdateService` vérifie automatiquement les mises à jour au démarrage de l'application. Vous pouvez également déclencher une vérification manuellement :

```dart
final updateService = getIt<UpdateService>();
final updateInfo = await updateService.checkForUpdate();

if (updateInfo != null) {
  // Afficher le dialogue de mise à jour
}
```

### Comment ajouter une nouvelle fonctionnalité hors ligne ?

1. Créez un nouveau modèle qui implémente `SyncableModel`
2. Créez un repository qui étend `OfflineRepositoryBase`
3. Implémentez les méthodes requises pour la synchronisation
4. Créez un provider avec `createOfflineDataProvider`

## 📊 Performances <a id='perf'></a>

Le template est optimisé pour les performances :

- Utilisation du cache pour les images et les données
- Chargement différé des ressources
- Animations optimisées
- Journalisation désactivée en production
- Compression des assets

## 🔒 Sécurité <a id='secu'></a>

Le template inclut plusieurs mesures de sécurité :

- Authentification sécurisée avec Firebase
- Stockage sécurisé des données sensibles
- Validation des entrées utilisateur
- Protection contre les injections
- Gestion sécurisée des tokens

## 📈 Analyse de code <a id='analyse'></a>

Le template est configuré avec des règles d'analyse strictes pour maintenir une qualité de code élevée :

```bash
# Exécuter l'analyse de code
flutter analyze

# Formater le code
flutter format .
```

Les règles d'analyse sont définies dans `analysis_options.yaml`.

---

Ce README devrait vous donner une bonne compréhension du template et de ses fonctionnalités. N'hésitez pas à explorer le code source pour plus de détails et à consulter la documentation officielle de Flutter et Firebase pour des informations complémentaires.

Bonne programmation ! 🚀
