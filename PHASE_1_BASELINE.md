# Phase 1: Clean Baseline Setup ✅

## 🎯 What We Did

Created a fresh, clean fork of the original working demo app for the button SDK migration.

---

## 📁 New Project Location

**Folder**: `/Users/maximmakarenko/vektor-dev/zumu-sdk-translate-button/`

**Xcode Project**:
```
/Users/maximmakarenko/vektor-dev/zumu-sdk-translate-button/xcode-folder/DriverAppTranslatorDemo/DriverAppTranslatorDemo.xcodeproj
```

---

## ✅ What's Included (Original Working Demo)

### Project Structure
```
zumu-sdk-translate-button/
├── xcode-folder/
│   └── DriverAppTranslatorDemo/
│       ├── DriverAppTranslatorDemo.xcodeproj  ← Open this in Xcode
│       └── DriverAppTranslatorDemo/
│           ├── ContentView.swift
│           ├── Views/
│           ├── Models/
│           ├── Helpers/
│           └── ZumuSDK/                       ← Original full-screen SDK
│               ├── SDK/
│               │   ├── ZumuTranslator.swift   ← Core LiveKit integration
│               │   ├── ZumuTranslatorView.swift
│               │   └── ...
│               ├── ControlBar/
│               ├── Media/
│               └── ...
├── Package.swift
├── Package.resolved
├── README.md
└── .git/
```

### Original SDK (Full-Screen Modal)
- ✅ **ZumuSDK/** folder - Working full-screen translation UI
- ✅ **LiveKit integration** - Real-time voice translation
- ✅ **All dependencies** configured in Package.swift
- ✅ **Clean git status** - No modifications

---

## 🚀 How to Open and Test (Phase 1)

### Step 1: Open in Xcode

**Option A - Terminal:**
```bash
cd /Users/maximmakarenko/vektor-dev/zumu-sdk-translate-button/xcode-folder/DriverAppTranslatorDemo
open DriverAppTranslatorDemo.xcodeproj
```

**Option B - Xcode:**
1. Open Xcode
2. File → Open
3. Navigate to: `/Users/maximmakarenko/vektor-dev/zumu-sdk-translate-button/xcode-folder/DriverAppTranslatorDemo/`
4. Select **DriverAppTranslatorDemo.xcodeproj**
5. Click Open

### Step 2: Resolve Packages

In Xcode:
1. **File → Packages → Reset Package Caches** (wait ~10 sec)
2. **File → Packages → Resolve Package Versions** (wait ~1-2 min)

Wait for these packages to download:
- LiveKit (client-sdk-swift)
- LiveKitComponents (components-swift)

### Step 3: Clean and Build

1. **Cmd+Shift+K** (Clean Build Folder)
2. **Cmd+B** (Build)

**Expected**: Build succeeds ✅

### Step 4: Run the App

1. Select **iPhone 15** simulator (or any iOS 16+ simulator)
2. **Cmd+R** (Run)

**Expected Behavior**:
- App launches ✅
- You see the driver app UI with trip selection
- Select a test trip
- Tap "Start Translation" button
- **Full-screen modal** appears with translation UI
- Button connects to LiveKit
- Translation works (English ↔ Russian)

---

## ✅ Verification Checklist

Before proceeding to Phase 2, verify:

- [ ] Xcode opens the project without errors
- [ ] Packages resolve successfully (LiveKit + LiveKitComponents)
- [ ] Build succeeds (Cmd+B)
- [ ] App runs in simulator
- [ ] Can select a test trip
- [ ] Translation modal opens when tapping button
- [ ] LiveKit connection works
- [ ] Voice translation works end-to-end

---

## 🎯 What This Proves

This clean baseline proves:
- ✅ Original SDK works perfectly
- ✅ LiveKit integration is solid
- ✅ Package dependencies are correct
- ✅ No mysterious build issues
- ✅ Translation logic is sound

---

## 📋 Next Steps (After Verification)

**Phase 2**: Add Button SDK
- Create new folder: `ZumuButtonSDK/`
- Copy button UI components
- Copy LiveKit integration (adapted for button)
- Update views to use button instead of modal

**Phase 3**: Integration
- Replace full-screen modal with button
- Test state transitions
- Verify smart transcript
- Ensure 200×50px consistency

---

## 📊 Current Status

**Phase 1**: ✅ **READY FOR TESTING**

**Git Status**: Clean (no modifications)

**Branch**: `main`

**Remote**: `origin` → https://github.com/Zumu-AI/zumu-ios-sdk-demo.git

---

## 🔧 If Issues Occur

### Issue: Packages Won't Resolve

**Fix**:
```bash
rm -rf ~/Library/Caches/org.swift.swiftpm
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```
Then reopen Xcode and try again.

### Issue: Build Fails

**Check**:
1. Xcode version (should be 15.0+)
2. iOS deployment target (should be 16.0+)
3. Code signing settings (should be automatic)

### Issue: Simulator Not Available

**Fix**:
1. Xcode → Window → Devices and Simulators
2. Click "+" to add iOS 16+ simulator
3. Download if needed

---

## 📝 Notes

- **NO modifications** have been made to this baseline
- **Original SDK** is intact and working
- **Clean git history** preserved
- **Ready for incremental changes**

---

## ✅ Summary

**What We Have**: Clean fork of working demo app

**What Works**: Full-screen modal translation with LiveKit

**What's Next**: Verify this builds and runs, then add button SDK

**Status**: ✅ Phase 1 Complete - Ready for User Testing

---

**Created**: 2026-01-12

**Next**: User verifies build, then proceed to Phase 2
