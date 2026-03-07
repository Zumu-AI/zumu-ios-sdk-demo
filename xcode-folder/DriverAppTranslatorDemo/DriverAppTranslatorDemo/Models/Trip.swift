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
    let externalDriverId: String?
    let memberId: String?

    init(
        id: String = UUID().uuidString,
        driverName: String = Driver.current.name,
        driverLanguage: String = Driver.current.language,
        passengerName: String,
        passengerLanguage: String? = nil,
        pickupLocation: String,
        dropoffLocation: String,
        estimatedDuration: String = "15 min",
        externalDriverId: String? = nil,
        memberId: String? = nil
    ) {
        self.id = id
        self.driverName = driverName
        self.driverLanguage = driverLanguage
        self.passengerName = passengerName
        self.passengerLanguage = passengerLanguage
        self.pickupLocation = pickupLocation
        self.dropoffLocation = dropoffLocation
        self.estimatedDuration = estimatedDuration
        self.externalDriverId = externalDriverId
        self.memberId = memberId
    }
}

// Comprehensive demo trips — one per language, searchable by language name
// All use NYC locations for realistic rideshare testing
extension Trip {
    static let samples: [Trip] = [
        // ============================================================
        // DEFAULT: Georgian driver with English passenger
        // ============================================================
        Trip(
            driverName: "Georgi",
            driverLanguage: "Georgian",
            passengerName: "Felicia",
            passengerLanguage: "English",
            pickupLocation: "Brighton Beach, Brooklyn",
            dropoffLocation: "Midtown, Manhattan",
            estimatedDuration: "25 min",
            externalDriverId: "DRV-00100",
            memberId: "MBR-00100"
        ),

        // ============================================================
        // AUTO-DETECT (passenger language unknown)
        // ============================================================
        Trip(
            passengerName: "Jessie",
            passengerLanguage: nil,
            pickupLocation: "1510 Ocean Pkwy, Brooklyn",
            dropoffLocation: "116 27th Ave, Brooklyn",
            estimatedDuration: "18 min",
            externalDriverId: "DRV-00123",
            memberId: "MBR-45678"
        ),
        Trip(
            passengerName: "Alex Kim",
            passengerLanguage: nil,
            pickupLocation: "JFK Terminal 4",
            dropoffLocation: "Times Square, Manhattan",
            estimatedDuration: "45 min",
            externalDriverId: "DRV-00124",
            memberId: "MBR-45679"
        ),

        // ============================================================
        // TOP NYC RIDESHARE LANGUAGES
        // ============================================================
        Trip(
            passengerName: "Maria Garcia",
            passengerLanguage: "Spanish",
            pickupLocation: "Washington Heights, Manhattan",
            dropoffLocation: "Jackson Heights, Queens",
            estimatedDuration: "25 min",
            externalDriverId: "DRV-00200",
            memberId: "MBR-10001"
        ),
        Trip(
            passengerName: "Fadi Al-Hassan",
            passengerLanguage: "Arabic",
            pickupLocation: "Bay Ridge, Brooklyn",
            dropoffLocation: "Atlantic Ave, Brooklyn",
            estimatedDuration: "12 min",
            externalDriverId: "DRV-00201",
            memberId: "MBR-10002"
        ),
        Trip(
            passengerName: "Wei Chen",
            passengerLanguage: "Chinese",
            pickupLocation: "Flushing, Queens",
            dropoffLocation: "Chinatown, Manhattan",
            estimatedDuration: "35 min",
            externalDriverId: "DRV-00202",
            memberId: "MBR-10003"
        ),
        Trip(
            passengerName: "Raj Patel",
            passengerLanguage: "Hindi",
            pickupLocation: "Jackson Heights, Queens",
            dropoffLocation: "Midtown, Manhattan",
            estimatedDuration: "20 min",
            externalDriverId: "DRV-00203",
            memberId: "MBR-10004"
        ),
        Trip(
            passengerName: "Jean-Pierre Dupont",
            passengerLanguage: "French",
            pickupLocation: "SoHo, Manhattan",
            dropoffLocation: "Upper East Side, Manhattan",
            estimatedDuration: "15 min",
            externalDriverId: "DRV-00204",
            memberId: "MBR-10005"
        ),
        Trip(
            passengerName: "Aleksandr Ivanov",
            passengerLanguage: "Russian",
            pickupLocation: "Brighton Beach, Brooklyn",
            dropoffLocation: "Sheepshead Bay, Brooklyn",
            estimatedDuration: "8 min",
            externalDriverId: "DRV-00205",
            memberId: "MBR-10006"
        ),

        // ============================================================
        // CAUCASUS & CENTRAL ASIAN (KEY NYC DRIVER LANGUAGES)
        // ============================================================
        Trip(
            passengerName: "Giorgi Beridze",
            passengerLanguage: "Georgian",
            pickupLocation: "Bensonhurst, Brooklyn",
            dropoffLocation: "Sheepshead Bay, Brooklyn",
            estimatedDuration: "10 min",
            externalDriverId: "DRV-00300",
            memberId: "MBR-20001"
        ),
        Trip(
            passengerName: "Ulugbek Karimov",
            passengerLanguage: "Uzbek",
            pickupLocation: "Rego Park, Queens",
            dropoffLocation: "Forest Hills, Queens",
            estimatedDuration: "8 min",
            externalDriverId: "DRV-00301",
            memberId: "MBR-20002"
        ),
        Trip(
            passengerName: "Farrukh Rahimov",
            passengerLanguage: "Tajik",
            pickupLocation: "Kew Gardens, Queens",
            dropoffLocation: "Jamaica, Queens",
            estimatedDuration: "12 min",
            externalDriverId: "DRV-00302",
            memberId: "MBR-20003"
        ),
        Trip(
            passengerName: "Dariush Hosseini",
            passengerLanguage: "Persian",
            pickupLocation: "Great Neck, Long Island",
            dropoffLocation: "Midtown, Manhattan",
            estimatedDuration: "30 min",
            externalDriverId: "DRV-00303",
            memberId: "MBR-20004"
        ),
        Trip(
            passengerName: "Armen Sargsyan",
            passengerLanguage: "Armenian",
            pickupLocation: "Glendale, Queens",
            dropoffLocation: "Downtown Brooklyn",
            estimatedDuration: "22 min",
            externalDriverId: "DRV-00304",
            memberId: "MBR-20005"
        ),
        Trip(
            passengerName: "Eldar Mammadov",
            passengerLanguage: "Azerbaijani",
            pickupLocation: "Forest Hills, Queens",
            dropoffLocation: "Union Square, Manhattan",
            estimatedDuration: "25 min",
            externalDriverId: "DRV-00305",
            memberId: "MBR-20006"
        ),
        Trip(
            passengerName: "Nursultan Bekmuratov",
            passengerLanguage: "Kazakh",
            pickupLocation: "Astoria, Queens",
            dropoffLocation: "LaGuardia Airport",
            estimatedDuration: "15 min",
            externalDriverId: "DRV-00306",
            memberId: "MBR-20007"
        ),

        // ============================================================
        // SOUTH ASIAN
        // ============================================================
        Trip(
            passengerName: "Rahim Uddin",
            passengerLanguage: "Bengali",
            pickupLocation: "Kensington, Brooklyn",
            dropoffLocation: "Midwood, Brooklyn",
            estimatedDuration: "7 min",
            externalDriverId: "DRV-00400",
            memberId: "MBR-30001"
        ),
        Trip(
            passengerName: "Zara Khan",
            passengerLanguage: "Urdu",
            pickupLocation: "Coney Island, Brooklyn",
            dropoffLocation: "Downtown Brooklyn",
            estimatedDuration: "20 min",
            externalDriverId: "DRV-00401",
            memberId: "MBR-30002"
        ),
        Trip(
            passengerName: "Harpreet Singh",
            passengerLanguage: "Punjabi",
            pickupLocation: "Richmond Hill, Queens",
            dropoffLocation: "Penn Station, Manhattan",
            estimatedDuration: "30 min",
            externalDriverId: "DRV-00402",
            memberId: "MBR-30003"
        ),
        Trip(
            passengerName: "Deepak Sharma",
            passengerLanguage: "Nepali",
            pickupLocation: "Woodside, Queens",
            dropoffLocation: "Grand Central, Manhattan",
            estimatedDuration: "18 min",
            externalDriverId: "DRV-00403",
            memberId: "MBR-30004"
        ),
        Trip(
            passengerName: "Jayesh Desai",
            passengerLanguage: "Gujarati",
            pickupLocation: "Edison, NJ",
            dropoffLocation: "Jersey City, NJ",
            estimatedDuration: "22 min",
            externalDriverId: "DRV-00404",
            memberId: "MBR-30005"
        ),
        Trip(
            passengerName: "Lakshmi Venkatesh",
            passengerLanguage: "Telugu",
            pickupLocation: "Jersey City, NJ",
            dropoffLocation: "Newark Airport, NJ",
            estimatedDuration: "20 min",
            externalDriverId: "DRV-00405",
            memberId: "MBR-30006"
        ),
        Trip(
            passengerName: "Priya Murugan",
            passengerLanguage: "Tamil",
            pickupLocation: "Floral Park, Queens",
            dropoffLocation: "JFK Terminal 1",
            estimatedDuration: "15 min",
            externalDriverId: "DRV-00406",
            memberId: "MBR-30007"
        ),
        Trip(
            passengerName: "Abdul Wali",
            passengerLanguage: "Pashto",
            pickupLocation: "Flushing, Queens",
            dropoffLocation: "Astoria, Queens",
            estimatedDuration: "12 min",
            externalDriverId: "DRV-00407",
            memberId: "MBR-30008"
        ),

        // ============================================================
        // SOUTHEAST ASIAN
        // ============================================================
        Trip(
            passengerName: "Somchai Prasert",
            passengerLanguage: "Thai",
            pickupLocation: "Elmhurst, Queens",
            dropoffLocation: "Times Square, Manhattan",
            estimatedDuration: "22 min",
            externalDriverId: "DRV-00500",
            memberId: "MBR-40001"
        ),
        Trip(
            passengerName: "Nguyen Van Minh",
            passengerLanguage: "Vietnamese",
            pickupLocation: "Chinatown, Manhattan",
            dropoffLocation: "Midtown, Manhattan",
            estimatedDuration: "10 min",
            externalDriverId: "DRV-00501",
            memberId: "MBR-40002"
        ),
        Trip(
            passengerName: "Maria Santos",
            passengerLanguage: "Filipino",
            pickupLocation: "Woodside, Queens",
            dropoffLocation: "Midtown, Manhattan",
            estimatedDuration: "18 min",
            externalDriverId: "DRV-00502",
            memberId: "MBR-40003"
        ),
        Trip(
            passengerName: "Budi Santoso",
            passengerLanguage: "Indonesian",
            pickupLocation: "Astoria, Queens",
            dropoffLocation: "Wall Street, Manhattan",
            estimatedDuration: "25 min",
            externalDriverId: "DRV-00503",
            memberId: "MBR-40004"
        ),

        // ============================================================
        // EAST ASIAN
        // ============================================================
        Trip(
            passengerName: "Yuki Tanaka",
            passengerLanguage: "Japanese",
            pickupLocation: "East Village, Manhattan",
            dropoffLocation: "Midtown, Manhattan",
            estimatedDuration: "10 min",
            externalDriverId: "DRV-00600",
            memberId: "MBR-50001"
        ),
        Trip(
            passengerName: "Park Soo-Jin",
            passengerLanguage: "Korean",
            pickupLocation: "Koreatown, Manhattan",
            dropoffLocation: "Flushing, Queens",
            estimatedDuration: "25 min",
            externalDriverId: "DRV-00601",
            memberId: "MBR-50002"
        ),

        // ============================================================
        // EUROPEAN
        // ============================================================
        Trip(
            passengerName: "Hans Mueller",
            passengerLanguage: "German",
            pickupLocation: "Upper West Side, Manhattan",
            dropoffLocation: "Financial District, Manhattan",
            estimatedDuration: "18 min",
            externalDriverId: "DRV-00700",
            memberId: "MBR-60001"
        ),
        Trip(
            passengerName: "Joao Silva",
            passengerLanguage: "Portuguese",
            pickupLocation: "Newark, NJ",
            dropoffLocation: "Manhattan, NY",
            estimatedDuration: "25 min",
            externalDriverId: "DRV-00701",
            memberId: "MBR-60002"
        ),
        Trip(
            passengerName: "Marco Rossi",
            passengerLanguage: "Italian",
            pickupLocation: "Little Italy, Manhattan",
            dropoffLocation: "Brooklyn Heights",
            estimatedDuration: "12 min",
            externalDriverId: "DRV-00702",
            memberId: "MBR-60003"
        ),
        Trip(
            passengerName: "Michal Kowalski",
            passengerLanguage: "Polish",
            pickupLocation: "Greenpoint, Brooklyn",
            dropoffLocation: "Williamsburg, Brooklyn",
            estimatedDuration: "5 min",
            externalDriverId: "DRV-00703",
            memberId: "MBR-60004"
        ),
        Trip(
            passengerName: "Mehmet Yilmaz",
            passengerLanguage: "Turkish",
            pickupLocation: "Paterson, NJ",
            dropoffLocation: "Midtown, Manhattan",
            estimatedDuration: "35 min",
            externalDriverId: "DRV-00704",
            memberId: "MBR-60005"
        ),
        Trip(
            passengerName: "Olena Kovalenko",
            passengerLanguage: "Ukrainian",
            pickupLocation: "East Village, Manhattan",
            dropoffLocation: "Brighton Beach, Brooklyn",
            estimatedDuration: "30 min",
            externalDriverId: "DRV-00705",
            memberId: "MBR-60006"
        ),
        Trip(
            passengerName: "Janis Berzins",
            passengerLanguage: "Latvian",
            pickupLocation: "Prospect Park, Brooklyn",
            dropoffLocation: "DUMBO, Brooklyn",
            estimatedDuration: "12 min",
            externalDriverId: "DRV-00706",
            memberId: "MBR-60007"
        ),
        Trip(
            passengerName: "Vytautas Kazlauskas",
            passengerLanguage: "Lithuanian",
            pickupLocation: "Bushwick, Brooklyn",
            dropoffLocation: "Williamsburg, Brooklyn",
            estimatedDuration: "8 min",
            externalDriverId: "DRV-00707",
            memberId: "MBR-60008"
        ),
        Trip(
            passengerName: "Jan Novak",
            passengerLanguage: "Czech",
            pickupLocation: "Astoria, Queens",
            dropoffLocation: "Midtown, Manhattan",
            estimatedDuration: "18 min",
            externalDriverId: "DRV-00708",
            memberId: "MBR-60009"
        ),
        Trip(
            passengerName: "Ana Popescu",
            passengerLanguage: "Romanian",
            pickupLocation: "Ridgewood, Queens",
            dropoffLocation: "SoHo, Manhattan",
            estimatedDuration: "20 min",
            externalDriverId: "DRV-00709",
            memberId: "MBR-60010"
        ),
        Trip(
            passengerName: "Nikolaos Papadopoulos",
            passengerLanguage: "Greek",
            pickupLocation: "Astoria, Queens",
            dropoffLocation: "Upper East Side, Manhattan",
            estimatedDuration: "15 min",
            externalDriverId: "DRV-00710",
            memberId: "MBR-60011"
        ),
        Trip(
            passengerName: "Ivan Horvat",
            passengerLanguage: "Croatian",
            pickupLocation: "Astoria, Queens",
            dropoffLocation: "Chelsea, Manhattan",
            estimatedDuration: "20 min",
            externalDriverId: "DRV-00711",
            memberId: "MBR-60012"
        ),
        Trip(
            passengerName: "Dragana Petrovic",
            passengerLanguage: "Serbian",
            pickupLocation: "Ridgewood, Queens",
            dropoffLocation: "Tribeca, Manhattan",
            estimatedDuration: "22 min",
            externalDriverId: "DRV-00712",
            memberId: "MBR-60013"
        ),
        Trip(
            passengerName: "Todor Dimitrov",
            passengerLanguage: "Bulgarian",
            pickupLocation: "Bay Ridge, Brooklyn",
            dropoffLocation: "Wall Street, Manhattan",
            estimatedDuration: "25 min",
            externalDriverId: "DRV-00713",
            memberId: "MBR-60014"
        ),
        Trip(
            passengerName: "Szabolcs Nagy",
            passengerLanguage: "Hungarian",
            pickupLocation: "Upper West Side, Manhattan",
            dropoffLocation: "LaGuardia Airport",
            estimatedDuration: "25 min",
            externalDriverId: "DRV-00714",
            memberId: "MBR-60015"
        ),

        // ============================================================
        // AFRICAN
        // ============================================================
        Trip(
            passengerName: "Abdi Mohamed",
            passengerLanguage: "Somali",
            pickupLocation: "Lewiston, Bronx",
            dropoffLocation: "Harlem, Manhattan",
            estimatedDuration: "15 min",
            externalDriverId: "DRV-00800",
            memberId: "MBR-70001"
        ),
        Trip(
            passengerName: "Amara Diallo",
            passengerLanguage: "Swahili",
            pickupLocation: "Harlem, Manhattan",
            dropoffLocation: "Midtown, Manhattan",
            estimatedDuration: "12 min",
            externalDriverId: "DRV-00801",
            memberId: "MBR-70002"
        ),
        Trip(
            passengerName: "Yohannes Tesfaye",
            passengerLanguage: "Amharic",
            pickupLocation: "Bronx, NY",
            dropoffLocation: "Harlem, Manhattan",
            estimatedDuration: "15 min",
            externalDriverId: "DRV-00802",
            memberId: "MBR-70003"
        ),
        Trip(
            passengerName: "Ibrahim Moussa",
            passengerLanguage: "Hausa",
            pickupLocation: "East Harlem, Manhattan",
            dropoffLocation: "Midtown, Manhattan",
            estimatedDuration: "10 min",
            externalDriverId: "DRV-00803",
            memberId: "MBR-70004"
        ),

        // ============================================================
        // CARIBBEAN
        // ============================================================
        Trip(
            passengerName: "Jean-Baptiste Pierre",
            passengerLanguage: "Haitian Creole",
            pickupLocation: "Flatbush, Brooklyn",
            dropoffLocation: "Downtown Brooklyn",
            estimatedDuration: "10 min",
            externalDriverId: "DRV-00900",
            memberId: "MBR-80001"
        ),

        // ============================================================
        // MIDDLE EASTERN
        // ============================================================
        Trip(
            passengerName: "Moshe Levy",
            passengerLanguage: "Hebrew",
            pickupLocation: "Borough Park, Brooklyn",
            dropoffLocation: "Diamond District, Manhattan",
            estimatedDuration: "20 min",
            externalDriverId: "DRV-01000",
            memberId: "MBR-90001"
        ),
    ]
}
