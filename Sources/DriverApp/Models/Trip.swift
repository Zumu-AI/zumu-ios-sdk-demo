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

// Sample trips for testing - Diverse languages and edge cases
extension Trip {
    static let samples: [Trip] = [
        // European Languages
        Trip(
            passengerName: "María García",
            passengerLanguage: "Spanish",
            pickupLocation: "123 Main St, San Francisco, CA",
            dropoffLocation: "456 Oak Ave, San Francisco, CA",
            estimatedDuration: "15 min"
        ),
        Trip(
            passengerName: "Jean Dupont",
            passengerLanguage: "French",
            pickupLocation: "789 Market St, San Francisco, CA",
            dropoffLocation: "321 Pine St, San Francisco, CA",
            estimatedDuration: "12 min"
        ),
        Trip(
            passengerName: "Hans Müller",
            passengerLanguage: "German",
            pickupLocation: "Brandenburg Gate, Berlin, Germany",
            dropoffLocation: "Berlin Hauptbahnhof, Berlin, Germany",
            estimatedDuration: "18 min"
        ),
        Trip(
            passengerName: "João Silva",
            passengerLanguage: "Portuguese",
            pickupLocation: "Copacabana Beach, Rio de Janeiro, Brazil",
            dropoffLocation: "Christ the Redeemer, Rio de Janeiro, Brazil",
            estimatedDuration: "25 min"
        ),
        Trip(
            passengerName: "Marco Rossi",
            passengerLanguage: "Italian",
            pickupLocation: "Colosseum, Rome, Italy",
            dropoffLocation: "Vatican City, Rome, Italy",
            estimatedDuration: "14 min"
        ),
        Trip(
            passengerName: "Александр Иванов",
            passengerLanguage: "Russian",
            pickupLocation: "Red Square, Moscow, Russia",
            dropoffLocation: "Bolshoi Theatre, Moscow, Russia",
            estimatedDuration: "16 min"
        ),

        // Asian Languages
        Trip(
            passengerName: "田中さくら",
            passengerLanguage: "Japanese",
            pickupLocation: "Shibuya Station, Tokyo, Japan",
            dropoffLocation: "Tokyo Tower, Minato, Tokyo, Japan",
            estimatedDuration: "20 min"
        ),
        Trip(
            passengerName: "김민준",
            passengerLanguage: "Korean",
            pickupLocation: "Incheon International Airport, Incheon, South Korea",
            dropoffLocation: "Gangnam Station, Seoul, South Korea",
            estimatedDuration: "45 min"
        ),
        Trip(
            passengerName: "राज कुमार",
            passengerLanguage: "Hindi",
            pickupLocation: "India Gate, New Delhi, India",
            dropoffLocation: "Qutub Minar, New Delhi, India",
            estimatedDuration: "22 min"
        ),
        Trip(
            passengerName: "สมชาย วงศ์ไทย",
            passengerLanguage: "Thai",
            pickupLocation: "Suvarnabhumi Airport, Bangkok, Thailand",
            dropoffLocation: "Grand Palace, Bangkok, Thailand",
            estimatedDuration: "35 min"
        ),
        Trip(
            passengerName: "Nguyễn Văn An",
            passengerLanguage: "Vietnamese",
            pickupLocation: "Hanoi Old Quarter, Hanoi, Vietnam",
            dropoffLocation: "Ho Chi Minh Mausoleum, Hanoi, Vietnam",
            estimatedDuration: "18 min"
        ),

        // Middle Eastern
        Trip(
            passengerName: "أحمد محمد",
            passengerLanguage: "Arabic",
            pickupLocation: "Dubai Mall, Dubai, UAE",
            dropoffLocation: "Burj Khalifa, Dubai, UAE",
            estimatedDuration: "8 min"
        ),

        // Auto-Detect Scenarios
        Trip(
            passengerName: "李明",
            passengerLanguage: nil, // Chinese auto-detect
            pickupLocation: "Beijing Capital Airport, Beijing, China",
            dropoffLocation: "Forbidden City, Beijing, China",
            estimatedDuration: "42 min"
        ),
        Trip(
            passengerName: "Yuki Tanaka",
            passengerLanguage: nil, // Japanese auto-detect (romanized name)
            pickupLocation: "Narita Airport, Tokyo, Japan",
            dropoffLocation: "Shibuya Crossing, Tokyo, Japan",
            estimatedDuration: "55 min"
        ),

        // Edge Cases
        Trip(
            passengerName: "María del Carmen Fernández-González de la Cruz",
            passengerLanguage: "Spanish",
            pickupLocation: "Madrid-Barajas Airport, Madrid, Spain",
            dropoffLocation: "Plaza Mayor, Madrid, Spain",
            estimatedDuration: "30 min"
        ),
        Trip(
            passengerName: "Li",
            passengerLanguage: "Chinese",
            pickupLocation: "SFO Terminal 1, San Francisco, CA",
            dropoffLocation: "Chinatown, San Francisco, CA",
            estimatedDuration: "25 min"
        ),
        Trip(
            passengerName: "Chen 陈",
            passengerLanguage: nil, // Mixed script auto-detect
            pickupLocation: "Downtown Seattle, WA",
            dropoffLocation: "Space Needle, Seattle, WA",
            estimatedDuration: "10 min"
        ),
        Trip(
            passengerName: "Michał Kowalski",
            passengerLanguage: "Polish",
            pickupLocation: "Warsaw Chopin Airport, Warsaw, Poland",
            dropoffLocation: "Old Town Square, Warsaw, Poland",
            estimatedDuration: "28 min"
        )
    ]
}
