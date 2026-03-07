import SwiftUI

struct DriverEditSheet: View {
    @ObservedObject var driver: Driver
    @Environment(\.dismiss) var dismiss

    @State private var name: String
    @State private var language: String
    @State private var vehicleInfo: String
    @State private var searchText: String = ""

    init(driver: Driver) {
        self.driver = driver
        _name = State(initialValue: driver.name)
        _language = State(initialValue: driver.language)
        _vehicleInfo = State(initialValue: driver.vehicleInfo)
    }

    var filteredLanguages: [String] {
        if searchText.isEmpty {
            return Driver.availableLanguages
        }
        return Driver.availableLanguages.filter {
            $0.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Driver Information") {
                    TextField("Name", text: $name)
                    TextField("Vehicle", text: $vehicleInfo)
                }

                Section("Language (\(Driver.availableLanguages.count) available)") {
                    TextField("Search languages...", text: $searchText)
                        .textFieldStyle(.roundedBorder)

                    ForEach(filteredLanguages, id: \.self) { lang in
                        Button(action: { language = lang }) {
                            HStack {
                                Text(lang)
                                    .foregroundColor(.primary)
                                Spacer()
                                if language == lang {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Driver")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        driver.updateProfile(
                            name: name,
                            language: language,
                            vehicleInfo: vehicleInfo
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
