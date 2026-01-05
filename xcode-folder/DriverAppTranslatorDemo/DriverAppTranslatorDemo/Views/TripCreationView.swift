import SwiftUI

struct TripCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var createdTrip: Trip?

    // Form fields
    @State private var tripId = ""
    @State private var driverName = Driver.current.name
    @State private var driverLanguage = Driver.current.language
    @State private var passengerName = ""
    @State private var passengerLanguage = "Spanish"
    @State private var useAutoDetect = false
    @State private var pickupLocation = ""
    @State private var dropoffLocation = ""

    // Language options
    private let languages = [
        "Spanish", "French", "German", "Italian", "Portuguese",
        "Chinese", "Japanese", "Korean", "Arabic", "Russian",
        "Hindi", "Turkish", "Vietnamese", "Thai", "Polish"
    ]

    var body: some View {
        NavigationView {
            Form {
                // Trip Info Section
                Section(header: Text("Trip Information")) {
                    TextField("Trip ID", text: $tripId)
                        .textInputAutocapitalization(.characters)

                    Button(action: generateTripId) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                            Text("Generate Trip ID")
                        }
                    }
                }

                // Driver Section
                Section(header: Text("Driver Information")) {
                    TextField("Driver Name", text: $driverName)
                        .textInputAutocapitalization(.words)

                    Picker("Driver Language", selection: $driverLanguage) {
                        ForEach(["English"] + languages, id: \.self) { language in
                            Text(language).tag(language)
                        }
                    }
                }

                // Passenger Section
                Section(header: Text("Passenger Information")) {
                    TextField("Passenger Name", text: $passengerName)
                        .textInputAutocapitalization(.words)

                    Toggle("Auto-detect Language", isOn: $useAutoDetect)
                        .tint(.blue)

                    if !useAutoDetect {
                        Picker("Passenger Language", selection: $passengerLanguage) {
                            ForEach(languages, id: \.self) { language in
                                Text(language).tag(language)
                            }
                        }
                    } else {
                        HStack {
                            Image(systemName: "wand.and.stars")
                                .foregroundColor(.orange)
                            Text("Language will be auto-detected")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Locations Section
                Section(header: Text("Trip Locations")) {
                    TextField("Pickup Location", text: $pickupLocation)
                        .textInputAutocapitalization(.words)

                    TextField("Dropoff Location", text: $dropoffLocation)
                        .textInputAutocapitalization(.words)
                }

                // Create Button
                Section {
                    Button(action: createTrip) {
                        HStack {
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                            Text("Create Trip")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                    }
                    .listRowBackground(Color.blue)
                    .disabled(!isFormValid)
                    .opacity(isFormValid ? 1.0 : 0.5)
                }
            }
            .navigationTitle("Create New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var isFormValid: Bool {
        !tripId.trimmingCharacters(in: .whitespaces).isEmpty &&
        !driverName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !passengerName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !pickupLocation.trimmingCharacters(in: .whitespaces).isEmpty &&
        !dropoffLocation.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func generateTripId() {
        let randomNumber = Int.random(in: 10000...99999)
        tripId = "TRIP-\(randomNumber)"
    }

    private func createTrip() {
        let newTrip = Trip(
            id: tripId.trimmingCharacters(in: .whitespaces),
            driverName: driverName.trimmingCharacters(in: .whitespaces),
            driverLanguage: driverLanguage,
            passengerName: passengerName.trimmingCharacters(in: .whitespaces),
            passengerLanguage: useAutoDetect ? nil : passengerLanguage,
            pickupLocation: pickupLocation.trimmingCharacters(in: .whitespaces),
            dropoffLocation: dropoffLocation.trimmingCharacters(in: .whitespaces),
            estimatedDuration: "15 min" // Default duration
        )

        createdTrip = newTrip
        dismiss()
    }
}

// MARK: - Preview
#if DEBUG
struct TripCreationView_Previews: PreviewProvider {
    static var previews: some View {
        TripCreationView(createdTrip: .constant(nil))
    }
}
#endif
