# MegaVent Setup Instructions

This document provides comprehensive setup instructions for the MegaVent event management platform.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Firebase Configuration](#firebase-configuration)
- [Flutter Setup](#flutter-setup)
- [Project Configuration](#project-configuration)
- [Development Environment](#development-environment)
- [Testing Setup](#testing-setup)
- [Deployment](#deployment)
- [Troubleshooting](#troubleshooting)

## Prerequisites

### System Requirements

**Flutter Development:**
- Flutter SDK 3.13.0 or higher
- Dart SDK 3.1.0 or higher
- Git version control

**For Android Development:**
- Android Studio Arctic Fox or newer
- Android SDK 21 or higher
- Java Development Kit (JDK) 11 or higher

**For iOS Development (macOS only):**
- Xcode 14.0 or higher
- iOS 12.0 or higher
- macOS 10.15.7 or higher

**Additional Tools:**
- Firebase CLI
- Node.js 16.0 or higher (for Firebase CLI)
- Code editor (VS Code recommended)

### Installing Prerequisites

1. **Install Flutter:**
   ```bash
   # Download Flutter SDK from https://flutter.dev/docs/get-started/install
   # Extract and add to PATH
   export PATH="$PATH:`pwd`/flutter/bin"
   
   # Verify installation
   flutter doctor
   ```

2. **Install Firebase CLI:**
   ```bash
   npm install -g firebase-tools
   firebase --version
   ```

3. **Install VS Code Extensions (Recommended):**
   - Flutter
   - Dart
   - Firebase
   - GitLens

## Firebase Configuration

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Enter project name: `megavent-app` (or your preferred name)
4. Enable Google Analytics (recommended)
5. Select or create Analytics account
6. Click "Create project"

### Step 2: Enable Firebase Services

1. **Authentication:**
   - Go to Authentication → Sign-in method
   - Enable "Email/Password"
   - Configure authorized domains if needed

2. **Firestore Database:**
   - Go to Firestore Database → Create database
   - Choose "Start in test mode" for development
   - Select appropriate location (closest to users)

3. **Cloud Storage:**
   - Go to Storage → Get started
   - Start in test mode
   - Choose same location as Firestore

4. **Cloud Messaging (Optional):**
   - Go to Cloud Messaging
   - No additional setup required initially

### Step 3: Configure Firebase Apps

**For Android:**
1. Click "Add app" → Android
2. Enter package name: `com.megavent.app`
3. Enter app nickname: `MegaVent Android`
4. Download `google-services.json`
5. Place file in `android/app/` directory

**For iOS:**
1. Click "Add app" → iOS
2. Enter bundle ID: `com.megavent.app`
3. Enter app nickname: `MegaVent iOS`
4. Download `GoogleService-Info.plist`
5. Place file in `ios/Runner/` directory

**For Web (Optional):**
1. Click "Add app" → Web
2. Enter app nickname: `MegaVent Web`
3. Copy configuration object for later use

### Step 4: Configure Firestore Security Rules

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own profile
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Events - anyone can read, only organizers can create/update
    match /events/{eventId} {
      allow read: if true;
      allow create, update: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == "organizer";
      allow delete: if request.auth != null && 
        resource.data.organizerId == request.auth.uid;
    }
    
    // Registrations - users can read their own, organizers can read their events
    match /registrations/{registrationId} {
      allow read: if request.auth != null && 
        (resource.data.userId == request.auth.uid || 
         resource.data.organizerId == request.auth.uid);
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.userId;
      allow update: if request.auth != null && 
        request.auth.uid == resource.data.organizerId;
    }
  }
}
```

### Step 5: Configure Storage Rules

```javascript
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {
    // Event images
    match /events/{eventId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // User profile images
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Flutter Setup

### Step 1: Clone Repository

```bash
# Clone the repository
git clone https://github.com/yourusername/megavent.git
cd megavent

# Or create new Flutter project
flutter create --org com.megavent megavent
cd megavent
```

### Step 2: Configure Dependencies

Create/update `pubspec.yaml`:

```yaml
name: megavent
description: Event management platform with QR-based registration
version: 1.0.0+1

environment:
  sdk: '>=3.1.0 <4.0.0'
  flutter: ">=3.13.0"

dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.12.0
  cloud_firestore: ^4.8.0
  firebase_storage: ^11.6.0
  firebase_messaging: ^14.7.0
  
  # QR Code functionality
  qr_flutter: ^4.2.0
  mobile_scanner: ^2.1.0
  
  # State management
  flutter_riverpod: ^2.4.5
  
  # UI and utilities
  intl: ^0.18.1
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
  flutter_local_notifications: ^15.3.0
  permission_handler: ^11.0.1
  
  # Utilities
  crypto: ^3.0.3
  uuid: ^4.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  mockito: ^5.4.2
  build_runner: ^2.4.7

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/icons/
  
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
```

### Step 3: Install Dependencies

```bash
flutter pub get
```

## Project Configuration

### Step 1: Configure Android

**android/app/build.gradle:**
```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.megavent.app"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.debug
        }
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

**android/build.gradle:**
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

**android/app/build.gradle (bottom):**
```gradle
apply plugin: 'com.google.gms.google-services'
```

### Step 2: Configure iOS

**ios/Runner/Info.plist:**
```xml
<dict>
    <!-- Camera permission for QR scanning -->
    <key>NSCameraUsageDescription</key>
    <string>This app needs camera access to scan QR codes</string>
    
    <!-- Photo library permission -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>This app needs photo library access to select event images</string>
    
    <!-- Minimum iOS version -->
    <key>MinimumOSVersion</key>
    <string>12.0</string>
</dict>
```

### Step 3: Create Project Structure

```bash
mkdir -p lib/src/{app,config,constants,features,models,providers,services,utils,widgets}
mkdir -p lib/src/features/{auth,events,scanner,profile,dashboard}
mkdir -p lib/src/features/auth/{presentation,application}
mkdir -p lib/src/features/events/{presentation,application}
mkdir -p lib/src/features/scanner/{presentation,application}
mkdir -p assets/{images,icons,fonts}
mkdir -p test/{unit,widget,integration}
```

### Step 4: Configure Firebase in Flutter

**lib/firebase_options.dart:**
```dart
// Auto-generated after running: flutterfire configure

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
    }
  }

  // Add your Firebase configuration here
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'your-android-api-key',
    appId: 'your-android-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-storage-bucket',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'your-ios-api-key',
    appId: 'your-ios-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    storageBucket: 'your-storage-bucket',
    iosClientId: 'your-ios-client-id',
    iosBundleId: 'com.megavent.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'your-web-api-key',
    appId: 'your-web-app-id',
    messagingSenderId: 'your-sender-id',
    projectId: 'your-project-id',
    authDomain: 'your-project-id.firebaseapp.com',
    storageBucket: 'your-storage-bucket',
  );
}
```

**lib/main.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';
import 'src/app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(
    const ProviderScope(
      child: MegaVentApp(),
    ),
  );
}
```

## Development Environment

### Step 1: Configure FlutterFire CLI

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for Flutter
flutterfire configure
```

Follow prompts to:
- Select Firebase project
- Choose platforms (Android, iOS, Web)
- Generate firebase_options.dart

### Step 2: Set Up Development Database

Create initial Firestore collections:

1. **users** collection:
```json
{
  "uid": "user123",
  "email": "user@example.com",
  "displayName": "John Doe",
  "role": "attendee",
  "createdAt": "2025-01-01T00:00:00Z"
}
```

2. **events** collection:
```json
{
  "id": "event123",
  "organizerId": "organizer456",
  "title": "Sample Event",
  "description": "Event description",
  "dateTime": "2025-06-20T18:00:00Z",
  "location": "Event Location",
  "capacity": 100,
  "createdAt": "2025-01-01T00:00:00Z"
}
```

### Step 3: Configure Development Tools

**analysis_options.yaml:**
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    avoid_print: true
    prefer_single_quotes: true
    sort_child_properties_last: true
```

## Testing Setup

### Step 1: Configure Test Environment

**test/helpers/test_helpers.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

Widget createTestApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('Test Helper Functions', () {
    testWidgets('createTestApp wraps widget correctly', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const Text('Test Widget'),
        ),
      );
      
      expect(find.text('Test Widget'), findsOneWidget);
    });
  });
}
```

### Step 2: Unit Test Examples

**test/unit/services/qr_service_test.dart:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:megavent/src/services/qr_service.dart';

void main() {
  group('QrService', () {
    test('generateRegistrationHash creates unique hash', () {
      // Arrange
      const eventId = 'test-event';
      const userId = 'test-user';
      final timestamp = DateTime.now();

      // Act
      final hash = QrService.generateRegistrationHash(
        eventId: eventId,
        userId: userId,
        timestamp: timestamp,
      );

      // Assert
      expect(hash, isNotEmpty);
      expect(hash.length, equals(64)); // SHA-256 hash length
    });

    test('generateRegistrationHash creates different hashes for different inputs', () {
      // Arrange
      const eventId = 'test-event';
      final timestamp = DateTime.now();

      // Act
      final hash1 = QrService.generateRegistrationHash(
        eventId: eventId,
        userId: 'user1',
        timestamp: timestamp,
      );
      
      final hash2 = QrService.generateRegistrationHash(
        eventId: eventId,
        userId: 'user2',
        timestamp: timestamp,
      );

      // Assert
      expect(hash1, isNot(equals(hash2)));
    });
  });
}
```

### Step 3: Widget Test Examples

**test/widget/auth/login_screen_test.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:megavent/src/features/auth/presentation/screens/login_screen.dart';
import '../../helpers/test_helpers.dart';

void main() {
  group('LoginScreen', () {
    testWidgets('displays email and password fields', (tester) async {
      await tester.pumpWidget(
        createTestApp(const LoginScreen()),
      );

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('displays login button', (tester) async {
      await tester.pumpWidget(
        createTestApp(const LoginScreen()),
      );

      expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    });

    testWidgets('shows validation error for empty email', (tester) async {
      await tester.pumpWidget(
        createTestApp(const LoginScreen()),
      );

      // Find and tap login button without entering email
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });
  });
}
```

### Step 4: Integration Test Setup

**integration_test/app_test.dart:**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:megavent/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MegaVent App Integration Tests', () {
    testWidgets('complete user registration flow', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to registration
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Fill registration form
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'testpass123');
      await tester.enterText(find.byKey(const Key('name_field')), 'Test User');

      // Select role
      await tester.tap(find.text('Attendee'));
      await tester.pumpAndSettle();

      // Submit registration
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify navigation to dashboard
      expect(find.text('Welcome, Test User'), findsOneWidget);
    });
  });
}
```

### Step 5: Run Tests

```bash
# Run unit tests
flutter test test/unit/

# Run widget tests
flutter test test/widget/

# Run all tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

## Deployment

### Step 1: Prepare for Release

**Update Version:**
```yaml
# pubspec.yaml
version: 1.0.0+1  # version+build_number
```

**Configure Release Signing (Android):**

Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=your_key_alias
storeFile=path/to/your/keystore.jks
```

Update `android/app/build.gradle`:
```gradle
android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Step 2: Build Release Apps

**Android:**
```bash
# Build APK
flutter build apk --release

# Build App Bundle (recommended for Play Store)
flutter build appbundle --release
```

**iOS:**
```bash
# Build iOS app
flutter build ios --release

# Build IPA for distribution
flutter build ipa --release
```

**Web:**
```bash
# Build web app
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### Step 3: Deploy to App Stores

**Google Play Store:**
1. Create developer account
2. Upload app bundle
3. Complete store listing
4. Set up release management
5. Submit for review

**Apple App Store:**
1. Create Apple Developer account
2. Use Xcode or Application Loader
3. Upload IPA file
4. Complete App Store Connect listing
5. Submit for review

**Firebase Hosting (Web):**
```bash
# Initialize hosting
firebase init hosting

# Deploy
firebase deploy --only hosting
```

### Step 4: Set Up CI/CD (Optional)

**GitHub Actions workflow (.github/workflows/flutter.yml):**
```yaml
name: Flutter CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.13.0'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Run tests
      run: flutter test
      
    - name: Analyze code
      run: flutter analyze
      
    - name: Check formatting
      run: dart format --set-exit-if-changed .

  build:
    needs: test
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.13.0'
        
    - name: Install dependencies
      run: flutter pub get
      
    - name: Build APK
      run: flutter build apk --release
      
    - name: Upload APK
      uses: actions/upload-artifact@v3
      with:
        name: release-apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

## Troubleshooting

### Common Issues

**1. Firebase Configuration Issues:**
```bash
# Error: Firebase not initialized
Solution: Ensure Firebase.initializeApp() is called before runApp()

# Error: google-services.json not found
Solution: Verify file placement in android/app/ directory

# Error: GoogleService-Info.plist not found
Solution: Add file to ios/Runner/ through Xcode
```

**2. Build Issues:**
```bash
# Error: Gradle build failed
Solution: Clean and rebuild
flutter clean
flutter pub get
flutter build apk

# Error: Pod install failed (iOS)
Solution: Update CocoaPods
cd ios
pod repo update
pod install
```

**3. Permission Issues:**
```bash
# Error: Camera permission denied
Solution: Add camera permissions to platform files

# Android: android/app/src/main/AndroidManifest.xml
<uses-permission android:name="android.permission.CAMERA" />

# iOS: ios/Runner/Info.plist
<key>NSCameraUsageDescription</key>
<string>Camera access needed for QR scanning</string>
```

**4. QR Scanning Issues:**
```bash
# Error: Scanner not detecting codes
Solutions:
- Ensure adequate lighting
- Check camera permissions
- Verify QR code format
- Test on physical device (not emulator)
```

**5. State Management Issues:**
```bash
# Error: Provider not found
Solution: Wrap app with ProviderScope

# Error: State not updating
Solution: Use ref.watch() in widgets, ref.read() in event handlers
```

### Debug Commands

```bash
# Check Flutter installation
flutter doctor -v

# Check dependencies
flutter pub deps

# Analyze code
flutter analyze

# Check for outdated packages
flutter pub outdated

# Clean build cache
flutter clean

# Verbose build output
flutter build apk --verbose
```

### Performance Optimization

**1. Image Optimization:**
```dart
// Use cached network images
CachedNetworkImage(
  imageUrl: 'https://example.com/image.jpg',
  placeholder: (context, url) => Container(
  color: AppConstants.primaryColor.withOpacity(0.1),
  child: const Center(
    child: SpinKitThreeBounce(
      color: AppConstants.primaryColor,
      size: 20.0,
    ),
  ),
),,
  errorWidget: (context, url, error) => Icon(Icons.error),
)

// Optimize image size
Image.network(
  'https://example.com/image.jpg',
  width: 100,
  height: 100,
  fit: BoxFit.cover,
)
```

**2. List Performance:**
```dart
// Use ListView.builder for large lists
ListView.builder(
  itemCount: events.length,
  itemBuilder: (context, index) {
    return EventCard(event: events[index]);
  },
)
```

**3. Memory Management:**
```dart
// Dispose controllers and streams
@override
void dispose() {
  _controller.dispose();
  _subscription.cancel();
  super.dispose();
}
```

### Support Resources

- **Flutter Documentation**: https://flutter.dev/docs
- **Firebase Documentation**: https://firebase.google.com/docs
- **GitHub Issues**: Create issues for bugs or feature requests
- **Stack Overflow**: Tag questions with 'flutter' and 'firebase'
- **Flutter Community**: https://flutter.dev/community

### Contact Support

For technical support:
- **Email**: support@megavent.com
- **GitHub**: Create an issue with detailed description
- **Documentation**: Check this file and README.md first

---

**Next Steps:**
1. Follow the setup instructions step by step
2. Test the basic app functionality
3. Implement core features according to the project structure
4. Set up proper testing and CI/CD
5. Deploy to your preferred platforms

Good luck with your MegaVent development! 🚀