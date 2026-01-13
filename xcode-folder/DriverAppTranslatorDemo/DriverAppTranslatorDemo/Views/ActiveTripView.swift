import SwiftUI

struct ActiveTripView: View {
    let trip: Trip

    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(red: 0.95, green: 0.97, blue: 1.0), Color.white],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Trip info header with glassmorphic design
                TripInfoHeader(trip: trip)
                    .padding(.bottom, 24)

                Spacer()

                // Info card (centered in remaining space)
                InfoCard()
                    .padding(.horizontal, 24)

                Spacer()
            }

            // Translation button overlay (bottom-right, always visible)
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    ZumuTranslatorButton(
                        config: ZumuTranslator.TranslationConfig(
                            driverName: trip.driverName,
                            driverLanguage: trip.driverLanguage,
                            passengerName: trip.passengerName,
                            passengerLanguage: trip.passengerLanguage,
                            tripId: trip.id,
                            externalDriverId: trip.externalDriverId,
                            memberId: trip.memberId
                        ),
                        apiKey: ProcessInfo.processInfo.environment["ZUMU_API_KEY"]
                            ?? "zumu_iZkF5TngXZs3-HWAVjblozL2sB8H2jPi9sc38JRQvWk"
                    )
                    .padding(.trailing, 20)
                    .padding(.bottom, 20)
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct TripInfoHeader: View {
    let trip: Trip

    var body: some View {
        VStack(spacing: 16) {
            // Passenger info
            HStack(spacing: 16) {
                // Avatar
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(String(trip.passengerName.prefix(1)))
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.passengerName)
                        .font(.title3)
                        .fontWeight(.semibold)

                    if let language = trip.passengerLanguage {
                        Label(language, systemImage: "globe")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Label("Language will be auto-detected", systemImage: "globe")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Duration badge
                Text(trip.estimatedDuration)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        LinearGradient(
                            colors: [Color.blue, Color.purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
            }

            // Destination
            HStack(spacing: 12) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundColor(.red)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Destination")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(trip.dropoffLocation)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .lineLimit(2)
                }

                Spacer()
            }
            .padding(16)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(.white.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [.white.opacity(0.5), .clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
}

struct InfoCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.blue)
                Text("About Translation")
                    .font(.headline)
                    .fontWeight(.semibold)
            }

            VStack(alignment: .leading, spacing: 8) {
                FeatureRow(icon: "waveform", text: "Real-time voice translation")
                FeatureRow(icon: "bubble.left.and.bubble.right", text: "Live conversation transcription")
                FeatureRow(icon: "speaker.wave.3", text: "Crystal clear audio quality")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
