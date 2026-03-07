import Foundation
import SwiftUI

class Driver: ObservableObject {
    @Published var name: String {
        didSet { UserDefaults.standard.set(name, forKey: "driverName") }
    }
    @Published var language: String {
        didSet { UserDefaults.standard.set(language, forKey: "driverLanguage") }
    }
    @Published var vehicleInfo: String {
        didSet { UserDefaults.standard.set(vehicleInfo, forKey: "driverVehicle") }
    }
    let rating: Double = 4.9

    static let shared = Driver()

    private init() {
        self.name = UserDefaults.standard.string(forKey: "driverName") ?? "Peter"
        self.language = UserDefaults.standard.string(forKey: "driverLanguage") ?? "Russian"
        self.vehicleInfo = UserDefaults.standard.string(forKey: "driverVehicle") ?? "Toyota Camry • ABC 123"
    }

    static var current: Driver { shared }

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
