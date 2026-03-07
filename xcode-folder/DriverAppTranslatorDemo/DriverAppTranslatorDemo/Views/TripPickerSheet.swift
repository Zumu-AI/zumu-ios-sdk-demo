import SwiftUI

struct TripPickerSheet: View {
    @Binding var selectedTrip: Trip?
    @Binding var showingPicker: Bool
    let onCreateNewTapped: () -> Void

    @State private var searchText = ""

    let trips = Trip.samples

    var filteredTrips: [Trip] {
        if searchText.isEmpty { return trips }
        let query = searchText.lowercased()
        return trips.filter {
            ($0.passengerLanguage ?? "auto-detect").lowercased().contains(query) ||
            $0.passengerName.lowercased().contains(query) ||
            $0.pickupLocation.lowercased().contains(query)
        }
    }

    // Group trips by language category for visual clarity
    var groupedTrips: [(String, [Trip])] {
        var groups: [String: [Trip]] = [:]
        for trip in filteredTrips {
            let key = trip.passengerLanguage ?? "Auto-Detect"
            groups[key, default: []].append(trip)
        }
        // Sort: Auto-Detect first, then alphabetical
        return groups.sorted { a, b in
            if a.key == "Auto-Detect" { return true }
            if b.key == "Auto-Detect" { return false }
            return a.key < b.key
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search by language, name, or location...", text: $searchText)
                        .textFieldStyle(.plain)
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(10)
                .background(Color(UIColor.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.vertical, 8)

                // Results count
                Text("\(filteredTrips.count) trips")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    .padding(.bottom, 4)

                List {
                    // Create New Trip
                    Section {
                        Button(action: onCreateNewTapped) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(.white)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Create New Trip")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text("Custom passenger & language")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            .padding(.vertical, 6)
                        }
                        .listRowBackground(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    }

                    // Grouped by language
                    ForEach(groupedTrips, id: \.0) { language, trips in
                        Section(header:
                            HStack(spacing: 6) {
                                languageFlag(language)
                                Text(language.uppercased())
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                Text("(\(trips.count))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        ) {
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
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("Select Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { showingPicker = false }
                }
            }
        }
    }

    func languageFlag(_ language: String) -> Text {
        let flags: [String: String] = [
            "Spanish": "🇪🇸", "Arabic": "🇸🇦", "Chinese": "🇨🇳", "Hindi": "🇮🇳",
            "French": "🇫🇷", "Russian": "🇷🇺", "Georgian": "🇬🇪", "Uzbek": "🇺🇿",
            "Tajik": "🇹🇯", "Persian": "🇮🇷", "Armenian": "🇦🇲", "Azerbaijani": "🇦🇿",
            "Kazakh": "🇰🇿", "Bengali": "🇧🇩", "Urdu": "🇵🇰", "Punjabi": "🇮🇳",
            "Nepali": "🇳🇵", "Gujarati": "🇮🇳", "Telugu": "🇮🇳", "Tamil": "🇮🇳",
            "Pashto": "🇦🇫", "Thai": "🇹🇭", "Vietnamese": "🇻🇳", "Filipino": "🇵🇭",
            "Indonesian": "🇮🇩", "Japanese": "🇯🇵", "Korean": "🇰🇷",
            "German": "🇩🇪", "Portuguese": "🇧🇷", "Italian": "🇮🇹", "Polish": "🇵🇱",
            "Turkish": "🇹🇷", "Ukrainian": "🇺🇦", "Latvian": "🇱🇻", "Lithuanian": "🇱🇹",
            "Czech": "🇨🇿", "Romanian": "🇷🇴", "Greek": "🇬🇷", "Croatian": "🇭🇷",
            "Serbian": "🇷🇸", "Bulgarian": "🇧🇬", "Hungarian": "🇭🇺",
            "Somali": "🇸🇴", "Swahili": "🇰🇪", "Amharic": "🇪🇹", "Hausa": "🇳🇬",
            "Haitian Creole": "🇭🇹", "Hebrew": "🇮🇱",
            "Auto-Detect": "🌐",
        ]
        return Text(flags[language] ?? "🗣")
    }
}

struct TripPickerRow: View {
    let trip: Trip

    var body: some View {
        HStack(spacing: 12) {
            // Language badge — BIG and prominent
            VStack(spacing: 2) {
                Text(trip.passengerLanguage ?? "Auto")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(trip.passengerLanguage != nil ? .blue : .orange)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(width: 70)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(trip.passengerLanguage != nil
                        ? Color.blue.opacity(0.1)
                        : Color.orange.opacity(0.1))
            )

            // Trip details
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.passengerName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                Text("\(trip.pickupLocation) → \(trip.dropoffLocation)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Text(trip.estimatedDuration)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 2)
    }
}
