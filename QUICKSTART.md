# Quick Start Guide - 5 Minutes to Running App

## Prerequisites
- Mac with Xcode 14.0+
- Zumu API Key

## Step-by-Step Setup

### 1. Create Xcode Project (2 minutes)

```bash
# Open Xcode
# File → New → Project → iOS → App
# - Product Name: DriverAppTranslatorDemo
# - Interface: SwiftUI
# - Language: Swift
# - Save in this directory
```

Or use this directory path when creating the project:
```
/Users/maximmakarenko/vektor-dev/driver-app-translator-demo
```

### 2. Add Zumu SDK Dependency (1 minute)

In Xcode:
1. **File → Add Package Dependencies**
2. Enter URL: `https://github.com/Zumu-AI/zumu-ios-sdk`
3. **Dependency Rule**: Version → `1.0.0` → "Up to Next Major Version"
4. Click **Add Package**
5. Ensure **ZumuTranslator** is checked
6. Click **Add Package**

### 3. Add Source Files (1 minute)

Copy the source files to your Xcode project:

**In Finder:**
```
Sources/DriverApp/
├── DriverAppApp.swift
├── ContentView.swift
├── Models/
│   ├── Trip.swift
│   └── Driver.swift
├── ViewModels/
│   └── TranslatorViewModel.swift
└── Views/
    ├── TripSelectionView.swift
    ├── TripPickerSheet.swift
    └── ActiveTripView.swift
```

**In Xcode:**
1. Drag the files from `Sources/DriverApp/` into your Xcode project
2. **Check**: "Copy items if needed"
3. **Check**: "Create groups"
4. Ensure files are added to your target

### 4. Configure Info.plist (30 seconds)

Either:
- **Copy** the provided `Info.plist` to replace your project's Info.plist

OR

- **Manually add** these keys in Xcode:
  1. Select your project → Target → Info tab
  2. Add these keys:
     - `NSMicrophoneUsageDescription`: "Zumu needs microphone access for real-time translation"
     - `NSSpeechRecognitionUsageDescription`: "Zumu needs speech recognition to translate conversations"

### 5. Set API Key (30 seconds)

**Option A: Environment Variable (Recommended)**
1. Product → Scheme → Edit Scheme
2. Run → Arguments tab → Environment Variables
3. Click `+`
4. Name: `ZUMU_API_KEY`
5. Value: `zumu_your_actual_key_here`

**Option B: Temporary Hardcode (Testing Only)**
Edit `ViewModels/TranslatorViewModel.swift` line 13:
```swift
let apiKey = "zumu_your_actual_key_here"
```

### 6. Build & Run

1. Select iPhone simulator (or physical device)
2. Press `⌘ + R`
3. Grant microphone permission when prompted
4. Start testing!

---

## Verify Setup

### ✅ Checklist

- [ ] Xcode project created
- [ ] Zumu SDK added via SPM
- [ ] All source files imported
- [ ] Info.plist configured
- [ ] API key set
- [ ] App builds without errors
- [ ] App runs on simulator
- [ ] Can see driver info screen
- [ ] Can select test trips
- [ ] "Start Translation" button appears

---

## First Test

1. Tap **"Select Test Trip"**
2. Choose **"María García"** (Spanish test)
3. Tap **"Start Translation"**
4. Watch the console logs:
   ```
   ✅ Session started successfully: [session-id]
   ```
5. Speak into your mic (or simulate in simulator)
6. Check for translated messages

---

## Troubleshooting

### Build Errors

**"Cannot find 'ZumuTranslator' in scope"**
- Solution: File → Packages → Resolve Package Versions
- Or: File → Packages → Reset Package Caches

**"Missing required module 'ZumuTranslator'"**
- Solution: Clean build folder (`⌘ + Shift + K`)
- Rebuild (`⌘ + B`)

### Runtime Errors

**"Invalid API key"**
- Check your API key is correct
- Verify it's active in Zumu Dashboard
- Ensure environment variable is set properly

**"No microphone permission"**
- iOS Simulator: Check Settings → Privacy → Microphone
- Physical Device: Grant permission when prompted

---

## Next Steps

Once running:
1. Test all 3 sample trips
2. Verify SDK integration works
3. Document any issues in `TESTING_NOTES.md`
4. Read full `README.md` for detailed testing guide

---

## Quick Commands

```bash
# Clean build
⌘ + Shift + K

# Build
⌘ + B

# Run
⌘ + R

# Stop
⌘ + .
```

---

**Need help?** Check the full README.md or contact Zumu support.
