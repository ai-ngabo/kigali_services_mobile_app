# Kigali Services Mobile App

This is a Flutter mobile application for browsing, creating, and managing service listings in Kigali with real-time database integration and directed location features.

## Features

### Authentication
- Email/password registration and login
- Google Sign-In integration
- Email verification process
- Secure password reset functionality
- Persistent authentication state management

### Service Directory
- Browse all available services and businesses
- Filter by category (Restaurant, Hotel, Transport, Education, Healthcare, etc.)
- Search functionality
- Real-time listing updates

### Location Features
- Interactive Google Maps integration
- Geolocation services
- Address-based search
- GPS coordinates for each listing
- Geocoding for reverse address lookup

### Rating & Reviews
- Submit and view reviews for listings
- Star rating system (5-point scale)
- User review history
- Real-time rating calculations

### User Profiles
- Create and manage user profiles
- Track user listings
- View user ratings and reviews
- Edit profile information

### My Listings
- Create new service listings
- Edit existing listings
- Delete listings
- View analytics for your listings

### Settings
- App preferences
- Notification settings
- Account management
- Logout functionality

## Project Architecture

The application follows this architecture:

```
lib/
├── models/              # Data models (User, Listing, Review)
├── services/            # Business logic (Firebase, Auth, Location)
├── providers/           # State management (Provider pattern)
├── screens/             # UI screens (Auth, Directory, Maps, etc.)
├── widgets/             # Reusable UI components
├── utils/              # Constants, themes, and utilities
├── main.dart           # App entry point
└── firebase_options.dart # Firebase configuration (see Setup)
```

### Architecture Benefits
- **Testability**: Services and providers are easily testable
- **Maintainability**: Clear separation of concerns
- **Scalability**: Easy to add new features
- **Reusability**: Shared components and services

## State Management: Provider Pattern

Kigali Services and Directory app uses **Provider** package for efficient state management:

### Key Providers

#### 1. AppAuthProvider
```dart
// Manages:
- User authentication state
- Login/signup/logout
- Email verification
- Google Sign-In
- Password reset
```

#### 2. ListingsProvider
```dart
// Manages:
- All listings stream
- User's listings stream
- Create/update/delete listings
- Listing search and filtering
```

#### 3. FilterProvider
```dart
// Manages:
- Category filters
- Search query state
- Filter persistence
```

#### 4. SettingsProvider
```dart
// Manages:
- User preferences
- Dark mode toggle
- Notification settings
```

### Provider Usage
```dart
// Consuming a provider
Consumer<ListingsProvider>(
  builder: (context, provider, child) {
    return ListView(
      children: provider.listings.map(...).toList(),
    );
  },
)

// Accessing in code
final listings = Provider.of<ListingsProvider>(context, listen: false);
```

## Firebase Integration

### Services Used
1. **Firebase Authentication** - User registration and login
2. **Cloud Firestore** - Real-time database
3. **Firebase Storage** - Image/file storage
4. **Google Sign-In** - Social authentication

### Firestore Database Structure

#### Collections Overview

```
firestore/
├── users/
│   └── {userId}/
│       ├── uid: string
│       ├── displayName: string
│       ├── email: string
│       ├── photoUrl: string
│       ├── createdAt: timestamp
│       └── listingCount: int
│
├── listings/
│   └── {listingId}/
│       ├── id: string (UUID)
│       ├── name: string
│       ├── category: string
│       ├── address: string
│       ├── contact: string
│       ├── description: string
│       ├── latitude: double
│       ├── longitude: double
│       ├── createdBy: string (userId)
│       ├── createdByName: string
│       ├── timestamp: timestamp
│       ├── rating: double (avg)
│       ├── ratingCount: int
│       └── imageUrl: string
│
└── reviews/
    └── {reviewId}/
        ├── id: string (UUID)
        ├── listingId: string (FK)
        ├── userId: string (FK)
        ├── userName: string
        ├── rating: double (1-5)
        ├── comment: string
        └── timestamp: timestamp
```

#### Collection Indexes
- `listings` ordered by `timestamp` (descending)
- `listings` filtered by `createdBy` + `timestamp`
- `reviews` filtered by `listingId` + `timestamp`
- `users` accessible by document ID


## Setup Instructions

### Prerequisites
- Flutter 3.0+ 
- Dart 3.0+
- Android SDK or Xcode
- Firebase project

### 1. Firebase Configuration

Get your Firebase credentials from [Firebase Console](https://console.firebase.google.com):

```bash
# Use FlutterFire CLI for automatic setup
flutterfire configure

# Or manually:
# - Copy your firebase_options.dart.example to firebase_options.dart
# - Fill in your Firebase project credentials
# - Add google-services.json for Android
# - Add GoogleService-Info.plist for iOS
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Build
```bash
# Android
flutter build apk

# iOS
flutter build ios


## Security & Privacy

### Sensitive Files (Excluded from Git)
- `lib/firebase_options.dart` - Firebase credentials
- `android/app/google-services.json` - Android Firebase config
- `ios/Runner/GoogleService-Info.plist` - iOS Firebase config
- `.env` files - Environment variables

### Firestore Security Rules
The app includes security rules in `firestore.rules`:
- Users can only read/write their own profile
- Listings are publicly readable
- Only listing owner can edit/delete their listings
- Reviews can be created by authenticated users

## Dependencies

### Core
- flutter: UI framework
- provider: State management
- firebase_core: Firebase initialization

### Firebase
- firebase_auth: Authentication
- cloud_firestore: Database
- firebase_storage: File storage
- google_sign_in: Social login

### Maps & Location
- google_maps_flutter: Interactive maps
- geolocator: GPS location access
- geocoding: Address , coordinates conversion
- url_launcher: Open URLs

### UI Components
- flutter_rating_bar: 5-star rating widget
- cached_network_image: Optimized image loading
- image_picker: Camera/gallery access
- google_fonts: Custom fonts

### Utilities
- intl: Internationalization
- uuid: Generate unique IDs

## Development

### Running the App
```bash
flutter run

# With specific device
flutter run -d <device_id>

# With build mode
flutter run --release
```

### Code Structure Guidelines
1. **Models** - Data classes with serialization methods
2. **Services** - Firebase interactions and business logic
3. **Providers** - State management using ChangeNotifier
4. **Screens** - Full-page widgets
5. **Widgets** - Reusable components

### Adding a New Feature
1. Create a model in `lib/models/`
2. Add service methods in `lib/services/`
3. Create a provider in `lib/providers/`
4. Build UI screens in `lib/screens/`

## Troubleshooting

### Firebase Initialization Error
```
Error: DefaultFirebaseOptions have not been configured
```
→ Ensure `firebase_options.dart` exists and matches your Firebase project



## License

This project is open source and available under the MIT License.

## Support

For issues or any question, contact me via [email](a.ngabo@alustudent.com)

---

**Developer**: Alain Ishimwe Ngabo
**Last Updated**: March 2026  
**Firebase Project ID**: kigali-services-director-444fa  
**Current Version**: 1.0.0

-----------Mobile Development Course--------------
