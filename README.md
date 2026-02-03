# Salah Umma - Islamic Prayer Time App

A beautiful, local-first Flutter application for managing Islamic prayer times, Qada prayers, Ramadan fasting tracker, and Qibla finder.

## Features

### 🕌 Prayer Times
- **Real-time Prayer Tracking**: Displays next prayer with countdown timer
- **Aladhan API Integration**: Accurate prayer times based on your location
- **Iqama Offsets**: Customizable time offsets for each prayer
- **Heartbeat System**: Updates every second to show time until next prayer
- **Offline Support**: Cached prayer times for 30 days

### 📿 Qada Calculator
- **Automatic Calculation**: Based on age and gender (maturity at 9 for girls, 12 for boys)
- **Progress Tracking**: Visual progress bar showing completed vs remaining prayers
- **Daily Counter**: Track how many Qada prayers completed today
- **Persistent Storage**: All data saved locally with Hive

### 🌙 Ramadan Tracker
- **Historical Tracking**: View all Ramadans since maturity
- **Visual Calendar**: 30-day grid to mark fasted days
- **Progress Monitoring**: See completion percentage for each Ramadan
- **Time Travel**: Navigate through past Ramadans to update records

### 🧭 Qibla Finder
- **Compass Integration**: Real-time compass using device sensors
- **Distance Calculation**: Shows distance to Kaaba in kilometers
- **Haptic Feedback**: Vibrates when aligned with Qibla
- **Visual Indicators**: Green arrow when pointing towards Qibla

### 🎨 UI/UX
- **Cosmic Background**: Animated starfield with CustomPainter
- **Glassmorphism**: Beautiful glass-effect containers on desktop
- **Adaptive Design**:
  - Mobile (< 640px): Transparent, full-screen layout
  - Desktop (> 640px): Glass cards with blur effects
- **Dark Theme**: Optimized for night usage

## Architecture

### Local-First Design
- No cloud database dependency
- All data stored locally with Hive
- Automatic userId generation
- Instant state synchronization

### Tech Stack
- **Flutter**: Cross-platform framework
- **Provider**: State management
- **Hive**: Local NoSQL database
- **Geolocator**: GPS location services
- **Sensors Plus**: Magnetometer for compass
- **HTTP**: API communication

## Getting Started

### Prerequisites
- Flutter SDK (3.7.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Device with GPS and magnetometer

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd salah_umma
```

2. Install dependencies:
```bash
flutter pub get
```

3. Generate Hive adapters:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

### Permissions

The app requires the following permissions:

**Android** (`android/app/src/main/AndroidManifest.xml`):
- `ACCESS_FINE_LOCATION`: For GPS location
- `ACCESS_COARSE_LOCATION`: For approximate location
- `INTERNET`: For API calls

**iOS** (`ios/Runner/Info.plist`):
- `NSLocationWhenInUseUsageDescription`: Location access
- `NSLocationAlwaysUsageDescription`: Background location

## Usage

### First Time Setup
1. Open the app
2. Go to **Settings**
3. Enter your name, date of birth, and gender
4. Tap "Update Location" to get your GPS coordinates
5. Return to Home to see prayer times

### Prayer Times
- View all 5 daily prayers with Adhan and Iqama times
- See countdown to next prayer
- Times automatically update based on your location

### Qada Prayers
- Total missed prayers calculated automatically
- Tap "Mark Prayer Completed" after each Qada prayer
- Progress bar shows completion percentage

### Ramadan Tracker
- Navigate between different Ramadan years
- Tap on calendar days to mark as fasted
- Green = fasted, gray = not fasted

### Qibla Finder
- Hold phone flat
- Rotate until arrow turns green
- Feel haptic feedback when aligned

## API Reference

### Aladhan API
- **Endpoint**: `https://api.aladhan.com/v1`
- **Methods Used**:
  - `/timings/{timestamp}`: Get prayer times for specific date
  - `/calendar/{year}/{month}`: Get full month prayer times
- **Calculation Method**: 2 (Muslim World League)

## License

This project is licensed under the MIT License.
