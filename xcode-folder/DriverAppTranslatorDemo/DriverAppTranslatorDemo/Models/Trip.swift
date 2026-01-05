import Foundation

struct Trip: Identifiable, Equatable {
    let id: String
    let driverName: String
    let driverLanguage: String
    let passengerName: String
    let passengerLanguage: String?
    let pickupLocation: String
    let dropoffLocation: String
    let estimatedDuration: String

    init(
        id: String = UUID().uuidString,
        driverName: String = Driver.current.name,
        driverLanguage: String = Driver.current.language,
        passengerName: String,
        passengerLanguage: String? = nil,
        pickupLocation: String,
        dropoffLocation: String,
        estimatedDuration: String = "15 min"
    ) {
        self.id = id
        self.driverName = driverName
        self.driverLanguage = driverLanguage
        self.passengerName = passengerName
        self.passengerLanguage = passengerLanguage
        self.pickupLocation = pickupLocation
        self.dropoffLocation = dropoffLocation
        self.estimatedDuration = estimatedDuration
    }
}

// Sample trips for testing
extension Trip {
    static let samples: [Trip] = [
        // Default trip: Peter (Russian driver) with Jessie (autodetect)
        Trip(
            id: "trip-\(UUID().uuidString)",
            passengerName: "Jessie",
            passengerLanguage: nil, // Auto-detect language
            pickupLocation: "1510 Ocean Pkwy",
            dropoffLocation: "116 27th Ave",
            estimatedDuration: "18 min"
        ),
        // Russian driver with Arabic passenger
        Trip(
            id: "trip-\(UUID().uuidString)",
            driverName: "Max",
            driverLanguage: "Russian",
            passengerName: "Fadi",
            passengerLanguage: "Arabic",
            pickupLocation: "116 27th Ave",
            dropoffLocation: "241 37th St",
            estimatedDuration: "12 min"
        ),
        Trip(
            passengerName: "María García",
            passengerLanguage: "Spanish",
            pickupLocation: "123 Main St, San Francisco, CA",
            dropoffLocation: "456 Oak Ave, San Francisco, CA"
        ),
        Trip(
            passengerName: "Jean Dupont",
            passengerLanguage: "French",
            pickupLocation: "789 Market St, San Francisco, CA",
            dropoffLocation: "321 Pine St, San Francisco, CA"
        ),
        Trip(
            passengerName: "李明",
            passengerLanguage: nil, // Test auto-detect
            pickupLocation: "555 Grant Ave, San Francisco, CA",
            dropoffLocation: "888 Broadway, San Francisco, CA"
        )
    ]
}
