# Contributing to MegaVent

Thank you for your interest in contributing to MegaVent! This document provides guidelines and information for contributors.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Process](#development-process)
- [Code Standards](#code-standards)
- [Testing Requirements](#testing-requirements)
- [Submitting Changes](#submitting-changes)
- [Reporting Issues](#reporting-issues)
- [Feature Requests](#feature-requests)

## Getting Started

### Prerequisites

Before contributing, ensure you have:
- Flutter 3.13+ installed
- Firebase CLI configured
- Git configured with your details
- Code editor with Flutter/Dart extensions

### Setting Up Development Environment

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/yourusername/megavent.git
   cd megavent
   ```
3. Add the upstream repository:
   ```bash
   git remote add upstream https://github.com/original-owner/megavent.git
   ```
4. Install dependencies:
   ```bash
   flutter pub get
   ```
5. Set up Firebase (see INSTRUCTIONS.md)

## Development Process

### Branching Strategy

We use a feature branch workflow:

1. Create a feature branch from `main`:
   ```bash
   git checkout -b feature/your-feature-name
   ```
2. Make your changes
3. Push to your fork
4. Create a Pull Request

### Branch Naming Convention

- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test improvements

Examples:
- `feature/qr-scanner-enhancement`
- `fix/authentication-bug`
- `docs/api-documentation`

## Code Standards

### Dart/Flutter Guidelines

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo).

### Code Formatting

- Use `dart format` before committing
- Follow consistent indentation (2 spaces)
- Keep line length under 80 characters where possible
- Use meaningful variable and function names

### Code Organization

```dart
// Good
class EventService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  EventService({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  }) : _firestore = firestore, _auth = auth;

  Future<List<Event>> fetchEvents() async {
    // Implementation
  }
}

// Avoid
class ES {
  var f;
  var a;
  // Poor naming and structure
}
```

### Widget Structure

- Keep widget trees shallow (< 3 levels deep)
- Extract complex widgets into separate classes
- Use const constructors where possible
- Prefer composition over inheritance

```dart
// Good
class EventCard extends StatelessWidget {
  const EventCard({
    Key? key,
    required this.event,
    this.onTap,
  }) : super(key: key);

  final Event event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(event.title),
        subtitle: Text(event.description),
        onTap: onTap,
      ),
    );
  }
}
```

### Documentation Standards

- Add dartdoc comments for public APIs
- Document complex business logic
- Include examples for utility functions
- Keep comments concise and relevant

```dart
/// Generates a secure QR code hash for event registration.
/// 
/// Combines [eventId], [userId], and [timestamp] to create a unique
/// SHA-256 hash that serves as the QR code data.
/// 
/// Example:
/// ```dart
/// final hash = QrService.generateRegistrationHash(
///   eventId: 'event123',
///   userId: 'user456',
///   timestamp: DateTime.now(),
/// );
/// ```
static String generateRegistrationHash({
  required String eventId,
  required String userId,
  required DateTime timestamp,
}) {
  // Implementation
}
```

## Testing Requirements

### Test Coverage

- Aim for >80% test coverage for new features
- Write tests before implementing features (TDD approach)
- Test both happy path and edge cases

### Test Types

1. **Unit Tests** - Test individual functions and classes
2. **Widget Tests** - Test UI components
3. **Integration Tests** - Test complete user flows

### Test Structure

```dart
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
  });
}
```

### Running Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/services/qr_service_test.dart
```

## Submitting Changes

### Commit Message Format

Use conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

**Types:**
- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation changes
- `style` - Code formatting changes
- `refactor` - Code refactoring
- `test` - Adding or updating tests
- `chore` - Maintenance tasks

**Examples:**
```bash
feat(scanner): add QR code validation
fix(auth): resolve login timeout issue
docs(readme): update installation instructions
test(events): add unit tests for event service
```

### Pull Request Process

1. **Before submitting:**
   - Run tests: `flutter test`
   - Check formatting: `dart format --set-exit-if-changed .`
   - Run analyzer: `flutter analyze`
   - Update documentation if needed

2. **Pull Request Template:**
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Documentation update
   - [ ] Refactoring

   ## Testing
   - [ ] Unit tests added/updated
   - [ ] Widget tests added/updated
   - [ ] Integration tests added/updated
   - [ ] Manual testing completed

   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Tests pass locally
   - [ ] Documentation updated
   - [ ] No breaking changes
   ```

3. **Review Process:**
   - At least one approving review required
   - All CI checks must pass
   - No merge conflicts
   - Up-to-date with main branch

## Reporting Issues

### Issue Template

When reporting bugs, include:

1. **Environment:**
   - Flutter version
   - Device/OS information
   - App version

2. **Description:**
   - Clear, concise description
   - Expected vs actual behavior
   - Steps to reproduce

3. **Additional Context:**
   - Screenshots/videos
   - Error logs
   - Related issues

### Bug Report Example

```markdown
**Environment:**
- Flutter: 3.13.5
- Device: iPhone 14 Pro (iOS 17.0)
- App Version: 1.2.0

**Description:**
QR scanner fails to detect codes in low light conditions.

**Steps to Reproduce:**
1. Open QR scanner
2. Point camera at QR code in dim lighting
3. Scanner doesn't detect the code

**Expected Behavior:**
Scanner should detect QR codes in various lighting conditions.

**Screenshots:**
[Attach relevant images]
```

## Feature Requests

### Request Template

1. **Problem Statement:**
   - What problem does this solve?
   - Who would benefit?

2. **Proposed Solution:**
   - Detailed description
   - User experience considerations
   - Technical approach (if known)

3. **Alternatives:**
   - Other solutions considered
   - Why this approach is preferred

4. **Additional Context:**
   - Mockups/wireframes
   - Similar features in other apps
   - Priority level

## Code Review Guidelines

### For Reviewers

- Focus on code quality, not personal style
- Provide constructive feedback
- Suggest improvements with examples
- Approve when standards are met

### For Contributors

- Respond to feedback promptly
- Ask questions if feedback isn't clear
- Make requested changes in timely manner
- Thank reviewers for their time

## Community Guidelines

- Be respectful and inclusive
- Help others learn and grow
- Focus on technical merit
- Celebrate contributions of all sizes
- Follow the project's Code of Conduct

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

## Questions?

If you have questions about contributing:
- Create a discussion on GitHub
- Reach out to maintainers
- Check existing issues and documentation

Thank you for contributing to MegaVent! 🎉