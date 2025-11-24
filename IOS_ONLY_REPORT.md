# iOS Only Configuration

## Status: ✅ iOS Focused

### 1. Android Removal
- ✅ Deleted `android/` directory.
- ✅ Removed Android configuration from `lib/firebase_options.dart`.

### 2. iOS Enhancements
- ✅ Added `LSApplicationQueriesSchemes` to `Info.plist` to support `https`, `http`, `tel`, `mailto`, `sms` deep links.
- ✅ Verified `GIDClientID` for Google Sign In.
- ✅ Verified Permissions for Camera, Photo Library, Microphone, and Tracking.

### 3. Next Steps
- Run `flutter clean` and `flutter pub get` to ensure no cached Android artifacts remain.
- Build using `flutter build ios` or run on iOS Simulator.

