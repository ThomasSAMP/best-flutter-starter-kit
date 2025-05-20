# Best Flutter Starter Kit

[![en](https://img.shields.io/badge/lang-en-red.svg)](https://github.com/ThomasSAMP/best-flutter-starter-kit/blob/master/README.md)
[![fr](https://img.shields.io/badge/lang-fr-blue.svg)](https://github.com/ThomasSAMP/best-flutter-starter-kit/blob/master/README.fr.md)

A complete and ready-to-use template for developing professional Flutter applications in record time, with integrated Firebase, Riverpod state management, advanced navigation, and offline capabilities. Ideal for quickly starting robust projects with authentication, data storage, analytics, crashlytics, and multi-platform support.

![Flutter Template](https://d2ms8rpfqc4h24.cloudfront.net/What_is_Flutter_f648a606af.png)

## 📝 Table of Contents

- [About](#about)
- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Firebase Configuration](#firebase-configuration)
- [Architecture](#architecture)
  - [Folder Structure](#folder-structure)
  - [State Management](#state-management)
  - [Navigation](#navigation)
- [Services](#services)
  - [Authentication](#authentication)
  - [Firestore](#firestore)
  - [Offline Storage](#offline-storage)
  - [Notifications](#notifications)
  - [Analytics](#analytics)
  - [Crashlytics](#crashlytics)
  - [Updates](#updates)
- [Widgets](#widgets)
- [Tests](#tests)
- [Deployment](#deployment)
  - [Android](#android)
  - [iOS](#ios)
- [Contribution](#contribution)
- [License](#license)
- [Additional Documentation](#additional-documentation)
- [Best Practices](#best-practices)
- [Customization](#customization)
- [FAQ](#faq)
- [Performance](#performance)
- [Security](#security)
- [Code Analysis](#code-analysis)

## 🚀 About <a id='about'></a>

This Flutter template is designed to accelerate your application development by providing a solid foundation with best practices, clean architecture, and ready-to-use features. It integrates Firebase for authentication, data storage, notifications, and analytics, as well as offline capabilities for an optimal user experience.

## ✨ Features <a id='features'></a>

- 🔐 **Complete Authentication** - Login, registration, and password reset
- 🔄 **Offline Synchronization** - Continue using the app without an internet connection
- 🧭 **Advanced Navigation** - Using GoRouter for smooth and typed navigation
- 🎨 **Customizable Theme** - Light and dark themes with Material 3
- 📊 **Analytics** - Track user events with Firebase Analytics
- 💾 **Data Storage** - Using Firestore, Hive, and SharedPreferences
- 🔔 **Push Notifications** - Firebase Cloud Messaging integration
- 🐞 **Error Handling** - Capture and report errors with Firebase Crashlytics
- 🌐 **Network Management** - Handle HTTP requests with Dio
- 📱 **Responsive** - Adapts to different screen sizes
- 🧪 **Tests** - Configuration for unit and integration tests
- 🔄 **CI/CD** - Continuous integration with GitHub Actions

## 🏁 Getting Started <a id='getting-started'></a>

### Prerequisites <a id='prerequisites'></a>

- [Flutter](https://flutter.dev/docs/get-started/install) (version 3.7.2 or higher)
- [Dart](https://dart.dev/get-dart) (version 3.0.0 or higher)
- [Git](https://git-scm.com/downloads)
- [Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli)
- [FlutterFire CLI](https://firebase.flutter.dev/docs/cli/)

### Installation <a id='installation'></a>

1. Clone this repository:

   ```bash
   git clone https://github.com/yourusername/flutter_template.git your_project_name
   cd your_project_name
   ```

2. Remove the link to the original Git repository:

   ```bash
   rm -rf .git
   git init
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the code generator:

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. Update the app name and identifier:
   - Modify `name` and `description` in `pubspec.yaml`
   - Update the application ID in `android/app/build.gradle.kts` (look for `applicationId`)
   - Update the Bundle ID in Xcode for iOS

### Firebase Configuration <a id='firebase-configuration'></a>

1. Create a new Firebase project on the [Firebase console](https://console.firebase.google.com/)

2. Install FlutterFire CLI if not already done:

   ```bash
   dart pub global activate flutterfire_cli
   ```

3. Configure Firebase for your project:

   ```bash
   flutterfire configure --project=your-firebase-project-id
   ```

   Follow the instructions to select the platforms (Android, iOS, Web) you want to configure.

4. This will generate a `lib/core/config/firebase_options.dart` file with your Firebase configurations.

5. Enable the necessary Firebase services in the Firebase console:

   - Authentication (Email/Password)
   - Cloud Firestore
   - Storage
   - Analytics
   - Crashlytics
   - Cloud Messaging

6. For Android, download the `google-services.json` file and place it in `android/app/`.

7. For iOS, download the `GoogleService-Info.plist` file and add it to your iOS project via Xcode.

8. Update the `firebase.json` file at the root of the project with your Firebase credentials (you can base it on `firebase.json.template`).

## 🏗 Architecture <a id='architecture'></a>

This template follows a clean and modular architecture for easy maintenance and scalability.

### Folder Structure <a id='folder-structure'></a>

```
lib/
├── core/                   # Core functionality
│   ├── config/             # Application configuration
│   ├── constants/          # Global constants
│   ├── di/                 # Dependency injection
│   ├── errors/             # Error handling
│   ├── models/             # Base models
│   ├── network/            # Network configuration
│   ├── providers/          # Global providers
│   ├── repositories/       # Base repositories
│   ├── services/           # Application services
│   └── utils/              # Utilities
├── features/               # Application features
│   ├── auth/               # Authentication
│   ├── home/               # Home screen
│   ├── profile/            # User profile
│   ├── settings/           # Settings
│   └── ...                 # Other features
├── routes/                 # Route configuration
├── shared/                 # Shared elements
│   ├── models/             # Shared models
│   ├── providers/          # Shared providers
│   ├── repositories/       # Shared repositories
│   └── widgets/            # Reusable widgets
└── theme/                  # Application theme
```

### State Management <a id='state-management'></a>

This template uses [Riverpod](https://riverpod.dev/) for state management, offering:

- Reactive and typed state management
- Clear separation between business logic and UI
- Ease of testing through dependency injection
- Simplified dependency management

Usage example:

```dart
// Provider definition
final counterProvider = StateNotifierProvider<CounterNotifier, int>((ref) {
  return CounterNotifier();
});

class CounterNotifier extends StateNotifier<int> {
  CounterNotifier() : super(0);

  void increment() => state++;
}

// Usage in a widget
class CounterWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return Text('Count: $count');
  }
}
```

### Navigation <a id='navigation'></a>

Navigation is managed with [GoRouter](https://pub.dev/packages/go_router), which offers:

- Declarative and typed navigation
- Route parameter management
- Integration with tab navigation
- Support for authentication-based redirections

Main routes:

- `/home` - Home screen
- `/login` - Login
- `/register` - Registration
- `/profile` - User profile
- `/settings` - Settings

## 🛠 Services <a id='services'></a>

### Authentication <a id='authentication'></a>

The authentication service (`AuthService`) manages:

- Email/password login
- Registration
- Password reset
- Logout
- Login state

Usage example:

```dart
final authService = getIt<AuthService>();

// Login
await authService.signInWithEmailAndPassword('user@example.com', 'password');

// Check login state
if (authService.isAuthenticated) {
  // User is logged in
}
```

### Firestore <a id='firestore'></a>

The repositories (`UserRepository`, `NoteRepository`, `TaskRepository`) handle interaction with Firestore:

- Create, read, update, and delete data
- Synchronization with local storage
- Connection error handling

### Offline Storage <a id='offline-storage'></a>

The template includes complete offline mode management:

- Local storage with SharedPreferences and Hive
- Automatic synchronization when connection is restored
- Connection status indicator
- Queue for pending operations

### Notifications <a id='notifications'></a>

The notification service (`NotificationService`) manages:

- Receiving push notifications with Firebase Cloud Messaging
- Displaying local notifications
- Handling notification actions
- Subscribing to topics for targeted notifications

### Analytics <a id='analytics'></a>

The analytics service (`AnalyticsService`) allows:

- Tracking user events
- Recording visited screens
- Tracking conversions
- Setting user properties

### Crashlytics <a id='crashlytics'></a>

The error service (`ErrorService`) handles:

- Capturing unhandled errors
- Sending error reports to Firebase Crashlytics
- Adding contextual information to reports
- Logging events preceding an error

### Updates <a id='updates'></a>

The update service (`UpdateService`) allows:

- Checking for new versions of the application
- Displaying an update dialog
- Redirecting to the store for updates
- Forcing critical updates

## 🧩 Widgets <a id='widgets'></a>

The template includes many reusable widgets:

- `AppButton` - Customizable button with different styles
- `AppTextField` - Text field with validation
- `AppScaffold` - Basic screen structure with tab navigation
- `CachedImage` - Cached image with error handling
- `LoadingOverlay` - Loading overlay
- `ConnectivityIndicator` - Connection status indicator
- `SyncManager` - Synchronization manager for offline data
- `UpdateDialog` - Application update dialog

## 🧪 Tests <a id='tests'></a>

The template is configured for unit and integration tests:

- Unit tests for services and repositories
- Widget tests for the user interface
- Mocks for external dependencies

To run the tests:

```bash
# Unit tests
flutter test

# Tests with coverage
flutter test --coverage
```

## 📦 Deployment <a id='deployment'></a>

### Android <a id='android'></a>

1. Update the version in `pubspec.yaml`
2. Create a signing key if you don't already have one:
   ```bash
   keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
   ```
3. Create an `android/key.properties` file with your key information
4. Build the APK or App Bundle:

   ```bash
   # APK
   flutter build apk --release

   # App Bundle
   flutter build appbundle --release
   ```

### iOS <a id='ios'></a>

1. Update the version in `pubspec.yaml`
2. Open the project in Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
3. Configure certificates and provisioning profiles
4. Build the application:
   ```bash
   flutter build ios --release
   ```
5. Archive and submit via Xcode

## 🤝 Contribution <a id='contribution'></a>

Contributions are welcome! Here's how you can contribute:

1. Fork this repository
2. Create a branch for your feature (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License <a id='license'></a>

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 📚 Additional Documentation <a id='additional-documentation'></a>

For more detailed documentation on different aspects of the template, check out the following resources:

### Core Services

#### Connectivity and Offline Mode

The `ConnectivityService` monitors the internet connection status and notifies other components of the application. Combined with repositories that implement `OfflineRepositoryBase`, it provides a smooth user experience even without an internet connection.

```dart
// Check connection status
final connectivityService = getIt<ConnectivityService>();
if (connectivityService.currentStatus == ConnectionStatus.online) {
  // Connected to the Internet
}

// Listen for connectivity changes
connectivityService.connectionStatus.listen((status) {
  if (status == ConnectionStatus.online) {
    // Connection is restored
  }
});
```

#### Image Cache Management

The `ImageCacheService` offers advanced image cache management:

```dart
final imageCacheService = getIt<ImageCacheService>();

// Preload images
await imageCacheService.preloadImages(['https://example.com/image1.jpg', 'https://example.com/image2.jpg']);

// Clear cache
await imageCacheService.clearCache();

// Get cache size
final cacheSize = await imageCacheService.getCacheSize();
final formattedSize = imageCacheService.formatCacheSize(cacheSize);
```

#### Haptic Feedback

The `HapticService` allows adding haptic feedback to improve user experience:

```dart
final hapticService = getIt<HapticService>();

// Trigger different types of haptic feedback
hapticService.feedback(HapticFeedbackType.light);
hapticService.feedback(HapticFeedbackType.medium);
hapticService.feedback(HapticFeedbackType.heavy);
hapticService.feedback(HapticFeedbackType.success);
hapticService.feedback(HapticFeedbackType.error);

// Custom vibration
hapticService.customVibration([0, 100, 50, 200]);
```

### Dependency Injection

The template uses [GetIt](https://pub.dev/packages/get_it) and [Injectable](https://pub.dev/packages/injectable) for dependency injection:

```dart
// Access a service
final authService = getIt<AuthService>();

// Define an injectable service
@lazySingleton
class MyService {
  // ...
}

// Initialize dependency injection
await configureDependencies();
```

To add a new injectable service:

1. Add the `@lazySingleton` or `@injectable` annotation to your class
2. Run the code generation command:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

### Environment Configuration

The template supports different environments (development, staging, production) via the `EnvConfig` class:

```dart
// Initialize environment
EnvConfig.initialize(Environment.dev);

// Access configuration
final apiUrl = EnvConfig.instance.apiUrl;
final enableLogging = EnvConfig.instance.enableLogging;

// Check current environment
if (EnvConfig.isDevelopment) {
  // Development-specific code
}
```

To add or modify environment configurations, edit the `EnvConfig` class in `lib/core/config/env_config.dart`.

### Logging

The template includes a custom logging system via the `AppLogger` class:

```dart
// Different logging levels
AppLogger.debug('Debug message');
AppLogger.info('Information');
AppLogger.warning('Warning');
AppLogger.error('Error', exception, stackTrace);
```

Logging is automatically disabled in production for optimal performance.

## 🧠 Best Practices <a id='best-practices'></a>

### State Management

- Use Riverpod providers for global state management
- Prefer `StateNotifierProvider` for complex states
- Use `ref.watch()` to observe state changes
- Use `ref.read()` for one-time actions

### Navigation

- Define all routes in `lib/routes/app_router.dart`
- Use the `NavigationService` methods for navigation
- Implement authentication-based redirections

### Data Models

- Create immutable models with `copyWith()` methods
- Implement `toJson()` and `fromJson()` for serialization
- Use `freezed` for complex models

### UI

- Use the template's custom widgets for consistency
- Follow Material Design 3 guidelines
- Test on different screen sizes to ensure responsiveness

## 🔧 Customization <a id='customization'></a>

### Theme

The application theme is defined in `lib/theme/app_theme.dart`. You can customize:

- Primary and secondary colors
- Text styles
- Component shapes
- Animations
- Light and dark themes

```dart
// Example of theme customization
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme(
    primary: Color(0xFF6200EE), // Your primary color
    // ...other colors
  ),
  // ...other customizations
);
```

### App Icon and Splash Screen

To customize the application icon and splash screen:

1. Replace the files in `assets/icons/` and `assets/images/`
2. Run the following commands:

```bash
# Generate application icons
flutter pub run flutter_launcher_icons:main

# Generate splash screen
flutter pub run flutter_native_splash:create
```

The configurations for these tools are found in `pubspec.yaml`.

## 🤔 FAQ <a id='faq'></a>

### How to add a new service?

1. Create a new class in `lib/core/services/`
2. Add the `@lazySingleton` or `@injectable` annotation
3. Run the code generator
4. Access the service via `getIt<YourService>()`

### How to add a new route?

Add a new route in `lib/routes/app_router.dart`:

```dart
GoRoute(
  path: '/your-route',
  name: 'your-route',
  pageBuilder: (context, state) =>
    const NoTransitionPage(child: YourScreen(), name: 'YourScreen'),
),
```

### How to handle application updates?

The `UpdateService` automatically checks for updates when the application starts. You can also trigger a check manually:

```dart
final updateService = getIt<UpdateService>();
final updateInfo = await updateService.checkForUpdate();

if (updateInfo != null) {
  // Display the update dialog
}
```

### How to add a new offline feature?

1. Create a new model that implements `SyncableModel`
2. Create a repository that extends `OfflineRepositoryBase`
3. Implement the required methods for synchronization
4. Create a provider with `createOfflineDataProvider`

## 📊 Performance <a id='performance'></a>

The template is optimized for performance:

- Cache usage for images and data
- Lazy loading of resources
- Optimized animations
- Logging disabled in production
- Asset compression

## 🔒 Security <a id='security'></a>

The template includes several security measures:

- Secure authentication with Firebase
- Secure storage of sensitive data
- User input validation
- Protection against injections
- Secure token management

## 📈 Code Analysis <a id='code-analysis'></a>

The template is configured with strict analysis rules to maintain high code quality:

```bash
# Run code analysis
flutter analyze

# Format code
flutter format .
```

The analysis rules are defined in `analysis_options.yaml`.

---

This README should give you a good understanding of the template and its features. Feel free to explore the source code for more details and check the official Flutter and Firebase documentation for additional information.

Happy coding! 🚀
