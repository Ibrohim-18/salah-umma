# Quick Start Guide - Salah Umma

## Prerequisites

Before running the app, ensure you have:

- **Flutter SDK** 3.7.0 or higher
- **Dart SDK** (comes with Flutter)
- **Android Studio** or **VS Code** with Flutter extensions
- **Physical device** or emulator with:
  - GPS capability
  - Magnetometer (for Qibla compass)
  - Internet connection (for initial prayer time fetch)

## Installation Steps

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Generate Hive Adapters

The app uses Hive for local storage. Generate the required type adapters:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will create `.g.dart` files for all models.

### 3. Run the App

**For Android:**
```bash
flutter run
```

**For iOS:**
```bash
flutter run -d ios
```

**For Web (limited functionality):**
```bash
flutter run -d chrome
```

**For Windows:**
```bash
flutter run -d windows
```

## First Launch Setup

### Step 1: Grant Permissions

When you first launch the app, it will request:
- **Location Permission**: Required for prayer times and Qibla
- Allow "While using the app" or "Always"

### Step 2: Configure Profile

1. Tap the **Settings** icon (bottom right)
2. Enter your **Name** (optional)
3. Set your **Date of Birth** (required for Qada calculation)
4. Select your **Gender** (required for Qada calculation)
5. Tap **"Save Profile"**

### Step 3: Get Location

1. In Settings, tap **"Update Location"**
2. Wait for GPS to acquire your coordinates
3. Your city and coordinates will be displayed

### Step 4: Return to Home

1. Tap the **Home** icon (bottom left)
2. Prayer times will load automatically
3. You'll see the countdown to the next prayer

## Features Overview

### 🏠 Home Screen

**What you'll see:**
- Current time
- Your location (city, country)
- Next prayer countdown (hours, minutes, seconds)
- Adhan and Iqama times
- Full list of today's prayer times
- Qada progress tracker

**Actions:**
- Tap **"Mark Prayer Completed"** to log a Qada prayer

### 🧭 Qibla Screen

**How to use:**
1. Hold your phone flat (parallel to ground)
2. Rotate your body until the arrow turns **green**
3. Feel the haptic vibration when aligned
4. The arrow points towards Kaaba

**Display shows:**
- Distance to Kaaba (in km)
- Compass direction (N, NE, E, etc.)
- Alignment indicator

### 🌙 Ramadan Screen

**Features:**
- Navigate through all Ramadans since your maturity
- Use **← →** arrows to switch years
- Tap calendar days to mark as fasted (green = fasted)
- Progress bar shows completion percentage

**How it works:**
- Automatically calculates all Ramadan dates since you reached maturity
- Stores your fasting history locally
- Can update past Ramadans retroactively

### ⚙️ Settings Screen

**Profile Section:**
- Name
- Date of Birth (affects Qada calculation)
- Gender (affects maturity age: 9 for girls, 12 for boys)

**Location Section:**
- Current coordinates
- City and country
- Update location button

**User ID:**
- Unique identifier (auto-generated)
- Used for local data namespace

## Troubleshooting

### Prayer times not loading

**Solution:**
1. Check internet connection
2. Verify location permissions are granted
3. Go to Settings → Update Location
4. Restart the app

### Qibla compass not working

**Solution:**
1. Ensure device has magnetometer sensor
2. Move away from magnetic interference (metal objects, electronics)
3. Calibrate compass by moving phone in figure-8 pattern
4. Restart the app

### Qada count seems wrong

**Solution:**
1. Verify Date of Birth is correct
2. Verify Gender is correct
3. Qada = (Days since maturity) × 5 prayers/day
4. Maturity age: 9 years (female), 12 years (male)

### App crashes on startup

**Solution:**
1. Clear app data
2. Uninstall and reinstall
3. Check Flutter version: `flutter --version`
4. Run: `flutter clean && flutter pub get`

## Development Commands

### Run in debug mode
```bash
flutter run
```

### Run in release mode (faster)
```bash
flutter run --release
```

### Build APK (Android)
```bash
flutter build apk --release
```

### Build App Bundle (Android)
```bash
flutter build appbundle --release
```

### Build iOS
```bash
flutter build ios --release
```

### Run tests
```bash
flutter test
```

### Check for issues
```bash
flutter analyze
```

## Data Storage

All data is stored locally on your device using Hive:

**Location:**
- Android: `/data/data/com.salah.salah_umma/`
- iOS: `Library/Application Support/`
- Windows: `%APPDATA%/com.salah.salah_umma/`

**Boxes:**
- `user_box`: Profile and settings
- `qada_box`: Prayer completion tracking
- `ramadan_box`: Fasting history
- `prayer_times_cache`: Cached prayer times (30 days)

## Privacy

- **No cloud storage**: All data stays on your device
- **No analytics**: No tracking or telemetry
- **No account required**: Works completely offline after initial setup
- **No ads**: Clean, distraction-free experience

## Support

For issues or questions:
1. Check this guide
2. Review `ARCHITECTURE.md` for technical details
3. Check `README.md` for feature documentation

## Next Steps

After setup:
1. ✅ Set up profile and location
2. ✅ Check prayer times
3. ✅ Find Qibla direction
4. ✅ Start tracking Qada prayers
5. ✅ Mark Ramadan fasting days

Enjoy using Salah Umma! 🌙

