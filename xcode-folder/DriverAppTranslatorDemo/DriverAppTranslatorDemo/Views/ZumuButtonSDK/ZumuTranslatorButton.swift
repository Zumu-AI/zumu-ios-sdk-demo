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
            // Main button container - width changes based on state
            HStack(spacing: 12) {
                // Show control buttons on left side (only in active states)
                if viewModel.isConnected && viewModel.state != .connecting {
                    HStack(spacing: 8) {
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

                        // End session button (X)
                        Button(action: {
                            Task { await viewModel.disconnect() }
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .background(Circle().fill(.black.opacity(0.3)))
                        }
                        .buttonStyle(PlainButtonStyle())
                        .transition(.scale.combined(with: .opacity))
                    }
                }

                // Main button
                Button(action: {
                    Task { await viewModel.handleTap() }
                }) {
                    HStack(spacing: 12) {
                        // Left side: Icon or visualizer
                        visualizationView

                        // Center: State text
                        Text(viewModel.state.label)
                            .font(.system(size: isCompact ? 16 : 18, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 20)
                    .frame(width: isCompact ? 180 : 240, height: 60)
                    .background(backgroundView)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(viewModel.state == .thinking)
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

    // MARK: - Computed Properties

    /// Whether button should be in compact format (inactive/connecting states)
    private var isCompact: Bool {
        viewModel.state == .inactive || viewModel.state == .connecting
    }

    // MARK: - Visualization View

    @ViewBuilder
    private var visualizationView: some View {
        switch viewModel.state {
        case .inactive:
            // AI Translate icon
            Image(systemName: "wand.and.stars")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white.opacity(0.9))

        case .connecting:
            // Loader (not pulsating dots)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                .scaleEffect(0.9)

        case .listening:
            // Clean waveform without pulsating dots
            if let localTrack = viewModel.localAudioTrack {
                BarAudioVisualizer(
                    audioTrack: localTrack,
                    agentState: .listening,
                    barCount: 5,
                    barSpacingFactor: 0.08,
                    barMinOpacity: 0.0 // No pulsating dots, clean waveform only
                )
                .frame(width: 44, height: 28)
            } else {
                // Fallback icon when no audio track
                Image(systemName: "waveform")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
            }

        case .thinking:
            // Pulsating dot for thinking/translating
            PulsatingDot()

        case .translating:
            // Clean waveform moving with agent speech
            if let localTrack = viewModel.localAudioTrack {
                BarAudioVisualizer(
                    audioTrack: localTrack,
                    agentState: viewModel.livekitAgentState ?? .speaking,
                    barCount: 5,
                    barSpacingFactor: 0.08,
                    barMinOpacity: 0.2
                )
                .frame(width: 44, height: 28)
            } else {
                Image(systemName: "speaker.wave.3.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .symbolEffect(.variableColor)
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
    case inactive, connecting, listening, thinking, translating, error(String)

    var label: String {
        switch self {
        case .inactive:
            return "AI Translate"
        case .connecting:
            return "Cancel"
        case .listening:
            return "Listening..."
        case .thinking:
            return "Translating..."
        case .translating:
            return "Speaking"
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
        case .inactive, .connecting:
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
        case .inactive, .connecting:
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
        // Reset animation
        animationPhase = 0
        pulseScale = 1.0

        switch state {
        case .inactive, .connecting, .error:
            // Static, no animation
            break

        case .listening:
            // Medium pulse + flowing animation
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                animationPhase = 1.0
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseScale = 1.02
            }

        case .thinking:
            // Slow contemplative wobble
            withAnimation(.linear(duration: 4.0).repeatForever(autoreverses: false)) {
                animationPhase = .pi * 2
            }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseScale = 1.015
            }

        case .translating:
            // Fast energetic flow
            withAnimation(.linear(duration: 2.0).repeatForever(autoreverses: false)) {
                animationPhase = 1.0
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                pulseScale = 1.03
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

// MARK: - Thinking Dots (Legacy - can remove if not needed)

struct ThinkingDots: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(.primary)
                    .frame(width: 8, height: 8)
                    .opacity(animating ? 1.0 : 0.3)
                    .animation(
                        .easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .onAppear { animating = true }
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
    @Published var isMicMuted: Bool = false
    @Published var livekitAgentState: AgentState?

    private let config: ZumuTranslator.TranslationConfig
    private let apiKey: String
    private var session: Session?
    private var pollingTask: Task<Void, Never>?
    private var audioLevelTask: Task<Void, Never>?

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
        case .listening, .translating:
            // Disconnect when tapped in active states
            await disconnect()
        default:
            break
        }
    }

    func toggleMic() async {
        guard let session = session else { return }
        let localParticipant = session.room.localParticipant
        let currentlyEnabled = localParticipant.isMicrophoneEnabled()

        do {
            try await localParticipant.setMicrophone(enabled: !currentlyEnabled)
            isMicMuted = !currentlyEnabled
            print("🎤 Mic \(isMicMuted ? "muted" : "unmuted")")
        } catch {
            print("❌ Failed to toggle mic: \(error)")
        }
    }

    private func connect() async {
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

            print("📞 Token source created with trip_id: \(config.tripId)")

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

            // Start the session
            await newSession.start()

            self.session = newSession
            self.isConnected = true
            self.state = .listening

            // Expose local audio track
            if let firstAudioTrack = newSession.room.localParticipant.audioTracks.first,
               let audioTrack = firstAudioTrack.track as? AudioTrack {
                self.localAudioTrack = audioTrack
                print("🎤 Local audio track available")
            }

            // Start monitoring
            startAgentStatePolling()
            startAudioLevelMonitoring()

            print("✅ Button: Connected to LiveKit")

        } catch {
            state = .error("Connection Failed")
            print("❌ Button: Connection error: \(error)")
        }
    }

    func disconnect() async {
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
            while !Task.isCancelled {
                guard let session = session else { break }

                let currentAgentState = session.agent.agentState
                self.livekitAgentState = currentAgentState

                // Update button state based on agent state
                switch currentAgentState {
                case .idle, .listening:
                    if self.state != .listening {
                        print("🎧 Agent state: listening")
                        self.state = .listening
                    }
                case .thinking:
                    if self.state != .thinking {
                        print("💭 Agent state: thinking")
                        self.state = .thinking
                    }
                case .speaking:
                    if self.state != .translating {
                        print("🗣️ Agent state: speaking")
                        self.state = .translating
                    }
                @unknown default:
                    break
                }

                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        }
    }

    // MARK: - RoomDelegate

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
