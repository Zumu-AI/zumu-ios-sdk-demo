import Foundation
import Combine
import ZumuTranslator

@MainActor
class TranslatorViewModel: ObservableObject {
    @Published var translator: ZumuTranslator?
    @Published var isSessionActive = false
    @Published var errorMessage: String?
    @Published var currentTrip: Trip?

    private var cancellables = Set<AnyCancellable>()

    init() {
        // Initialize with API key from environment or use demo key
        let apiKey = ProcessInfo.processInfo.environment["ZUMU_API_KEY"] ?? "zumu_iZkF5TngXZs3-HWAVjblozL2sB8H2jPi9sc38JRQvWk"
        self.translator = ZumuTranslator(apiKey: apiKey)

        setupSubscriptions()
    }

    private func setupSubscriptions() {
        guard let translator = translator else { return }

        // Monitor session state
        translator.$state
            .sink { [weak self] state in
                self?.handleStateChange(state)
            }
            .store(in: &cancellables)
    }

    private func handleStateChange(_ state: SessionState) {
        switch state {
        case .idle:
            isSessionActive = false
            errorMessage = nil
        case .connecting:
            errorMessage = nil
        case .active:
            isSessionActive = true
            errorMessage = nil
        case .disconnected:
            isSessionActive = false
            errorMessage = "Connection lost. Attempting to reconnect..."
        case .ending:
            isSessionActive = false
        case .error(let message):
            isSessionActive = false
            errorMessage = message
        }
    }

    func startSession(for trip: Trip, driver: Driver) async {
        guard let translator = translator else {
            errorMessage = "Translator not initialized"
            return
        }

        currentTrip = trip

        let config = SessionConfig(
            driverName: driver.name,
            driverLanguage: driver.language,
            passengerName: trip.passengerName,
            passengerLanguage: trip.passengerLanguage, // nil will trigger auto-detect
            tripId: trip.id,
            pickupLocation: trip.pickupLocation,
            dropoffLocation: trip.dropoffLocation
        )

        do {
            let session = try await translator.startSession(config: config)
            print("✅ Session started successfully: \(session.id)")
        } catch {
            errorMessage = "Failed to start session: \(error.localizedDescription)"
            print("❌ Error starting session: \(error)")
        }
    }

    func endSession() async {
        guard let translator = translator else { return }
        await translator.endSession()
        currentTrip = nil
    }

    func sendMessage(_ text: String) async {
        guard let translator = translator else { return }

        do {
            try await translator.sendMessage(text)
        } catch {
            errorMessage = "Failed to send message: \(error.localizedDescription)"
        }
    }

    func toggleMute() {
        translator?.toggleMute()
    }
}
