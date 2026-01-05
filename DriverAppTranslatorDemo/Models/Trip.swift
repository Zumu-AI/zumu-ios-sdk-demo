import Foundation

struct Trip: Identifiable {
    let id: String
    let passengerName: String
    let passengerLanguage: String?
    let pickupLocation: String
    let dropoffLocation: String
    let estimatedDuration: String

    init(
        id: String = UUID().uuidString,
        passengerName: String,
        passengerLanguage: String? = nil,
        pickupLocation: String,
        dropoffLocation: String,
        estimatedDuration: String = "15 min"
    ) {
        self.id = id
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
