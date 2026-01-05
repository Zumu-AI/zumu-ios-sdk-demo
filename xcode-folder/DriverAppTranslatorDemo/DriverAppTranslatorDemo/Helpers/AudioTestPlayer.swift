import AVFoundation
import Combine
import Foundation

/// Simple audio player for testing audio output
class AudioTestPlayer: ObservableObject {
    @Published var isPlaying = false
    private var audioPlayer: AVAudioPlayer?

    static let shared = AudioTestPlayer()

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Failed to setup audio session: \(error)")
        }
    }

    func playTestAudio() {
        guard let url = Bundle.main.url(forResource: "test_audio", withExtension: "mp3") else {
            print("❌ Test audio file not found")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.delegate = self as? any AVAudioPlayerDelegate
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            isPlaying = true
            print("✅ Playing test audio")
        } catch {
            print("❌ Failed to play audio: \(error)")
        }
    }

    func stopAudio() {
        audioPlayer?.stop()
        isPlaying = false
        print("⏹️ Stopped test audio")
    }
}
