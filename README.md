# Flutter Template

Un template Flutter complet avec Firebase, gestion d'état, navigation, et bien plus encore.

![Flutter Logo](https://storage.googleapis.com/cms-storage-bucket/c823e53b3a1a7b0d36a9.png)

## Fonctionnalités

- 🔐 **Authentification**: Connexion par email/mot de passe avec Firebase
- 🎨 **UI Components**: Widgets personnalisés et support de thèmes (clair/sombre)
- 📱 **Navigation**: Navigation par onglets avec GoRouter
- 🔄 **Gestion d'état**: Riverpod pour la gestion d'état
- 🔥 **Intégration Firebase**: Firestore, Storage, Messaging, Analytics, Crashlytics
- 🧪 **Tests**: Tests unitaires et de widgets
- 🚀 **CI/CD**: Workflow GitHub Actions
- 📊 **Analytics**: Intégration de Firebase Analytics
- 📱 **Notifications Push**: Firebase Cloud Messaging
- 🔍 **Injection de dépendances**: GetIt et Injectable
- 🌐 **Réseau**: Dio pour les requêtes API
- 💾 **Stockage**: Hive et SharedPreferences

## Prérequis

- Flutter SDK (version 3.0.0 ou supérieure)
- Dart SDK (version 3.0.0 ou supérieure)
- Android Studio / VS Code
- Compte Firebase
- Git

## Installation et configuration

### 1. Cloner le template

```bash
git clone https://github.com/yourusername/flutter_template.git
cd flutter_template
```

### 2. Installer les dépendances

```bash
flutter pub get
```

### 3. Mettre à jour la configuration Gradle (pour éviter les problèmes de compatibilité Java)

Ouvrez `android/gradle/wrapper/gradle-wrapper.properties` et mettez à jour:

```properties
distributionUrl=https\://services.gradle.org/distributions/gradle-8.2-all.zip
```

Modifiez `android/build.gradle`:

```groovy
buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        // Ajoutez cette ligne pour Firebase
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

Modifiez `android/app/build.gradle`:

```groovy
android {
    namespace "com.yourname.flutter_template"
    compileSdkVersion 34

    // Reste du fichier...
}

// À la fin du fichier, ajoutez:
apply plugin: 'com.google.gms.google-services'
```

### 4. Configurer Firebase

#### 4.1 Installer FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

#### 4.2 Créer un projet Firebase

- Rendez-vous sur [Firebase Console](https://console.firebase.google.com/)
- Cliquez sur "Ajouter un projet" et suivez les instructions

#### 4.3 Configurer Firebase pour votre application

```bash
flutterfire configure --project=your-firebase-project-id
```

Cette commande va:

- Vous demander quelles plateformes vous souhaitez configurer
- Générer les fichiers de configuration nécessaires:
  - `lib/core/config/firebase_options.dart`
  - `firebase.json`
  - `android/app/google-services.json` (pour Android)
  - `ios/Runner/GoogleService-Info.plist` (pour iOS)

> **Important**: Ces fichiers contiennent des informations sensibles et ne doivent pas être commités dans un dépôt public. Ils sont déjà inclus dans le `.gitignore`.

### 5. Générer les fichiers d'injection de dépendances

L'injection de dépendances utilise `build_runner` pour générer du code:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Si vous rencontrez des erreurs avec cette approche, vous pouvez utiliser l'implémentation manuelle fournie dans `lib/core/di/injection.dart`.

### 6. Configurer les règles de sécurité Firebase

Accédez à la console Firebase pour configurer les règles de sécurité pour:

- Firestore
- Storage
- Realtime Database (si utilisé)

### 7. Exécuter l'application

```bash
flutter run
```

## Structure du projet

```
lib/
├── core/                 # Fonctionnalités centrales
│   ├── config/           # Configuration de l'application
│   ├── constants/        # Constantes de l'application
│   ├── di/               # Injection de dépendances
│   ├── errors/           # Gestion des erreurs
│   ├── network/          # Code lié au réseau
│   ├── services/         # Services principaux
│   └── utils/            # Fonctions utilitaires
├── features/             # Fonctionnalités de l'application
│   ├── auth/             # Fonctionnalité d'authentification
│   ├── home/             # Fonctionnalité d'accueil
│   ├── profile/          # Fonctionnalité de profil
│   ├── notifications/    # Fonctionnalité de notifications
│   └── settings/         # Fonctionnalité de paramètres
├── routes/               # Routes de navigation
├── shared/               # Code partagé
│   ├── models/           # Modèles partagés
│   ├── providers/        # Providers partagés
│   ├── repositories/     # Repositories partagés
│   └── widgets/          # Widgets partagés
├── theme/                # Thème de l'application
└── main.dart             # Point d'entrée de l'application
```

## Architecture

Ce template suit les principes de Clean Architecture avec le pattern MVVM:

- **Model**: Données et logique métier
- **View**: Composants UI
- **ViewModel**: Connecte le Model et la View

L'application est structurée en features, chaque feature ayant:

- **Data**: Sources de données, repositories et modèles
- **Domain**: Cas d'utilisation et logique métier
- **Presentation**: Composants UI et view models

## Gestion d'état

Ce template utilise Riverpod pour la gestion d'état, offrant:

- Gestion d'état réactive
- Injection de dépendances
- Facilité de test
- Reconstructions efficaces

## Navigation

GoRouter est utilisé pour la navigation. L'application a une barre de navigation inférieure avec des onglets pour:

- Accueil
- Profil
- Notifications
- Paramètres

## Thèmes

L'application prend en charge les thèmes clair et sombre, avec un sélecteur de thème dans l'écran Paramètres.

## Tests

Le template inclut:

- Tests unitaires pour la logique métier
- Tests de widgets pour les composants UI
- Tests d'intégration pour les workflows de fonctionnalités

Exécutez les tests avec:

```bash
flutter test
```

## CI/CD

GitHub Actions est configuré pour:

- Vérification du formatage du code
- Analyse statique
- Exécution des tests
- Construction de l'application

## Extensions VS Code recommandées

- Flutter (Dart-Code.flutter)
- Dart (Dart-Code.dart-code)
- Flutter Widget Snippets (Nash.awesome-flutter-snippets)
- Pubspec Assist (jeroen-meijer.pubspec-assist)
- Better Comments (aaron-bond.better-comments)
- Todo Tree (Gruntfuggly.todo-tree)
- GitLens (eamodio.gitlens)

## Personnalisation

### Changer le nom de l'application et le Bundle ID

1. Mettez à jour le nom de l'application dans `pubspec.yaml`:

   ```yaml
   name: your_app_name
   description: Votre description d'application
   ```

2. Mettez à jour le Bundle ID:
   - Android: Modifiez `android/app/build.gradle`
   - iOS: Modifiez `ios/Runner/Info.plist`

### Changer l'icône de l'application

Utilisez le package flutter_launcher_icons:

1. Configurez dans `pubspec.yaml`:

   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/images/app_icon.png"
   ```

2. Exécutez:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

### Changer l'écran de démarrage

Utilisez le package flutter_native_splash:

1. Configurez dans `pubspec.yaml`:

   ```yaml
   flutter_native_splash:
     color: "#ffffff"
     image: assets/images/splash_logo.png
     color_dark: "#121212"
     image_dark: assets/images/splash_logo_dark.png
   ```

2. Exécutez:
   ```bash
   flutter pub run flutter_native_splash:create
   ```

## Résolution des problèmes courants

### Erreur de compatibilité Gradle/Java

Si vous rencontrez une erreur comme `Unsupported class file major version 65`, cela signifie que votre version de Java est incompatible avec la version de Gradle. Suivez les étapes de la section "Mettre à jour la configuration Gradle" ci-dessus.

### Erreurs d'injection de dépendances

Si vous voyez des erreurs concernant `injection.config.dart` manquant:

1. Assurez-vous d'avoir exécuté:

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. Si les erreurs persistent, utilisez l'approche manuelle d'injection de dépendances fournie dans le template.

### Erreurs Firebase

Si vous rencontrez des erreurs liées à Firebase:

1. Vérifiez que vous avez correctement exécuté `flutterfire configure`
2. Assurez-vous que les fichiers de configuration Firebase sont au bon endroit
3. Vérifiez que vous avez ajouté les plugins Firebase nécessaires dans `pubspec.yaml`
4. Assurez-vous que l'initialisation Firebase est appelée avant d'utiliser les services Firebase

### Conflits de noms dans le code

Si vous rencontrez des erreurs de type "ambiguous import", utilisez des préfixes d'import ou renommez les classes en conflit comme expliqué dans le code du template.

## Contribuer

1. Forkez le dépôt
2. Créez votre branche de fonctionnalité (`git checkout -b feature/amazing-feature`)
3. Committez vos changements (`git commit -m 'Add some amazing feature'`)
4. Poussez vers la branche (`git push origin feature/amazing-feature`)
5. Ouvrez une Pull Request

## Licence

Ce projet est sous licence MIT - voir le fichier LICENSE pour plus de détails.

## Remerciements

- [Flutter](https://flutter.dev/)
- [Firebase](https://firebase.google.com/)
- [Riverpod](https://riverpod.dev/)
- [GoRouter](https://pub.dev/packages/go_router)
- [GetIt](https://pub.dev/packages/get_it)
- [Injectable](https://pub.dev/packages/injectable)
- [Dio](https://pub.dev/packages/dio)
- [Hive](https://pub.dev/packages/hive)

---

Développé avec ❤️ pour accélérer vos projets Flutter
