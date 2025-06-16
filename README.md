# MegaVent - Event Management Platform

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter Version](https://img.shields.io/badge/Flutter-3.13+-blue.svg)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Cloud%20Services-orange.svg)](https://firebase.google.com)

## Project Overview

MegaVent is a comprehensive event management platform that simplifies event organization and attendance verification through QR code technology. The application serves event organizers and attendees with a seamless experience from registration to check-in.

**Key Benefits:**
- Streamlined event creation and management
- Secure QR-based attendance verification
- Real-time attendance tracking
- Cross-platform compatibility (iOS & Android)

## Key Features

- 🔐 Role-based authentication (Organizer/Attendee)
- 🎫 Unique QR code generation per registration
- 📱 QR scanner for instant check-in
- 📊 Real-time attendance analytics
- 📝 Event creation and management
- 🔔 Notification system
- 🌐 Cloud-synced data

## Technology Stack

| Component       | Technology                          |
|-----------------|-------------------------------------|
| Frontend        | Flutter 3.13+                       |
| Backend         | Firebase (Auth, Firestore, Storage) |
| QR Generation   | qr_flutter 4.2.0                    |
| QR Scanning     | mobile_scanner 2.1.0                |
| State Management| Riverpod 2.4.5                      |
| Notifications   | Firebase Cloud Messaging            |

## Project Structure

```
megavent/
├── android/                   # Android platform code
├── ios/                       # iOS platform code
├── lib/                       # Core application
│   ├── src/                   # Application source
│   │   ├── app/               # App initialization
│   │   ├── config/            # App configuration
│   │   ├── constants/         # App constants
│   │   ├── features/          # Feature modules
│   │   │   ├── auth/          # Authentication
│   │   │   ├── events/        # Event management
│   │   │   ├── scanner/       # QR scanning
│   │   │   ├── profile/       # User profile
│   │   │   └── dashboard/     # Analytics
│   │   ├── models/            # Data models
│   │   ├── providers/         # State providers
│   │   ├── services/          # Business logic
│   │   ├── utils/             # Utilities
│   │   └── widgets/           # Shared widgets
│   └── main.dart              # Entry point
├── firebase/                  # Firebase configs
├── test/                      # Test suites
├── pubspec.yaml               # Dependency management
├── CONTRIBUTING.md            # Contribution guidelines
├── LICENSE.md                 # MIT License
├── INSTRUCTIONS.md            # Setup instructions
└── README.md                  # Project documentation
```

## Getting Started

### Prerequisites
- Flutter 3.13+
- Firebase CLI
- Dart 3.1+
- Android Studio/Xcode

### Installation
```bash
git clone https://github.com/yourusername/megavent.git
cd megavent
flutter pub get
```

### Quick Setup
For detailed setup instructions, see [INSTRUCTIONS.md](INSTRUCTIONS.md)

1. Create Firebase project
2. Enable Authentication (Email/Password)
3. Set up Firestore Database
4. Configure Cloud Storage
5. Download config files
6. Run the app: `flutter run`

## User Roles and Permissions

| Role       | Permissions                                                                 |
|------------|-----------------------------------------------------------------------------|
| Organizer  | Create events, Manage events, View analytics, Scan QR codes, Invite attendees |
| Attendee   | Browse events, Register for events, View QR tickets, Update profile         |

## Core Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^2.24.0
  firebase_auth: ^4.12.0
  cloud_firestore: ^4.8.0
  firebase_storage: ^11.6.0
  qr_flutter: ^4.2.0
  mobile_scanner: ^2.1.0
  flutter_riverpod: ^2.4.5
  intl: ^0.18.1
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
  flutter_local_notifications: ^15.3.0
```

## User Flows

### Attendee Flow
1. Install app → Register as attendee → Verify email
2. Browse available events → View event details
3. Register for event → Generate unique QR ticket
4. Save QR to device or show at event
5. Get scanned at venue → Receive confirmation

### Organizer Flow
1. Install app → Register as organizer → Admin verification
2. Create new event → Set details (name, date, location, capacity)
3. Manage event → View registrations → Send notifications
4. At event → Open QR scanner → Scan attendee tickets
5. View real-time check-ins → Export attendance report

## Security Features

- SHA-256 hash generation for QR codes
- Timestamp-based QR validation
- Rate limiting on scans
- Device binding for organizer scanner
- No PII stored in QR codes
- QR codes expire after event

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines on how to contribute to this project.

## License

Distributed under the MIT License. See [LICENSE.md](LICENSE.md) for details.

## Contact

**Project Lead**: Abel Maeba
**Email**: abel@megavent.com  
**University**: Kabarak University

## Support

For technical support or questions:
- Create an issue on GitHub
- Check the [INSTRUCTIONS.md](INSTRUCTIONS.md) for setup help
- Review the documentation in the `/docs` folder