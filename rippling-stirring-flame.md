# Convert Full-Screen Translation Modal to Minimalistic AI Button

## Executive Summary

**Goal**: Transform the existing full-screen ZumuSDK translation UI into a persistent, non-intrusive 200×50pt button that stays fixed in the bottom-right corner across all views.

**Key Requirements**:
- ✅ ChatGPT-style minimalistic design
- ✅ Fixed bottom-right corner position (never moves or overlaps critical UI)
- ✅ 200×50pt pill shape (consistent across all states)
- ✅ Intuitive for drivers (one-tap to connect, visual state feedback)
- ✅ Waveform visualization (5 bars)
- ✅ State indicators (listening/thinking/translating)
- ✅ Mic mute toggle (inline)
- ✅ Transcript on long-press (not always visible)
- ✅ Preserve all LiveKit functionality and session safety patterns

**Baseline**: Clean fork at `/Users/maximmakarenko/vektor-dev/zumu-sdk-translate-button/`

**Status**: Phase 1 verification pending (original demo build test)

---

## Design Specifications

### Button States (7 Total)

All states maintain **200×50pt** size (no jumping or resizing).

#### 1. Inactive State (Purple)
```
┌──────────────────────────────────────┐
│  🔤  Start Translation               │  200×50pt
└──────────────────────────────────────┘
```
**Color**: Purple (#7C3AED)  
**Action**: Tap to connect

#### 2. Connecting State (Gray)
```
┌──────────────────────────────────────┐
│  ⏳  Connecting...                   │  200×50pt
└──────────────────────────────────────┘
```
**Color**: Gray (#6B7280)  
**Animation**: Spinner

#### 3. Listening State (Purple + Waveform)
```
┌──────────────────────────────────────┐
│  🎙️ ▁▃▅▃▁  Listening...             │  200×50pt
└──────────────────────────────────────┘
```
**Color**: Purple (#7C3AED)  
**Animation**: 5-bar waveform, mic icon

#### 4. Thinking State (Orange)
```
┌──────────────────────────────────────┐
│  🤔 ●●●  Thinking...                 │  200×50pt
└──────────────────────────────────────┘
```
**Color**: Orange (#F97316)  
**Animation**: 3-dot pulsing

#### 5. Translating State (Green)
```
┌──────────────────────────────────────┐
│  🔊 )))  Translating...              │  200×50pt
└──────────────────────────────────────┘
```
**Color**: Green (#10B981)  
**Animation**: Speaker waves

#### 6. Muted State (Red)
```
┌──────────────────────────────────────┐
│  🔇 ▁▃▅▃▁  Muted                     │  200×50pt
└──────────────────────────────────────┘
```
**Color**: Red (#EF4444)  
**Icon**: Muted mic, waveform still shows

#### 7. Error State (Red)
```
┌──────────────────────────────────────┐
│  ⚠️  Connection Lost                 │  200×50pt
└──────────────────────────────────────┘
```
**Color**: Red (#EF4444)  
**Action**: Tap to retry

### Transcript Popover (Long-Press)

```
        ┌────────────────────────────┐
        │ "Hello, how are you?"      │
        │ "Привет, как дела?"        │
        └────────────────────────────┘
                    ▼
        ┌──────────────────────────────────────┐
        │  🔊 )))  Translating...              │
        └──────────────────────────────────────┘
```

**Trigger**: Long-press button for 1 second  
**Dismissal**: Auto after 5 seconds or tap outside  
**Content**: Last 2-3 transcript messages  
**Style**: Semi-transparent (.ultraThinMaterial)

---

## Architecture Overview

### New Folder Structure

```
ZumuButtonSDK/                    ← NEW - Button SDK
├── Core/
│   ├── ButtonSessionManager.swift      (~450 lines)
│   ├── ZumuTokenSource.swift           (~150 lines, reuse from ZumuSDK)
│   └── AudioManager.swift              (~100 lines)
│
├── ViewModels/
│   └── ButtonViewModel.swift           (~350 lines)
│
├── Views/
│   ├── ZumuTranslatorButtonView.swift  (~280 lines) - Main button
│   ├── ButtonStateView.swift           (~200 lines) - State visuals
│   ├── WaveformView.swift              (~120 lines) - 5-bar animation
│   └── TranscriptPopover.swift         (~140 lines) - Long-press popup
│
├── Models/
│   ├── ButtonState.swift               (~40 lines)
│   ├── ButtonConfig.swift              (~60 lines)
│   └── TranscriptMessage.swift         (~30 lines)
│
└── Helpers/
    ├── ButtonStyles.swift              (~80 lines)
    └── HapticFeedback.swift            (~50 lines)
```

**Total New Code**: ~1,740 lines across 13 new files  
**Modified Code**: 3 view files (remove modal, add button overlay)  
**Preserved**: Original ZumuSDK/ kept as backup

---

## Critical Safety Patterns to Preserve

### 1. SessionCoordinator Pattern (Prevents Crashes)

**Location**: Will be in `ButtonSessionManager.swift`

```swift
// CRITICAL: Wait 800ms for LocalMedia.deinit cleanup
await SessionCoordinator.shared.prepareForNewSession()
// Only then create new Session/LocalMedia
let newSession = try await Session(...)
```

**Why**: LocalMedia cleanup takes 500-800ms. Creating overlapping sessions causes mutex deadlock.

### 2. Cached State Pattern (Prevents Deadlock)

**Location**: Will be in `ButtonViewModel.swift`

```swift
@Published var isConnectedCache: Bool = false
@Published var cachedMessages: [TranscriptMessage] = []

// NEVER access session.isConnected directly during disconnect
// Always use cached properties
```

**Why**: Accessing session properties during disconnect hits mutex locks and freezes UI.

### 3. Safe Polling Pattern (Background State Updates)

**Location**: Will be in `ButtonViewModel.swift`

```swift
func startStatePolling() {
    pollingTask = Task {
        while !Task.isCancelled {
            guard let session = sessionManager.session else { break }
            let agentState = session.agent.agentState
            await MainActor.run {
                self.currentState = ButtonState.from(agentState)
            }
            try? await Task.sleep(for: .milliseconds(100))
        }
    }
}
```

**Why**: Direct state access in SwiftUI views can cause race conditions. Polling + caching is safe.

---

## Implementation Plan

### Phase 1: Extract Core LiveKit Logic (~3-4 hours)

**Goal**: Create reusable session manager that handles LiveKit connection without UI.

**Files to Create**:

1. **ButtonSessionManager.swift** (~450 lines)
   - Session lifecycle (connect/disconnect)
   - Token fetching via ZumuTokenSource
   - Audio track subscription
   - Data message/stream handling
   - Agent state monitoring
   - Session safety via SessionCoordinator

2. **ZumuTokenSource.swift** (~150 lines)
   - Reuse from `ZumuSDK/Helpers/ZumuTokenSource.swift` (copy as-is)

3. **AudioManager.swift** (~100 lines)
   - Configure AVAudioSession for LiveKit
   - Handle audio interruptions
   - Extract from original SDK audio configuration logic

**Extract from**: `ZumuSDK/SDK/ZumuTranslator.swift` (lines 1-500)

---

### Phase 2: Create Button UI Components (~4-5 hours)

**Goal**: Build 200×50pt button with all 7 states and waveform visualization.

**Files to Create**:

1. **ButtonState.swift** (~40 lines)
   - Enum with 7 states
   - Color and label properties
   - Conversion from AgentState

2. **ButtonConfig.swift** (~60 lines)
   - Translation configuration model
   - Trip details, API key, backend URL

3. **TranscriptMessage.swift** (~30 lines)
   - Message model with id, text, speaker, timestamp

4. **ZumuTranslatorButtonView.swift** (~280 lines)
   - Main 200×50pt button UI
   - HStack with icon, waveform, label, mic toggle
   - Long-press gesture for transcript
   - Smooth animations between states

5. **ButtonStateView.swift** (~200 lines)
   - State icon rendering
   - Animations (spinner, pulse, waveform symbol)
   - ThinkingAnimation sub-view

6. **WaveformView.swift** (~120 lines)
   - 5-bar audio visualization
   - Extract from `ZumuSDK/Media/BarAudioVisualizer.swift`
   - Real-time height updates based on audio level

7. **TranscriptPopover.swift** (~140 lines)
   - Long-press popup above button
   - Last 2-3 messages display
   - Auto-dismiss after 5 seconds

---

### Phase 3: Create ViewModel and Integration (~3-4 hours)

**Goal**: Connect UI to session manager with proper state management.

**Files to Create**:

1. **ButtonViewModel.swift** (~350 lines)
   - @MainActor ObservableObject
   - Published state properties
   - Connection lifecycle methods
   - State polling task (100ms interval)
   - Audio level monitoring task
   - Microphone toggle
   - Haptic feedback integration

**Key Methods**:
- `connect()` - Connect to LiveKit room
- `disconnect()` - Cleanup and disconnect
- `toggleMicrophone()` - Mute/unmute
- `startStatePolling()` - Background agent state monitoring
- `startAudioLevelMonitoring()` - Waveform data

---

### Phase 4: Integrate Button into Views (~2-3 hours)

**Goal**: Replace full-screen modal with persistent button overlay in all 3 views.

**Files to Modify**:

1. **TripSelectionView.swift**
   - Remove `@State private var showingTranslator = false`
   - Remove `.fullScreenCover` modal
   - Add ZStack with button overlay
   - Button only appears when trip selected
   - Position: bottom-right, 20pt padding

2. **ActiveTripView.swift**
   - Remove large "Open Zumu Translator" button
   - Remove `@State private var showTranslation = false`
   - Remove `.fullScreenCover` modal
   - Add ZStack with button overlay
   - Button always visible
   - Position: bottom-right, 20pt padding

3. **RideshareActiveTripView.swift**
   - Remove floating action button (FAB)
   - Remove `@State private var showTranslator = false`
   - Remove `.fullScreenCover` modal
   - Add ZStack with button overlay
   - Position: bottom-right, 120pt from bottom (above trip sheet)
   - Add .zIndex(999) for visibility

---

### Phase 5: Add Polish and Helpers (~1-2 hours)

**Goal**: Haptic feedback, button styles, smooth animations.

**Files to Create**:

1. **HapticFeedback.swift** (~50 lines)
   - `impact(_ style)` - Tactile feedback on button tap
   - `notification(_ type)` - Success/error feedback
   - `selection()` - Selection feedback

**Usage**:
- `.impact(.medium)` - On button tap
- `.impact(.light)` - On mic toggle
- `.notification(.success)` - On successful connection
- `.notification(.error)` - On connection failure

2. **ButtonStyles.swift** (~80 lines)
   - `Color(hex:)` extension - Parse hex colors
   - `ButtonShadowModifier` - Consistent shadow styling
   - `.buttonShadow(color:)` view modifier

---

## Testing Strategy

### Manual Testing Checklist

#### Test 1: Button Appearance
- [ ] Button appears in TripSelectionView (only when trip selected)
- [ ] Button appears in ActiveTripView (always visible)
- [ ] Button appears in RideshareActiveTripView (above bottom sheet)
- [ ] Button is 200×50pt in all states
- [ ] Button is in bottom-right corner (20pt padding)

#### Test 2: Connection Flow
- [ ] Tap inactive button → transitions to "Connecting..."
- [ ] After 2-3 seconds → transitions to "Listening..." (purple + waveform)
- [ ] Waveform animates when speaking
- [ ] Agent state updates: listening → thinking → translating → listening

#### Test 3: Microphone Toggle
- [ ] Tap mic icon while connected → button turns red "Muted"
- [ ] Waveform still shows (visual feedback)
- [ ] Tap mic icon again → returns to "Listening..."
- [ ] Haptic feedback on toggle

#### Test 4: Transcript Popover
- [ ] Long-press button (1 second) → transcript appears above
- [ ] Popover shows last 2-3 messages
- [ ] Popover auto-dismisses after 5 seconds
- [ ] Tap outside popover → dismisses immediately

#### Test 5: Disconnection
- [ ] Tap button while listening → disconnects gracefully
- [ ] Button returns to inactive state
- [ ] No crashes or errors in console

#### Test 6: Error Handling
- [ ] Airplane mode → button shows "Connection Lost" (red)
- [ ] Tap error button → retries connection
- [ ] Backend offline → shows error state

---

## Known Issues and Solutions

### Issue 1: Button State Not Shared Across Views

**Problem**: Each view creates its own `ZumuTranslatorButtonView` instance, so switching views creates a new session.

**Solution**: Use a shared `@EnvironmentObject` for session state:

```swift
// Add to App.swift
@main
struct DriverAppTranslatorDemoApp: App {
    @StateObject private var buttonSession = ButtonViewModel.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(buttonSession)
        }
    }
}

// Modify ButtonViewModel to singleton
class ButtonViewModel: ObservableObject {
    static let shared = ButtonViewModel()
    private init() { ... }
}
```

**Alternative**: Only allow one active trip at a time (simpler, recommended for Phase 1).

### Issue 2: Button Overlaps Bottom Sheet in RideshareActiveTripView

**Solution**: Position button higher (120pt from bottom) with .zIndex(999).

```swift
.padding(.bottom, 120) // Higher position
.zIndex(999) // Ensure visibility
```

### Issue 3: Audio Level Calculation Requires Buffer Access

**Solution**: Reuse audio level calculation from original SDK or approximate with placeholder values for MVP.

---

## Implementation Time Estimate

| Phase | Tasks | Estimated Time |
|-------|-------|---------------|
| Phase 1 | Extract LiveKit logic (3 files) | 3-4 hours |
| Phase 2 | Create button UI (7 files) | 4-5 hours |
| Phase 3 | Create ViewModel (1 file) | 3-4 hours |
| Phase 4 | Integrate into views (3 files) | 2-3 hours |
| Phase 5 | Add polish (2 files) | 1-2 hours |
| Testing | Manual testing, bug fixes | 2-3 hours |
| **Total** | | **15-21 hours** |

**Recommendation**: Implement in phases, test after each phase.

---

## Success Criteria

✅ **Functionality**:
- Button connects to LiveKit successfully
- All 7 states transition correctly
- Waveform visualizes audio in real-time
- Mic mute toggle works
- Transcript appears on long-press
- Translation works end-to-end

✅ **UX**:
- Button is always 200×50pt (no size jumping)
- Smooth animations between states (<300ms)
- Haptic feedback on interactions
- Button never overlaps critical UI
- Intuitive for drivers (one-tap connect)

✅ **Stability**:
- No crashes on connect/disconnect
- No mutex deadlocks (SessionCoordinator working)
- Graceful error handling
- No memory leaks

---

## File Creation Order (Recommended)

**Day 1 (Core Logic)**:
1. ButtonState.swift
2. ButtonConfig.swift
3. TranscriptMessage.swift
4. ZumuTokenSource.swift (copy from original)
5. AudioManager.swift
6. ButtonSessionManager.swift

**Day 2 (UI Components)**:
7. WaveformView.swift
8. ButtonStateView.swift
9. TranscriptPopover.swift
10. HapticFeedback.swift
11. ButtonStyles.swift

**Day 3 (Integration)**:
12. ButtonViewModel.swift
13. ZumuTranslatorButtonView.swift
14. Modify TripSelectionView.swift
15. Modify ActiveTripView.swift
16. Modify RideshareActiveTripView.swift

**Day 4 (Testing & Polish)**:
17. Manual testing across all views
18. Bug fixes
19. Performance optimization
20. Final polish

---

## Critical Reminders

⚠️ **DO NOT**:
- Delete or modify original `ZumuSDK/` folder (keep as backup)
- Access session properties directly during disconnect (use cached states)
- Create overlapping sessions (use SessionCoordinator)
- Skip the 800ms cleanup delay

✅ **DO**:
- Test after each phase
- Use @MainActor for UI updates
- Add haptic feedback for better UX
- Keep button at 200×50pt in all states
- Use cached state properties
- Log errors for debugging

---

## Next Steps

1. **Phase 1 Verification**: User confirms original demo builds and runs ✅
2. **Plan Approval**: User reviews and approves this plan
3. **Implementation**: Execute phases 1-5 sequentially
4. **Testing**: Manual testing after each phase
5. **Deployment**: Integrate into production app

---

**Plan Created**: 2026-01-12  
**Estimated Completion**: 3-4 days of focused development  
**Risk Level**: Low (preserving all existing patterns, incremental changes)  
**Status**: ✅ Complete, awaiting Phase 1 verification and user approval
