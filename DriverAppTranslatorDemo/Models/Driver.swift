import Foundation

struct Driver {
    let name: String
    let language: String
    let vehicleInfo: String
    let rating: Double

    static let current = Driver(
        name: "John Doe",
        language: "English",
        vehicleInfo: "Toyota Camry • ABC 123",
        rating: 4.9
    )
}
