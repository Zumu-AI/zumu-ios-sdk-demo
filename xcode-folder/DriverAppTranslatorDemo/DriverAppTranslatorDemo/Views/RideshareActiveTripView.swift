import SwiftUI

struct RideshareActiveTripView: View {
    let trip: Trip
    let onChangeTripTapped: () -> Void
    let onCreateTripTapped: () -> Void
    @State private var showTranslator = false
    // @StateObject private var audioPlayer = AudioTestPlayer.shared

    var body: some View {
        ZStack {
            // Background - simulated map
            MapPlaceholder()

            VStack(spacing: 0) {
                // Top navigation bar
                NavigationHeader(trip: trip)

                Spacer()

                // AI Translation button (bottom right corner)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()

                        VStack(spacing: 12) {
                            /* // Test Audio button - Disabled (file not in Xcode project)
                            Button(action: {
                                if audioPlayer.isPlaying {
                                    audioPlayer.stopAudio()
                                } else {
                                    audioPlayer.playTestAudio()
                                }
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: audioPlayer.isPlaying ? "stop.circle.fill" : "speaker.wave.2.circle.fill")
                                        .font(.system(size: 20))
                                    Text(audioPlayer.isPlaying ? "Stop Audio" : "Test Audio")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: audioPlayer.isPlaying ? [Color.red, Color.orange] : [Color.orange, Color.yellow]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                                .shadow(color: .orange.opacity(0.4), radius: 10, x: 0, y: 5)
                            }
                            */

                            // AI Translation button
                            Button(action: { showTranslator = true }) {
                                HStack(spacing: 8) {
                                    Image(systemName: "waveform.circle.fill")
                                        .font(.system(size: 20))
                                    Text("AI Translation")
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.purple, Color.blue]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                                .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
                            }
                        }
                        .padding(.trailing, 16)
                        .padding(.bottom, 16)
                    }
                }

                // Bottom sheet with trip info
                BottomTripSheet(
                    trip: trip,
                    onChangeTripTapped: onChangeTripTapped,
                    onCreateTripTapped: onCreateTripTapped
                )
            }
        }
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $showTranslator) {
            ZumuTranslatorView(
                config: ZumuTranslator.TranslationConfig(
                    driverName: trip.driverName,
                    driverLanguage: trip.driverLanguage,
                    passengerName: trip.passengerName,
                    passengerLanguage: trip.passengerLanguage,
                    tripId: trip.id,
                    pickupLocation: trip.pickupLocation,
                    dropoffLocation: trip.dropoffLocation
                ),
                apiKey: ProcessInfo.processInfo.environment["ZUMU_API_KEY"]
                    ?? "zumu_iZkF5TngXZs3-HWAVjblozL2sB8H2jPi9sc38JRQvWk"
            )
        }
    }
}

// MARK: - Map Placeholder
struct MapPlaceholder: View {
    var body: some View {
        ZStack {
            // Gradient background to simulate map
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.9, green: 0.95, blue: 0.98),
                    Color(red: 0.85, green: 0.92, blue: 0.96)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Route simulation
            VStack(spacing: 100) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                    )

                DashedLine()
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 4, dash: [10, 5]))
                    .frame(height: 150)

                Circle()
                    .fill(Color.red)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 4)
                    )
            }
            .opacity(0.3)
        }
    }
}

struct DashedLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        return path
    }
}

// MARK: - Navigation Header
struct NavigationHeader: View {
    let trip: Trip

    var body: some View {
        VStack(spacing: 0) {
            // Turn-by-turn style header
            HStack(spacing: 12) {
                Image(systemName: "arrow.turn.up.right")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.black.opacity(0.7))
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 4) {
                    Text("70 ft")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.9))

                    Text(trip.dropoffLocation.components(separatedBy: ",").first ?? trip.dropoffLocation)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                        Text("Dropping off \(trip.passengerName)")
                            .font(.caption)
                    }
                    .foregroundColor(.white.opacity(0.8))
                }

                Spacer()
            }
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.black.opacity(0.8), Color.black.opacity(0.4)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
    }
}

// MARK: - Bottom Trip Sheet
struct BottomTripSheet: View {
    let trip: Trip
    let onChangeTripTapped: () -> Void
    let onCreateTripTapped: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Drag handle
            RoundedRectangle(cornerRadius: 3)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 40, height: 5)
                .padding(.top, 8)

            // Trip progress bar
            TripProgressBar(trip: trip)
                .padding(.horizontal)
                .padding(.vertical, 12)

            Divider()

            // Passenger info
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Text(trip.passengerName.prefix(1))
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.passengerName)
                        .font(.headline)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text("4.9")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        if let language = trip.passengerLanguage {
                            Text("•")
                                .foregroundColor(.secondary)
                            Text(language)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        } else {
                            Text("•")
                                .foregroundColor(.secondary)
                            HStack(spacing: 2) {
                                Image(systemName: "wand.and.stars")
                                    .font(.caption)
                                Text("Auto-detect")
                            }
                            .font(.subheadline)
                            .foregroundColor(.orange)
                        }
                    }
                }

                Spacer()

                // Call/Message buttons
                HStack(spacing: 12) {
                    Button(action: {}) {
                        Image(systemName: "phone.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.green)
                            .clipShape(Circle())
                    }

                    Button(action: {}) {
                        Image(systemName: "message.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
            }
            .padding()

            Divider()

            // Trip actions
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    // Change trip button
                    Button(action: onChangeTripTapped) {
                        HStack {
                            Image(systemName: "arrow.triangle.2.circlepath")
                            Text("Change")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }

                    // Create new trip button
                    Button(action: onCreateTripTapped) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Create")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.purple)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(10)
                    }

                    // Complete trip button
                    Button(action: {
                        // Complete trip action (for demo purposes)
                    }) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Complete")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.black)
                        .cornerRadius(10)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: -5)
        )
    }
}

// MARK: - Trip Progress Bar
struct TripProgressBar: View {
    let trip: Trip

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 2) {
                Text("16 min")
                    .font(.title2)
                    .fontWeight(.bold)

                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Text("Similar ETA")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.title2)
                    .foregroundColor(.blue)

                Text("2.7 mi")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
}

