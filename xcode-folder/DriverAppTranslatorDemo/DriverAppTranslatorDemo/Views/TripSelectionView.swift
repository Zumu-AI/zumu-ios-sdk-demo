import SwiftUI

struct TripSelectionView: View {
    @Binding var selectedTrip: Trip?
    @Binding var showingTripPicker: Bool
    @State private var showingTranslator = false

    let driver = Driver.current

    var body: some View {
        VStack(spacing: 24) {
            // Driver info card
            DriverInfoCard(driver: driver)

            // Selected trip display
            if let trip = selectedTrip {
                TripCard(trip: trip)

                // Start translation button
                Button(action: {
                    showingTranslator = true
                }) {
                    HStack {
                        Image(systemName: "mic.fill")
                        Text("Start Translation")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .fullScreenCover(isPresented: $showingTranslator) {
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
            } else {
                // No trip selected state
                VStack(spacing: 16) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)

                    Text("No Active Trip")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Select a test trip to begin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            }

            // Test trips picker button
            Button(action: {
                showingTripPicker = true
            }) {
                HStack {
                    Image(systemName: "list.bullet")
                    Text("Select Test Trip")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .cornerRadius(12)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
        .sheet(isPresented: $showingTripPicker) {
            TripPickerSheet(
                selectedTrip: $selectedTrip,
                showingPicker: $showingTripPicker,
                onCreateNewTapped: {
                    showingTripPicker = false
                    // Create trip action would go here
                }
            )
        }
    }
}

struct DriverInfoCard: View {
    let driver: Driver

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)

                VStack(alignment: .leading, spacing: 4) {
                    Text(driver.name)
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text(driver.vehicleInfo)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        Text(String(format: "%.1f", driver.rating))
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }

                Spacer()

                VStack(alignment: .trailing) {
                    Text("Language")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(driver.language)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
        }
        .padding()
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct TripCard: View {
    let trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Current Trip")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)

                Spacer()

                Text(trip.estimatedDuration)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
            }

            // Passenger info
            HStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .font(.title2)
                    .foregroundColor(.green)
                    .frame(width: 40)

                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.passengerName)
                        .font(.headline)

                    if let language = trip.passengerLanguage {
                        HStack(spacing: 4) {
                            Image(systemName: "globe")
                                .font(.caption)
                            Text(language)
                                .font(.subheadline)
                        }
                        .foregroundColor(.secondary)
                    } else {
                        HStack(spacing: 4) {
                            Image(systemName: "wand.and.stars")
                                .font(.caption)
                            Text("Auto-detect language")
                                .font(.subheadline)
                        }
                        .foregroundColor(.orange)
                    }
                }

                Spacer()
            }

            Divider()

            // Locations
            VStack(spacing: 12) {
                LocationRow(
                    icon: "circle.fill",
                    iconColor: .blue,
                    location: trip.pickupLocation,
                    label: "Pickup"
                )

                LocationRow(
                    icon: "mappin.circle.fill",
                    iconColor: .red,
                    location: trip.dropoffLocation,
                    label: "Dropoff"
                )
            }

            // Trip ID
            HStack {
                Text("Trip ID:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(trip.id)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct LocationRow: View {
    let icon: String
    let iconColor: Color
    let location: String
    let label: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(location)
                    .font(.subheadline)
            }

            Spacer()
        }
    }
}

struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.red)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.red)
            Spacer()
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}
