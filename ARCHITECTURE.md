# Salah Umma - Architecture Documentation

## Overview

Salah Umma follows a **Local-First** architecture pattern, ensuring the app works offline and doesn't depend on cloud databases. All user data is stored locally using Hive, with automatic synchronization between state and storage.

## Core Principles

### 1. Local-First Design
- **No Cloud Dependency**: All data stored on device
- **Offline-First**: Works without internet (except initial prayer time fetch)
- **Auto-Generated User ID**: UUID created on first launch
- **Instant Sync**: State changes immediately persisted to Hive

### 2. State Management Flow
```
User Interaction → Provider Update → LocalStorage Sync → UI Refresh
```

### 3. Data Persistence
- **Hive**: NoSQL database for structured data
- **Type Adapters**: Auto-generated with build_runner
- **Boxes**: Separate boxes for User, Qada, Ramadan, Prayer Times Cache

## Module Architecture

### Prayer Engine (Heartbeat System)

**Purpose**: Real-time prayer time tracking with countdown

**Flow**:
1. **Initialization**:
   - UserProvider loads user location
   - PrayerService fetches times from Aladhan API
   - Times cached in Hive for 30 days

2. **Heartbeat Timer** (runs every 1 second):
   ```dart
   Timer.periodic(Duration(seconds: 1), (_) {
     - Get current time
     - Filter prayer times > now
     - First element = Next Prayer
     - Calculate time until Adhan
     - Calculate time until Iqama (Adhan + offset)
     - Update UI
   })
   ```

3. **Iqama Calculation**:
   ```
   Iqama Time = Adhan Time + User Offset (minutes)
   ```

**Key Files**:
- `services/prayer_service.dart`: API integration & caching
- `models/prayer_times_model.dart`: Data structure
- `providers/user_provider.dart`: State & heartbeat

---

### Qada Calculator

**Purpose**: Track missed prayers based on biological age

**Algorithm**:
```
Maturity Age = Gender == Female ? 9 : 12
Maturity Date = Birth Date + Maturity Age
Days Since Maturity = Today - Maturity Date
Total Missed Prayers = Days Since Maturity × 5
Remaining = Total - Completed
```

**State Updates**:
- On profile change (DOB/Gender): Recalculate total
- On "Mark Completed": Increment completed counter
- Daily reset: Clear today's counter at midnight

**Key Files**:
- `models/qada_model.dart`: Calculation logic
- `providers/user_provider.dart`: State management

---

### Ramadan Tracker

**Purpose**: Historical fasting tracker with time travel

**Date Calculation**:
```
Base: Ramadan 2024 = March 11
Shift: ~11 days earlier per year (Gregorian)
Formula: Base Date - (Year Diff × 11 days)
```

**Data Structure**:
```dart
Map<String, List<bool>> fastingHistory
// Key: "2024-03" → Value: [true, false, true, ...] (30 days)
```

**Features**:
- Navigate through all Ramadans since maturity
- Mark/unmark individual days
- Calculate completion percentage
- Persistent storage in Hive

**Key Files**:
- `services/ramadan_service.dart`: Date calculations
- `models/ramadan_model.dart`: Data & history
- `screens/ramadan_screen.dart`: UI with calendar grid

---

### Qibla Finder

**Purpose**: Compass-based Qibla direction with haptic feedback

**Calculation** (Spherical Geometry):
```dart
// Kaaba: 21.4225°N, 39.8262°E
azimuth = atan2(
  sin(Δlon) × cos(lat2),
  cos(lat1) × sin(lat2) - sin(lat1) × cos(lat2) × cos(Δlon)
)
```

**Sensor Integration**:
1. Magnetometer provides device heading (0-360°)
2. Calculate angle difference: `Qibla Direction - Device Heading`
3. Rotate arrow by this angle
4. If |difference| < 5°: Trigger haptic feedback

**Key Files**:
- `services/qibla_service.dart`: Math calculations
- `screens/qibla_screen.dart`: Compass UI & sensors

---

## UI/UX Architecture

### Adaptive Layout System

**Breakpoint**: 640px

**Mobile Mode** (< 640px):
- Transparent containers
- Full-screen content
- Content "floats" on cosmic background
- No glassmorphism

**Desktop Mode** (> 640px):
- Glass containers with blur
- Centered cards
- Box shadows
- Border glow effects

**Implementation**:
```dart
GlassContainer(
  child: content,
) 
// Automatically adapts based on MediaQuery.size.width
```

### Cosmic Background

**Technology**: CustomPainter (not video)

**Features**:
- 200 procedurally generated stars
- Fixed seed (42) for consistency
- Twinkling animation (60s loop)
- Gradient background (3 colors)
- Glow effect for bright stars

**Performance**:
- No video decoding
- GPU-accelerated canvas
- Minimal battery impact

---

## Data Flow Diagrams

### Prayer Times Flow
```
App Start
  ↓
UserProvider.initialize()
  ↓
Check Hive for User
  ↓
If location exists → PrayerService.getTodayPrayerTimes()
  ↓
Check Cache (Hive)
  ↓
If not cached → Aladhan API
  ↓
Parse JSON → PrayerTimesModel
  ↓
Save to Cache
  ↓
Start Heartbeat Timer
  ↓
Update Next Prayer every second
  ↓
UI reflects changes (Provider.notifyListeners)
```

### Qada Update Flow
```
User taps "Mark Completed"
  ↓
UserProvider.markQadaCompleted()
  ↓
QadaModel.markPrayerCompleted()
  ↓
Increment completedPrayers
  ↓
Update todayCount map
  ↓
Save to Hive
  ↓
notifyListeners()
  ↓
UI shows updated progress bar
```

---

## Storage Schema

### Hive Boxes

1. **user_box** (UserModel)
   - Key: `'current_user'`
   - Contains: Profile, location, settings

2. **qada_box** (QadaModel)
   - Key: `'qada'`
   - Contains: Total, completed, daily counts

3. **ramadan_box** (RamadanModel)
   - Key: `'ramadan'`
   - Contains: Fasting history map

4. **prayer_times_cache** (PrayerTimesModel)
   - Key: `'{lat}_{lon}_{date}'`
   - Auto-cleanup: Delete entries > 30 days

---

## API Integration

### Aladhan API

**Base URL**: `https://api.aladhan.com/v1`

**Endpoints Used**:

1. **Single Day**:
   ```
   GET /timings/{timestamp}
   ?latitude={lat}&longitude={lon}&method={method}
   ```

2. **Full Month**:
   ```
   GET /calendar/{year}/{month}
   ?latitude={lat}&longitude={lon}&method={method}
   ```

**Calculation Method**: 2 (Muslim World League)

**Response Parsing**:
```dart
timings['Fajr']   → "05:30 (EET)"
Clean: "05:30"
Parse: DateTime(year, month, day, 5, 30)
```

---

## Future Enhancements

- [ ] Quran reading module with Mushaf pages
- [ ] Audio notifications for Adhan
- [ ] Widget for home screen
- [ ] Multi-language support (easy_localization)
- [ ] Cloud backup (optional)
- [ ] Tasbih counter
- [ ] Hijri calendar integration

