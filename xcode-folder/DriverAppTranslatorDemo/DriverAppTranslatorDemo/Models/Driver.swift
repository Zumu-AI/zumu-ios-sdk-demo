import Foundation
import SwiftUI
import Combine

class Driver: ObservableObject {
    @Published var name: String
    @Published var language: String
    @Published var vehicleInfo: String
    let rating: Double = 4.9

    private var cancellables = Set<AnyCancellable>()

    static let shared = Driver()
    static var current: Driver { shared }

    private init() {
        self.name = UserDefaults.standard.string(forKey: "driverName") ?? "Peter"
        self.language = UserDefaults.standard.string(forKey: "driverLanguage") ?? "Russian"
        self.vehicleInfo = UserDefaults.standard.string(forKey: "driverVehicle") ?? "Toyota Camry • ABC 123"

        // Persist changes to UserDefaults
        $name.sink { UserDefaults.standard.set($0, forKey: "driverName") }.store(in: &cancellables)
        $language.sink { UserDefaults.standard.set($0, forKey: "driverLanguage") }.store(in: &cancellables)
        $vehicleInfo.sink { UserDefaults.standard.set($0, forKey: "driverVehicle") }.store(in: &cancellables)
    }

    func updateProfile(name: String, language: String, vehicleInfo: String) {
        self.name = name
        self.language = language
        self.vehicleInfo = vehicleInfo
    }

    // All 74 languages supported by ElevenLabs eleven_v3
    // Grouped by region — top NYC rideshare driver languages first
    static let availableLanguages = [
        // Top NYC rideshare driver languages
        "English", "Russian", "Spanish", "Arabic", "Chinese", "Hindi", "French",
        "Bengali", "Urdu", "Korean", "Turkish", "Georgian", "Persian",
        "Uzbek", "Tajik", "Haitian Creole",
        // European
        "German", "Portuguese", "Italian", "Polish", "Ukrainian", "Dutch",
        "Greek", "Czech", "Romanian", "Bulgarian", "Croatian", "Serbian",
        "Slovak", "Slovenian", "Hungarian", "Finnish", "Swedish", "Norwegian",
        "Danish", "Latvian", "Lithuanian", "Estonian", "Icelandic",
        "Bosnian", "Macedonian", "Belarusian", "Armenian", "Azerbaijani",
        "Catalan", "Galician", "Welsh", "Irish", "Luxembourgish",
        // South Asian
        "Nepali", "Punjabi", "Gujarati", "Marathi", "Telugu", "Tamil",
        "Kannada", "Malayalam", "Assamese", "Sindhi",
        // Central Asian
        "Kazakh", "Kyrgyz", "Pashto",
        // Southeast Asian
        "Thai", "Vietnamese", "Indonesian", "Malay", "Filipino",
        "Javanese", "Cebuano",
        // East Asian
        "Japanese",
        // African
        "Swahili", "Somali", "Hausa", "Amharic", "Afrikaans", "Lingala",
        // Middle Eastern
        "Hebrew",
    ]
}
