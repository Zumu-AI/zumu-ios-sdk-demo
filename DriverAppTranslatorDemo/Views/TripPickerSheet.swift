import SwiftUI

struct TripPickerSheet: View {
    @Binding var selectedTrip: Trip?
    @Binding var showingPicker: Bool

    let trips = Trip.samples

    var body: some View {
        NavigationView {
            List(trips) { trip in
                Button(action: {
                    selectedTrip = trip
                    showingPicker = false
                }) {
                    TripPickerRow(trip: trip)
                }
            }
            .navigationTitle("Select Test Trip")
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
