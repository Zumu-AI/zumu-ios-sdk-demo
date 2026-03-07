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

    @State private var languageSearch = ""

    // Use the full language list from Driver (74 languages)
    private var languages: [String] { Driver.availableLanguages }

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

                    NavigationLink {
                        LanguagePickerView(
                            selectedLanguage: $driverLanguage,
                            title: "Driver Language"
                        )
                    } label: {
                        HStack {
                            Text("Driver Language")
                            Spacer()
                            Text(driverLanguage)
                                .foregroundColor(.secondary)
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
                        NavigationLink {
                            LanguagePickerView(
                                selectedLanguage: $passengerLanguage,
                                title: "Passenger Language"
                            )
                        } label: {
                            HStack {
                                Text("Passenger Language")
                                Spacer()
                                Text(passengerLanguage)
                                    .foregroundColor(.secondary)
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

// MARK: - Searchable Language Picker (reusable)
struct LanguagePickerView: View {
    @Binding var selectedLanguage: String
    let title: String
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""

    var filtered: [String] {
        if search.isEmpty { return Driver.availableLanguages }
        return Driver.availableLanguages.filter {
            $0.localizedCaseInsensitiveContains(search)
        }
    }

    var body: some View {
        List {
            ForEach(filtered, id: \.self) { lang in
                Button(action: {
                    selectedLanguage = lang
                    dismiss()
                }) {
                    HStack {
                        Text(lang)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedLanguage == lang {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
        }
        .searchable(text: $search, prompt: "Search languages...")
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
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
