import SwiftUI

struct DriverEditSheet: View {
    @ObservedObject var driver: Driver
    @Environment(\.dismiss) var dismiss

    @State private var name: String
    @State private var language: String
    @State private var vehicleInfo: String

    init(driver: Driver) {
        self.driver = driver
        _name = State(initialValue: driver.name)
        _language = State(initialValue: driver.language)
        _vehicleInfo = State(initialValue: driver.vehicleInfo)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Driver Information") {
                    TextField("Name", text: $name)
                    TextField("Vehicle", text: $vehicleInfo)
                }

                Section("Language") {
                    Picker("Spoken Language", selection: $language) {
                        ForEach(Driver.availableLanguages, id: \.self) { lang in
                            Text(lang).tag(lang)
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        driver.updateProfile(name: name, language: language, vehicleInfo: vehicleInfo)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
