import SwiftUI

struct TripPickerSheet: View {
    @Binding var selectedTrip: Trip?
    @Binding var showingPicker: Bool
    @State private var searchText = ""

    let trips = Trip.samples

    var filteredTrips: [Trip] {
        if searchText.isEmpty {
            return trips
        }
        return trips.filter {
            $0.passengerName.localizedCaseInsensitiveContains(searchText) ||
            ($0.passengerLanguage?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    var europeanTrips: [Trip] {
        filteredTrips.filter {
            ["Spanish", "French", "German", "Portuguese", "Italian", "Russian", "Polish"]
                .contains($0.passengerLanguage ?? "")
        }
    }

    var asianTrips: [Trip] {
        filteredTrips.filter {
            ["Japanese", "Korean", "Hindi", "Thai", "Vietnamese", "Chinese"]
                .contains($0.passengerLanguage ?? "")
        }
    }

    var middleEasternTrips: [Trip] {
        filteredTrips.filter {
            ["Arabic"].contains($0.passengerLanguage ?? "")
        }
    }

    var edgeCaseTrips: [Trip] {
        filteredTrips.filter { trip in
            trip.passengerLanguage == nil ||
            trip.passengerName.count > 30 ||
            trip.passengerName.count < 3
        }
    }

    var body: some View {
        NavigationView {
            List {
                if !europeanTrips.isEmpty {
                    Section("🇪🇺 European Languages") {
                        ForEach(europeanTrips) { trip in
                            Button(action: {
                                selectedTrip = trip
                                showingPicker = false
                            }) {
                                TripPickerRow(trip: trip)
                            }
                        }
                    }
                }

                if !asianTrips.isEmpty {
                    Section("🌏 Asian Languages") {
                        ForEach(asianTrips) { trip in
                            Button(action: {
                                selectedTrip = trip
                                showingPicker = false
                            }) {
                                TripPickerRow(trip: trip)
                            }
                        }
                    }
                }

                if !middleEasternTrips.isEmpty {
                    Section("🕌 Middle Eastern") {
                        ForEach(middleEasternTrips) { trip in
                            Button(action: {
                                selectedTrip = trip
                                showingPicker = false
                            }) {
                                TripPickerRow(trip: trip)
                            }
                        }
                    }
                }

                if !edgeCaseTrips.isEmpty {
                    Section("🧪 Edge Cases & Auto-Detect") {
                        ForEach(edgeCaseTrips) { trip in
                            Button(action: {
                                selectedTrip = trip
                                showingPicker = false
                            }) {
                                TripPickerRow(trip: trip)
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search by name or language...")
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

    var languageFlag: String {
        guard let language = trip.passengerLanguage else { return "🌐" }
        switch language {
        case "Spanish": return "🇪🇸"
        case "French": return "🇫🇷"
        case "German": return "🇩🇪"
        case "Portuguese": return "🇧🇷"
        case "Italian": return "🇮🇹"
        case "Russian": return "🇷🇺"
        case "Japanese": return "🇯🇵"
        case "Korean": return "🇰🇷"
        case "Hindi": return "🇮🇳"
        case "Thai": return "🇹🇭"
        case "Vietnamese": return "🇻🇳"
        case "Arabic": return "🇦🇪"
        case "Chinese": return "🇨🇳"
        case "Polish": return "🇵🇱"
        default: return "🌍"
        }
    }

    var tripDescription: String? {
        if trip.passengerLanguage == "Arabic" {
            return "Tests RTL text rendering"
        } else if trip.passengerName.count > 30 {
            return "Tests long name handling"
        } else if trip.passengerName.count < 3 {
            return "Tests short name"
        } else if trip.passengerLanguage == nil {
            return "Auto-detect language"
        } else if trip.passengerName.contains(where: { $0.unicodeScalars.first?.properties.isEmoji ?? false }) ||
                  trip.passengerName.contains(where: { !$0.isASCII }) {
            return "Tests native script"
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(languageFlag)
                    .font(.title3)

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
                    HStack(spacing: 4) {
                        Image(systemName: "wand.and.stars")
                            .font(.caption2)
                        Text("Auto")
                    }
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
                }
            }

            if let description = tripDescription {
                Text(description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .italic()
            }

            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption2)
                Text(trip.estimatedDuration)
                    .font(.caption)
                Text("•")
                    .foregroundColor(.secondary)
                Text(trip.dropoffLocation)
                    .font(.caption)
                    .lineLimit(1)
            }
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
