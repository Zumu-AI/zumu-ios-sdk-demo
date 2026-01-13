import SwiftUI
import LiveKit
import LiveKitComponents
import Combine

/// Driver-friendly translation button with intuitive state-based design
/// States: inactive (compact) → connecting (compact) → active states (expanded with controls)
public struct ZumuTranslatorButton: View {
    let config: ZumuTranslator.TranslationConfig
    let apiKey: String

    @StateObject private var viewModel: ButtonViewModel
    @State private var showTranscript = false

    public init(config: ZumuTranslator.TranslationConfig, apiKey: String) {
        self.config = config
        self.apiKey = apiKey
        _viewModel = StateObject(wrappedValue: ButtonViewModel(config: config, apiKey: apiKey))
    }

    // Grid system (4pt base)
    private let grid: CGFloat = 4

    public var body: some View {
        ZStack(alignment: .bottom) {
            // Main button container - fixed width
            HStack(spacing: 12) {
                // Show mute button on left side (only in active states)
                if viewModel.isConnected && viewModel.state != .connecting && viewModel.state != .disconnecting {
                    // Mute button
                    Button(action: {
                        Task { await viewModel.toggleMic() }
                    }) {
                        Image(systemName: viewModel.isMicMuted ? "mic.slash.fill" : "mic.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(viewModel.isMicMuted ? .red : .white)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(.black.opacity(0.3)))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(.scale.combined(with: .opacity))
                }

                // Main button - tap to start/stop
                Button(action: {
                    Task { await viewModel.handleTap() }
                }) {
                    HStack(spacing: 12) {
                        // Left side: Icon or visualizer
                        visualizationView

                        // Center: State text
                        Text(viewModel.state.label)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 16)
                    .frame(width: 200, height: 56)
                    .background(backgroundView)
                }
                .buttonStyle(PlainButtonStyle())
                .allowsHitTesting(viewModel.state != .thinking && viewModel.state != .disconnecting)
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.state)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: viewModel.isConnected)
            .onLongPressGesture(minimumDuration: 1.0) {
                if !viewModel.transcripts.isEmpty {
                    showTranscript = true
                }
            }

            // Transcript popover
            if showTranscript {
                TranscriptPopover(messages: viewModel.transcripts, isVisible: $showTranscript)
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.8).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .offset(y: -80)
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: showTranscript)
    }

    // MARK: - Visualization View

    @ViewBuilder
    private var visualizationView: some View {
        switch viewModel.state {
        case .inactive:
            // AI Translate icon - sparkles for AI
            Image(systemName: "sparkles")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))

        case .connecting:
            // Loader (not pulsating dots)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(0.9)

        case .disconnecting:
            // Loader for disconnecting
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(0.9)

        case .listening:
            // Full waveform for listening (visualizes incoming audio)
            // BarAudioVisualizer works with nil audioTrack - will still render
            BarAudioVisualizer(
                audioTrack: viewModel.localAudioTrack, // Pass nil if not available yet
                agentState: .listening,
                barCount: 5,
                barSpacingFactor: 0.08, // LiveKit SDK best practice value
                barMinOpacity: 1.0 // Solid white bars (no grey effect)
            )
            .frame(width: 50, height: 28)
            .onAppear {
                let trackStatus = viewModel.localAudioTrack != nil ? "with audio track" : "without audio track (will still render)"
                print("🎵 Rendering BarAudioVisualizer in listening state: \(trackStatus)")
            }

        case .thinking:
            // Pulsating dot for thinking/translating
            PulsatingDot()

        case .translating:
            // Clean waveform moving with agent speech
            // Use agent's audio track (not local microphone) to show agent speaking
            BarAudioVisualizer(
                audioTrack: viewModel.agentAudioTrack, // Agent's voice output
                agentState: viewModel.livekitAgentState ?? .speaking,
                barCount: 5,
                barSpacingFactor: 0.08, // LiveKit SDK best practice value
                barMinOpacity: 1.0 // Solid white bars (no grey effect)
            )
            .frame(width: 50, height: 28)
            .onAppear {
                let trackStatus = viewModel.agentAudioTrack != nil ? "with agent audio track" : "without agent audio track (will still render)"
                print("🎵 Rendering BarAudioVisualizer in translating state: \(trackStatus)")
            }

        case .error:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.red)
        }
    }

    // MARK: - Background View

    @ViewBuilder
    private var backgroundView: some View {
        AnimatedGradientBackground(
            state: viewModel.state,
            audioLevel: viewModel.audioLevel
        )
        .shadow(color: .black.opacity(0.2), radius: 12, y: 6)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Button State

enum ButtonState: Equatable {
    case inactive, connecting, listening, thinking, translating, disconnecting, error(String)

    var label: String {
        switch self {
        case .inactive:
            return "AI Translate"
        case .connecting:
            return "Cancel"
        case .listening:
            return "Listening"
        case .thinking:
            return "Translating"
        case .translating:
            return "Speaking"
        case .disconnecting:
            return "Disconnecting"
        case .error(let msg):
            return msg
        }
    }
}

// MARK: - Animated Gradient Background (Orb-Inspired)

/// Animated gradient background inspired by ElevenLabs StateOrb
/// Uses state-specific color pairs and animation patterns
struct AnimatedGradientBackground: View {
    let state: ButtonState
    let audioLevel: Float

    @State private var animationPhase: CGFloat = 0
    @State private var pulseScale: CGFloat = 1.0

    // State-specific color pairs (exact specifications)
    private var colorPair: (Color, Color) {
        switch state {
        case .inactive, .connecting, .disconnecting:
            // Idle: Calm, ready, professional
            return (
                Color(hex: "7C3AED"), // Vibrant Purple
                Color(hex: "4F46E5")  // Deep Indigo
            )
        case .listening:
            // Listening: Alert, attentive, engaged
            return (
                Color(hex: "A855F7"), // Bright Purple
                Color(hex: "7C3AED")  // Vibrant Purple
            )
        case .thinking:
            // Thinking: Contemplative, processing
            return (
                Color(hex: "5B21B6"), // Deep Indigo
                Color(hex: "7C3AED")  // Vibrant Purple
            )
        case .translating:
            // Speaking: Active, energetic, communicating
            return (
                Color(hex: "6366F1"), // Indigo
                Color(hex: "3B82F6")  // Bright Blue
            )
        case .error:
            return (
                Color.red.opacity(0.7),
                Color.red.opacity(0.4)
            )
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 30)
            .fill(gradientFill)
            .scaleEffect(pulseScale)
            .onAppear {
                startAnimation()
            }
            .onChange(of: state) { _, _ in
                startAnimation()
            }
    }

    private var gradientFill: LinearGradient {
        let colors = colorPair

        switch state {
        case .inactive, .connecting, .disconnecting:
            // Static gradient for inactive states
            return LinearGradient(
                colors: [colors.0, colors.1],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

        case .listening:
            // Medium pulse, flowing gradient
            return LinearGradient(
                colors: [colors.0, colors.1, colors.0],
                startPoint: UnitPoint(x: animationPhase, y: 0),
                endPoint: UnitPoint(x: animationPhase + 1, y: 1)
            )

        case .thinking:
            // Contemplative wobble, circulating gradient
            return LinearGradient(
                colors: [colors.0, colors.1, colors.0],
                startPoint: UnitPoint(
                    x: 0.5 + cos(animationPhase) * 0.3,
                    y: 0.5 + sin(animationPhase) * 0.3
                ),
                endPoint: UnitPoint(
                    x: 0.5 - cos(animationPhase) * 0.3,
                    y: 0.5 - sin(animationPhase) * 0.3
                )
            )

        case .translating:
            // Audio-reactive, energetic flow
            let audioBoost = CGFloat(audioLevel) * 0.3
            return LinearGradient(
                colors: [colors.0, colors.1, colors.0],
                startPoint: UnitPoint(x: 0.5 - audioBoost, y: 0),
                endPoint: UnitPoint(x: 0.5 + audioBoost + animationPhase, y: 1)
            )

        case .error:
            return LinearGradient(
                colors: [colors.0, colors.1],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func startAnimation() {
        // Cancel any existing animations first
        withAnimation(.linear(duration: 0)) {
            animationPhase = 0
            pulseScale = 1.0
        }

        switch state {
        case .inactive, .connecting, .disconnecting, .error:
            // Static, no animation - explicitly keep at 1.0
            animationPhase = 0
            pulseScale = 1.0
            break

        case .listening:
            // Flowing gradient (no pulse) - reacts to audio input
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                animationPhase = 1.0
            }

        case .thinking:
            // Only thinking state pulsates + wobbles
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                animationPhase = .pi * 2
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.02 // Visible pulsating
            }

        case .translating:
            // Fast energetic flow (no pulse) - reacts to audio output
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                animationPhase = 1.0
            }
        }
    }
}

// MARK: - Color Extension (Hex Support)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: 1
        )
    }
}

// MARK: - Pulsating Dot for Thinking State

struct PulsatingDot: View {
    @State private var isPulsing = false

    var body: some View {
        Circle()
            .fill(.white)
            .frame(width: 12, height: 12)
            .scaleEffect(isPulsing ? 1.3 : 1.0)
            .opacity(isPulsing ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear { isPulsing = true }
    }
}

// MARK: - Pulsating Line for Listening State

/// Single vertical line that pulsates based on audio input level
struct PulsatingLine: View {
    let audioLevel: Float

    @State private var isAnimating = false

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(.white)
            .frame(width: 4, height: baseHeight)
            .scaleEffect(x: 1.0, y: heightScale)
            .animation(.easeInOut(duration: 0.15), value: audioLevel)
    }

    private var baseHeight: CGFloat {
        20
    }

    private var heightScale: CGFloat {
        // Scale based on audio level (0.0 to 1.0)
        let minScale: CGFloat = 0.5
        let maxScale: CGFloat = 1.5
        let scale = minScale + (CGFloat(audioLevel) * (maxScale - minScale))
        return scale
    }
}

// MARK: - Transcript Popover

struct TranscriptPopover: View {
    let messages: [TranscriptMsg]
    @Binding var isVisible: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recent Messages")
                    .font(.headline)
                Spacer()
                Button(action: { isVisible = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(messages.suffix(5)) { msg in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(msg.role)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(.secondary)
                            Text(msg.text)
                                .font(.body)
                        }
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                }
            }
            .frame(maxHeight: 200)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.systemBackground))
                .shadow(radius: 20)
        )
        .padding(.horizontal, 20)
        .frame(maxWidth: 360)
    }
}

struct TranscriptMsg: Identifiable {
    let id = UUID()
    let role: String
    let text: String
}

// MARK: - Button View Model

@MainActor
class ButtonViewModel: NSObject, ObservableObject, RoomDelegate {
    @Published var state: ButtonState = .inactive
    @Published var isConnected = false
    @Published var audioLevel: Float = 0.0
    @Published var transcripts: [TranscriptMsg] = []
    @Published var localAudioTrack: AudioTrack?
    @Published var agentAudioTrack: AudioTrack? // Agent's voice output
    @Published var isMicMuted: Bool = false
    @Published var livekitAgentState: AgentState?

    private let config: ZumuTranslator.TranslationConfig
    private let apiKey: String
    private var session: Session?
    private var pollingTask: Task<Void, Never>?
    private var audioLevelTask: Task<Void, Never>?
    private var connectionTask: Task<Void, Error>?

    init(config: ZumuTranslator.TranslationConfig, apiKey: String) {
        self.config = config
        self.apiKey = apiKey
        super.init()
    }

    func handleTap() async {
        switch state {
        case .inactive:
            await connect()
        case .connecting:
            // Cancel connection
            await disconnect()
        case .listening, .translating, .thinking:
            // Show disconnecting state, then disconnect
            state = .disconnecting
            await disconnect()
        default:
            break
        }
    }

    func toggleMic() async {
        guard let session = session else { return }
        let localParticipant = session.room.localParticipant
        let currentlyEnabled = localParticipant.isMicrophoneEnabled()

        print("🎤 Toggling mic: currently \(currentlyEnabled ? "enabled" : "disabled")")

        do {
            // Set new state
            try await localParticipant.setMicrophone(enabled: !currentlyEnabled)

            // Read back the actual state after setting
            let newState = localParticipant.isMicrophoneEnabled()
            isMicMuted = !newState

            print("🎤 Mic is now \(isMicMuted ? "muted" : "unmuted") (enabled: \(newState))")
        } catch {
            print("❌ Failed to toggle mic: \(error)")
        }
    }

    private func connect() async {
        // Cancel any existing connection attempt
        connectionTask?.cancel()

        connectionTask = Task { @MainActor in
            state = .connecting

            do {
                // End any existing session first
                if let existingSession = session {
                    await existingSession.end()
                    session = nil
                }

                // Create token source
                let tokenConfig = ZumuTokenSource.TranslationConfig(
                    driverName: config.driverName,
                    driverLanguage: config.driverLanguage,
                    passengerName: config.passengerName,
                    passengerLanguage: config.passengerLanguage,
                    tripId: config.tripId
                )

                let tokenSource = ZumuTokenSource(
                    apiKey: apiKey,
                    config: tokenConfig,
                    baseURL: "https://translator.zumu.ai"
                )

                print("📞 Token source created with trip_id: \(config.tripId ?? "nil")")
                print("📞 Driver: \(config.driverName) (\(config.driverLanguage))")
                print("📞 Passenger: \(config.passengerName) (\(config.passengerLanguage ?? "auto"))")

                // Check for cancellation
                try Task.checkCancellation()

                // Create session
                let newSession = Session(
                    tokenSource: tokenSource,
                    options: SessionOptions(
                        room: Room(
                            roomOptions: RoomOptions(
                                defaultAudioCaptureOptions: AudioCaptureOptions(),
                                defaultAudioPublishOptions: AudioPublishOptions()
                            )
                        )
                    )
                )

                newSession.room.add(delegate: self)

                // Check for cancellation before starting
                try Task.checkCancellation()

                // Start the session
                await newSession.start()

                // Check for cancellation after start
                try Task.checkCancellation()

                self.session = newSession
                self.isConnected = true
                self.state = .listening

                // Start monitoring first
                startAgentStatePolling()
                startAudioLevelMonitoring()

                // Wait briefly for tracks to be published, then expose local audio track
                Task { @MainActor in
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

                    if let firstAudioTrack = newSession.room.localParticipant.audioTracks.first,
                       let audioTrack = firstAudioTrack.track as? AudioTrack {
                        self.localAudioTrack = audioTrack
                        print("🎤 Local audio track available: \(audioTrack)")
                    } else {
                        print("⚠️ No local audio track found yet - will be captured via didPublishTrack delegate")
                        print("⚠️ Audio tracks count: \(newSession.room.localParticipant.audioTracks.count)")
                    }
                }

                print("✅ Button: Connected to LiveKit")
                print("🤖 Button: Initial agent state: \(newSession.agent.agentState as Any)")

            } catch is CancellationError {
                state = .inactive
                print("🚫 Button: Connection cancelled by user")
            } catch {
                state = .error("Connection Failed")
                print("❌ Button: Connection error: \(error)")
            }
        }

        // Await the connection task
        _ = await connectionTask?.result
    }

    func disconnect() async {
        // Cancel all tasks including connection
        connectionTask?.cancel()
        pollingTask?.cancel()
        audioLevelTask?.cancel()

        if let session = session {
            await session.end()
        }

        session = nil
        isConnected = false
        state = .inactive
        audioLevel = 0.0
        localAudioTrack = nil
        agentAudioTrack = nil
        isMicMuted = false
        transcripts.removeAll()

        print("✅ Button: Disconnected")
    }

    private func startAudioLevelMonitoring() {
        audioLevelTask = Task { @MainActor in
            while !Task.isCancelled {
                guard session != nil else { break }

                var targetLevel: Float = 0.0

                if state == .listening && !isMicMuted {
                    targetLevel = Float.random(in: 0.4...0.9)
                } else if state == .translating {
                    targetLevel = Float.random(in: 0.7...1.0)
                } else {
                    targetLevel = 0.0
                }

                let smoothingFactor: Float = 0.25
                self.audioLevel = self.audioLevel * (1 - smoothingFactor) + targetLevel * smoothingFactor

                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        }
    }

    private func startAgentStatePolling() {
        pollingTask = Task { @MainActor in
            var lastAgentState: AgentState?

            while !Task.isCancelled {
                guard let session = session else { break }

                let currentAgentState = session.agent.agentState

                // Update agent audio track (for waveform during speaking)
                self.agentAudioTrack = session.agent.audioTrack

                // Log agent state changes
                if lastAgentState != currentAgentState {
                    let previousState = lastAgentState.map { "\($0)" } ?? "nil"
                    print("🤖 Button: Agent state changed from \(previousState) to \(currentAgentState as Any)")
                    lastAgentState = currentAgentState
                }

                self.livekitAgentState = currentAgentState

                // Update button state based on agent state
                switch currentAgentState {
                case .idle, .listening:
                    if self.state != .listening {
                        print("🎧 Button: Transitioning to listening state")
                        self.state = .listening
                    }
                case .thinking:
                    if self.state != .thinking {
                        print("💭 Button: Transitioning to thinking state")
                        self.state = .thinking
                    }
                case .speaking:
                    if self.state != .translating {
                        print("🗣️ Button: Transitioning to speaking state")
                        self.state = .translating
                    }
                default:
                    // Handle initializing or any other agent states
                    break
                }

                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        }
    }

    // MARK: - RoomDelegate

    nonisolated func room(_ room: Room, participant: LocalParticipant, didPublishTrack publication: LocalTrackPublication) {
        Task { @MainActor in
            print("🎤 Track published: \(publication.kind)")

            if publication.kind == .audio, let audioTrack = publication.track as? AudioTrack {
                self.localAudioTrack = audioTrack
                print("🎤 Local audio track captured from publication: \(audioTrack)")
            }
        }
    }

    nonisolated func room(_ room: Room, participant: RemoteParticipant?, didReceiveData data: Data, forTopic topic: String, encryptionType: EncryptionType) {
        Task { @MainActor in
            guard topic == "lk.transcription" || topic.isEmpty else { return }

            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return
            }

            // Handle transcripts
            if let type = json["type"] as? String, type == "transcript",
               let text = json["text"] as? String,
               let role = json["role"] as? String {
                transcripts.append(TranscriptMsg(role: role, text: text))
                print("💬 Transcript: [\(role)] \(text)")
            }
        }
    }
}
