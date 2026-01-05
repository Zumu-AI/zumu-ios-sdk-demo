# Driver App Translator Demo

A test iOS application for integrating and testing the [Zumu AI iOS SDK](https://github.com/Zumu-AI/zumu-ios-sdk) for real-time driver-passenger translation.

## Overview

This app simulates a ride-sharing driver app (similar to Uber Driver) with one primary screen that displays passenger pickup information and integrates the Zumu AI translation SDK for real-time multilingual communication.

## Features

- **Driver Profile Display**: Shows driver name, language, vehicle info, and rating
- **Trip Selection**: Multiple test trips with different passenger scenarios
- **Real-time Translation**: Voice-to-voice translation using Zumu AI SDK
- **Dynamic Variables**: Tests all SDK configuration options:
  - Driver name and language
  - Passenger name and language (with auto-detect)
  - Trip ID, pickup location, dropoff location
- **Session Management**: Start/end translation sessions
- **Microphone Control**: Mute/unmute functionality
- **Text Messaging**: Optional text message sending alongside voice
- **Live Conversation View**: Real-time message display with translation

## Requirements

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- Zumu API Key

## Setup Instructions

### 1. Clone or Download the Project

```bash
cd driver-app-translator-demo
```

### 2. Get Your Zumu API Key

1. Log in to the [Zumu Dashboard](https://your-domain.com/dashboard)
2. Navigate to **API Keys**
3. Click **Create API Key**
4. Copy your key (format: `zumu_xxxxxxxxxxxx`)

### 3. Configure Environment Variables

Create a `.env` file (copy from `.env.example`):

```bash
cp .env.example .env
```

Edit `.env` and add your API key:

```
ZUMU_API_KEY=zumu_your_actual_api_key_here
```

**Important**: Never commit the `.env` file with real credentials.

### 4. Open in Xcode

Since this is a Swift Package, you have two options:

#### Option A: Open as Swift Package (for development)

```bash
open Package.swift
```

#### Option B: Create an Xcode Project (recommended for full iOS app)

1. Open Xcode
2. Create a new **iOS App** project
3. Name it "DriverAppTranslatorDemo"
4. Choose SwiftUI for Interface
5. Add the Swift Package dependency:
   - File → Add Package Dependencies
   - Enter: `https://github.com/Zumu-AI/zumu-ios-sdk`
   - Select version `1.0.0` or later
6. Copy the `Sources/DriverApp` folder contents to your project's source directory
7. Copy the `Info.plist` to your project

### 5. Configure Permissions

The `Info.plist` already includes the required microphone permissions:
- `NSMicrophoneUsageDescription`: For voice translation
- `NSSpeechRecognitionUsageDescription`: For speech recognition

### 6. Set API Key in Code

The app reads the API key from environment variables. For testing, you can:

1. **Via Xcode Scheme** (Recommended):
   - Product → Scheme → Edit Scheme
   - Run → Arguments → Environment Variables
   - Add: `ZUMU_API_KEY` = `zumu_your_key_here`

2. **Hardcode for Testing** (Not recommended for production):
   Edit `Sources/DriverApp/ViewModels/TranslatorViewModel.swift:13`:
   ```swift
   let apiKey = "zumu_your_actual_key_here"
   ```

### 7. Build and Run

1. Select a simulator or physical device
2. Press `Cmd + R` to build and run
3. Grant microphone permissions when prompted

## How to Use the App

### Test Scenarios

The app includes 3 pre-configured test trips:

1. **María García** (Spanish speaker)
   - Tests explicit language configuration
   - Spanish ↔ English translation

2. **Jean Dupont** (French speaker)
   - Tests French ↔ English translation
   - Different language pair

3. **李明** (Language auto-detect)
   - Tests auto-detection feature
   - `passengerLanguage` set to `nil`

### Testing Flow

1. **Select a Test Trip**:
   - Tap "Select Test Trip"
   - Choose from the 3 test scenarios
   - Trip details will display (passenger, locations, trip ID)

2. **Start Translation Session**:
   - Tap "Start Translation" button
   - App will call `translator.startSession(config: SessionConfig)`
   - Status banner shows connection state

3. **During Active Session**:
   - Speak into microphone for real-time translation
   - View translated messages in conversation view
   - Optionally send text messages
   - Use mute button to pause translation
   - Messages show timestamp and role (driver/passenger)

4. **End Session**:
   - Tap "End Trip" button
   - Session terminates gracefully
   - Returns to trip selection screen

## Project Structure

```
driver-app-translator-demo/
├── Package.swift                 # Swift Package configuration
├── Info.plist                    # iOS app permissions and config
├── Sources/DriverApp/
│   ├── DriverAppApp.swift       # App entry point
│   ├── ContentView.swift        # Main coordinator view
│   ├── Models/
│   │   ├── Trip.swift           # Trip data model with test samples
│   │   └── Driver.swift         # Driver profile model
│   ├── ViewModels/
│   │   └── TranslatorViewModel.swift  # SDK integration & state management
│   └── Views/
│       ├── TripSelectionView.swift    # Trip selection & driver info
│       ├── TripPickerSheet.swift      # Trip picker modal
│       └── ActiveTripView.swift       # Active translation session UI
└── README.md
```

## Testing the SDK

### What to Test

1. **Session Initialization**
   - ✅ Verify API key authentication works
   - ✅ Check session starts successfully
   - ✅ Confirm session ID is generated

2. **Dynamic Variables**
   - ✅ Driver name & language passed correctly
   - ✅ Passenger name & language configured
   - ✅ Auto-detect works when language is nil
   - ✅ Trip ID, pickup, dropoff locations sent

3. **Real-time Translation**
   - ✅ Voice input captured
   - ✅ Translation appears in messages
   - ✅ Bidirectional communication works
   - ✅ Audio output plays correctly

4. **Microphone Control**
   - ✅ Mute/unmute functionality
   - ✅ Mute state persists
   - ✅ Visual indicator updates

5. **Session Management**
   - ✅ End session terminates cleanly
   - ✅ Multiple sessions work sequentially
   - ✅ State updates properly

6. **Error Handling**
   - ✅ Invalid API key detection
   - ✅ Network error handling
   - ✅ Connection loss recovery
   - ✅ User-friendly error messages

### Logging & Debugging

The app includes logging in `TranslatorViewModel.swift`:

```swift
print("✅ Session started successfully: \(session.id)")
print("❌ Error starting session: \(error)")
```

Check Xcode console for:
- Session initialization logs
- Error messages
- SDK state changes

### Known Issues & Testing Notes

Document any issues found during testing in `TESTING_NOTES.md`:

```markdown
## Issue: [Brief description]
- **Severity**: High/Medium/Low
- **Steps to Reproduce**: ...
- **Expected Behavior**: ...
- **Actual Behavior**: ...
- **SDK Version**: ...
- **iOS Version**: ...
```

## SDK Integration Details

### Initialization

```swift
let translator = ZumuTranslator(apiKey: "zumu_your_key")
```

### Session Configuration

```swift
let config = SessionConfig(
    driverName: "John Doe",
    driverLanguage: "English",
    passengerName: "María García",
    passengerLanguage: "Spanish",  // or nil for auto-detect
    tripId: "TRIP-12345",
    pickupLocation: "123 Main St",
    dropoffLocation: "456 Oak Ave"
)

let session = try await translator.startSession(config: config)
```

### Observable Properties

```swift
@Published var state: SessionState       // Connection state
@Published var messages: [TranslationMessage]  // Conversation
@Published var isMuted: Bool            // Microphone state
@Published var session: TranslationSession?    // Active session
```

### State Management

The app uses Combine to react to SDK state changes:

```swift
translator.$state
    .sink { state in
        // Update UI based on state
    }
    .store(in: &cancellables)
```

## Troubleshooting

### "Invalid API key" Error
- Verify API key is correct and active
- Check environment variable is set properly
- Ensure key format is `zumu_xxxxxxxxxxxx`

### "Failed to create session" Error
- Check network connection
- Verify all required `SessionConfig` fields
- Check Zumu dashboard for quota limits

### No Audio / Translation Not Working
- Grant microphone permissions in Settings
- Check device is not muted
- Verify AirPods/Bluetooth devices connected properly
- Check SDK logs in Xcode console

### Build Errors
- Ensure Xcode 14.0+
- Clean build folder: `Cmd + Shift + K`
- Reset package dependencies: File → Packages → Reset Package Caches

## Next Steps

### Enhancements to Consider

1. **Persistence**: Save trip history and translations
2. **Analytics**: Track session duration, message counts
3. **Offline Mode**: Queue messages when disconnected
4. **Custom UI**: Match your app's design system
5. **Push Notifications**: Alert driver of passenger messages
6. **Language Settings**: Let driver choose preferred language
7. **Testing Automation**: XCTest integration tests

### Production Checklist

- [ ] Remove hardcoded API keys
- [ ] Implement secure keychain storage
- [ ] Add proper error tracking (Sentry, Firebase)
- [ ] Add analytics events
- [ ] Test on physical devices
- [ ] Test with poor network conditions
- [ ] Add accessibility labels
- [ ] Localize UI strings
- [ ] Add App Store screenshots
- [ ] Review Apple App Store guidelines

## Support & Resources

- **Zumu SDK Docs**: https://docs.your-domain.com
- **Zumu Dashboard**: https://your-domain.com/dashboard
- **SDK GitHub**: https://github.com/Zumu-AI/zumu-ios-sdk
- **Email Support**: support@your-domain.com

## License

This demo app is provided as-is for testing purposes.
Zumu iOS SDK is licensed under MIT License.

## Contributing

This is a test/demo application. For SDK issues, please report them at:
https://github.com/Zumu-AI/zumu-ios-sdk/issues

---

**Happy Testing!** 🚗💬🌍
