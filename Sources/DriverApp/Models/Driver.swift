import Foundation
import SwiftUI

class Driver: ObservableObject {
    @AppStorage("driverName") @Published var name: String = "John Doe"
    @AppStorage("driverLanguage") @Published var language: String = "English"
    @AppStorage("driverVehicle") @Published var vehicleInfo: String = "Toyota Camry • ABC 123"
    @AppStorage("driverRating") @Published var rating: Double = 4.9

    static let shared = Driver()

    private init() {}

    static let availableLanguages = [
        "English", "Spanish", "French", "German", "Portuguese", "Italian",
        "Russian", "Chinese", "Japanese", "Korean", "Arabic", "Hindi",
        "Thai", "Vietnamese", "Polish", "Dutch", "Turkish", "Greek"
    ]

    func updateProfile(name: String, language: String, vehicleInfo: String) {
        self.name = name
        self.language = language
        self.vehicleInfo = vehicleInfo
    }
}
