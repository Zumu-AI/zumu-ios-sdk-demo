import SwiftUI
import ZumuTranslator

struct ActiveTripView: View {
    @ObservedObject var viewModel: TranslatorViewModel
    let trip: Trip

    var body: some View {
        VStack(spacing: 0) {
            // Trip info header
            TripInfoHeader(trip: trip)

            // Translation status
            TranslationStatusBanner(
                state: viewModel.translator?.state ?? .idle,
                passengerLanguage: trip.passengerLanguage
            )

            // Messages area
            if let translator = viewModel.translator {
                MessagesView(messages: translator.messages)
            } else {
                Spacer()
                Text("Initializing translator...")
                    .foregroundColor(.secondary)
                Spacer()
            }

            // Controls
            ControlPanel(viewModel: viewModel)
        }
    }
}

struct TripInfoHeader: View {
    let trip: Trip

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.passengerName)
                        .font(.title3)
                        .fontWeight(.semibold)

                    if let language = trip.passengerLanguage {
                        Text("Speaking: \(language)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Text(trip.estimatedDuration)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }

            HStack(spacing: 8) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.red)
                    .font(.caption)
                Text(trip.dropoffLocation)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
    }
}

struct TranslationStatusBanner: View {
    let state: SessionState
    let passengerLanguage: String?

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)

            Text(statusText)
                .font(.subheadline)
                .fontWeight(.medium)

            Spacer()

            if state == .active {
                Image(systemName: "waveform")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(statusBackground)
    }

    private var statusColor: Color {
        switch state {
        case .idle: return .gray
        case .connecting: return .orange
        case .active: return .green
        case .disconnected: return .red
        case .ending: return .orange
        case .error: return .red
        }
    }

    private var statusText: String {
        switch state {
        case .idle: return "Ready to translate"
        case .connecting: return "Connecting translator..."
        case .active:
            if let language = passengerLanguage {
                return "Translating with \(language)"
            } else {
                return "Translating (auto-detecting language)"
            }
        case .disconnected: return "Connection lost"
        case .ending: return "Ending session..."
        case .error(let message): return "Error: \(message)"
        }
    }

    private var statusBackground: Color {
        switch state {
        case .active: return Color.green.opacity(0.1)
        case .error, .disconnected: return Color.red.opacity(0.1)
        case .connecting, .ending: return Color.orange.opacity(0.1)
        default: return Color.gray.opacity(0.1)
        }
    }
}

struct MessagesView: View {
    let messages: [TranslationMessage]

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                if messages.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "text.bubble")
                            .font(.system(size: 60))
                            .foregroundColor(.gray.opacity(0.5))

                        Text("Conversation will appear here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("Start talking to begin translation")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
            }
            .onChange(of: messages.count) { _ in
                if let lastMessage = messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
}

struct MessageBubble: View {
    let message: TranslationMessage

    var body: some View {
        HStack(alignment: .top) {
            if message.role == "user" {
                Spacer()
            }

            VStack(alignment: message.role == "user" ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .padding(12)
                    .background(message.role == "user" ? Color.blue : Color(UIColor.systemGray5))
                    .foregroundColor(message.role == "user" ? .white : .primary)
                    .cornerRadius(16)

                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            if message.role != "user" {
                Spacer()
            }
        }
    }
}

struct ControlPanel: View {
    @ObservedObject var viewModel: TranslatorViewModel
    @State private var messageText = ""

    var body: some View {
        VStack(spacing: 16) {
            Divider()

            // Message input (optional text messaging)
            HStack(spacing: 12) {
                TextField("Type a message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    guard !messageText.isEmpty else { return }
                    Task {
                        await viewModel.sendMessage(messageText)
                        messageText = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal)

            // Main controls
            HStack(spacing: 24) {
                // Mute button
                Button(action: {
                    viewModel.toggleMute()
                }) {
                    VStack {
                        Image(systemName: viewModel.translator?.isMuted == true ? "mic.slash.fill" : "mic.fill")
                            .font(.system(size: 32))
                            .foregroundColor(viewModel.translator?.isMuted == true ? .red : .blue)

                        Text(viewModel.translator?.isMuted == true ? "Unmute" : "Mute")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }

                // End session button
                Button(action: {
                    Task {
                        await viewModel.endSession()
                    }
                }) {
                    VStack {
                        Image(systemName: "phone.down.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.red)

                        Text("End Trip")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(UIColor.systemBackground))
    }
}
