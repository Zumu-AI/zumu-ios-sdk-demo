import SwiftUI

struct TripPickerSheet: View {
    @Binding var selectedTrip: Trip?
    @Binding var showingPicker: Bool
    let onCreateNewTapped: () -> Void

    let trips = Trip.samples

    var body: some View {
        NavigationView {
            List {
                // Create New Trip Button
                Section {
                    Button(action: onCreateNewTapped) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.white)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Create New Trip")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("Custom passenger and locations")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }

                // Sample Trips
                Section(header: Text("Sample Trips")) {
                    ForEach(trips) { trip in
                        Button(action: {
                            selectedTrip = trip
                            showingPicker = false
                        }) {
                            TripPickerRow(trip: trip)
                        }
                    }
                }
            }
            .navigationTitle("Select Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showingPicker = false
                    }
                }
            }
        }
    }
}

struct TripPickerRow: View {
    let trip: Trip

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(trip.passengerName)
                    .font(.headline)

                Spacer()

                if let language = trip.passengerLanguage {
                    Text(language)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                } else {
                    Text("Auto-detect")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(8)
                }
            }

            HStack(spacing: 4) {
                Image(systemName: "arrow.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(trip.pickupLocation) → \(trip.dropoffLocation)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}
