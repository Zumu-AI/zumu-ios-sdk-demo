# Zumu iOS SDK - Issues Found During Testing

**Date:** November 25, 2024
**SDK Version:** main branch (latest)
**Tester:** Driver App Integration Test
**API Key Used:** zumu_iZkF5TngXZs3-HWAVjblozL2sB8H2jPi9sc38JRQvWk

---

## Issue #1: Missing UIKit Import ✅ FIXED

**Status:** Fixed by Zumu team
**Severity:** Critical - Compilation Error

**Description:**
The SDK was missing `import UIKit` causing compilation failure when trying to use `UIDevice.current.model` on line 157.

**Fix Applied:**
Zumu team added `import UIKit` to the imports.

---

## Issue #2: API Endpoint Changed ✅ FIXED

**Status:** Fixed by Zumu team
**Severity:** Critical - Runtime Error

**Description:**
The baseURL was updated from `https://api.zumu.ai` to `https://translator.zumu.ai` (line 39).

**Fix Applied:**
Zumu team updated the default baseURL in the SDK.

---

## Issue #3: SDK State Management - Error Recovery ⚠️ CRITICAL

**Status:** 🔴 **NEEDS FIX**
**Severity:** Critical - Blocks Usage

### Problem Description:

The SDK enters an **unrecoverable error state** when an API call fails. Once in error state, all subsequent session start attempts fail with:
```
invalidState("Cannot start session while in state: error(...)")
```

### Error Sequence Observed:

```
1. ❌ Error: invalidState("Cannot start session while in state: connecting")
   → User clicked button twice, causing race condition

2. ❌ Error: apiError("Failed to start conversation")
   → Real error: /api/conversations/start endpoint failed

3. ❌ Error: invalidState("Cannot start session while in state: error(...)")
   → SDK stuck in error state, cannot recover
   → All subsequent attempts fail with same error
```

### Root Cause:

Looking at `ZumuTranslator.swift` lines 44-79:

```swift
public func startSession(config: SessionConfig) async throws -> TranslationSession {
    guard state == .idle else {
        throw ZumuError.invalidState("Cannot start session while in state: \(state)")
    }

    state = .connecting

    do {
        // Step 1: Create session ✅ This succeeds
        let session = try await createBackendSession(config: config)

        // Step 2: Start conversation ❌ This fails
        let conversationData = try await startConversation(sessionId: session.id)

        // ... rest of setup
        state = .active
        return session

    } catch {
        state = .error(error.localizedDescription)  // ⚠️ STUCK HERE
        throw error
    }
}
```

**Problems:**

1. **No state reset mechanism** - Once in `.error` state, there's no way to return to `.idle`
2. **No cleanup on error** - If step 1 succeeds but step 2 fails, the backend session is orphaned
3. **Race condition vulnerability** - Multiple rapid clicks cause "Cannot start while connecting" error

### Recommended Fixes:

#### Fix 1: Add State Reset Method
```swift
/// Reset error state to allow retry
@MainActor
public func resetErrorState() {
    if case .error = state {
        state = .idle
        session = nil
        messages = []
    }
}
```

#### Fix 2: Better Error Handling in startSession
```swift
public func startSession(config: SessionConfig) async throws -> TranslationSession {
    guard state == .idle else {
        throw ZumuError.invalidState("Cannot start session while in state: \(state)")
    }

    state = .connecting
    var createdSession: TranslationSession?

    do {
        // Step 1: Create session
        let session = try await createBackendSession(config: config)
        createdSession = session
        self.session = session

        // Step 2: Start conversation
        let conversationData = try await startConversation(sessionId: session.id)

        // Step 3: Connect WebSocket
        try await connectWebSocket(conversationId: conversationData.conversationId,
                                   signedUrl: conversationData.signedUrl)

        // Step 4: Set up audio
        try await setupAudioCapture()

        state = .active
        return session

    } catch {
        // Clean up partial session if created
        if let session = createdSession {
            try? await updateSessionStatus(sessionId: session.id, status: "failed")
        }

        // Reset to idle instead of staying in error
        state = .idle  // ← Allow retry
        self.session = nil
        throw error
    }
}
```

#### Fix 3: Prevent Race Conditions
```swift
private var isStarting = false

public func startSession(config: SessionConfig) async throws -> TranslationSession {
    guard state == .idle else {
        throw ZumuError.invalidState("Cannot start session while in state: \(state)")
    }

    guard !isStarting else {
        throw ZumuError.invalidState("Session start already in progress")
    }

    isStarting = true
    defer { isStarting = false }

    // ... rest of implementation
}
```

### Impact:

- **User Experience:** Users cannot retry after any error, must restart app
- **Testing:** Difficult to test error recovery scenarios
- **Production:** Any transient network error makes the SDK unusable until app restart

---

## Issue #4: API Endpoint Failure - /api/conversations/start

**Status:** 🔴 **NEEDS INVESTIGATION**
**Severity:** High - Core Functionality

### Error Message:
```
apiError("Failed to start conversation")
```

### Details:

- Backend session creation succeeds (`/api/sessions` endpoint works)
- Conversation start fails (`/api/conversations/start` endpoint fails)
- Returns non-2xx HTTP status code

### Questions for Zumu Team:

1. Is the `/api/conversations/start` endpoint deployed?
2. Does it require additional authentication beyond the API key?
3. What's the expected request/response format?
4. Are there any rate limits or quotas?

### Debugging Info:

**Request to `/api/conversations/start` (line 178-186):**
```swift
POST https://translator.zumu.ai/api/conversations/start
Headers:
  - Authorization: Bearer zumu_iZkF5TngXZs3-HWAVjblozL2sB8H2jPi9sc38JRQvWk
  - Content-Type: application/json
Body:
  {
    "session_id": "<session_id from previous call>"
  }
```

**Expected Response:**
```json
{
  "conversation_id": "string",
  "signed_url": "wss://..."
}
```

---

## Issue #5: Error Messages Could Be More Helpful

**Status:** 🟡 **ENHANCEMENT**
**Severity:** Low - Developer Experience

### Current Errors:
- `"Failed to create session"` - No detail on why
- `"Failed to start conversation"` - No HTTP status code or response body

### Suggestion:
```swift
guard let httpResponse = response as? HTTPURLResponse,
      (200...299).contains(httpResponse.statusCode) else {
    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
    let body = String(data: data, encoding: .utf8) ?? "No response body"
    throw ZumuError.apiError("Failed to start conversation (HTTP \(statusCode)): \(body)")
}
```

This would help developers debug API issues.

---

## Testing Summary

### ✅ Working Features:
- SDK imports and compiles
- API key authentication
- Backend session creation (`/api/sessions`)
- UI integration with SwiftUI
- Published properties and Combine publishers
- Audio permissions handling

### ❌ Not Working:
- Conversation start (API endpoint issue)
- Error state recovery (SDK bug)
- Session retry after failure

### 🟡 Warnings:
- `onChange(of:perform:)` deprecated in iOS 17 (fixed in our app code)

---

## Recommendations

### For Zumu Team:

1. **CRITICAL:** Fix state management to allow retry after errors (Issue #3)
2. **CRITICAL:** Investigate `/api/conversations/start` endpoint (Issue #4)
3. **HIGH:** Add state reset method or auto-reset on error
4. **MEDIUM:** Improve error messages with HTTP status codes
5. **LOW:** Add SDK documentation for error handling best practices

### For App Developers:

1. Disable "Start Translation" button while session is connecting
2. Show detailed error messages to users
3. Add "Try Again" button that resets state (once SDK supports it)
4. Implement exponential backoff for retries

---

## Test Environment

- **iOS Version:** 26.1 (Simulator)
- **Xcode Version:** 26.1.1
- **Device:** iPhone 17 Pro Simulator
- **SDK Branch:** main
- **API Key:** zumu_iZkF5TngXZs3-HWAVjblozL2sB8H2jPi9sc38JRQvWk
- **Base URL:** https://translator.zumu.ai

---

## Contact

For questions about this report, contact the driver app integration team or open an issue on GitHub.
