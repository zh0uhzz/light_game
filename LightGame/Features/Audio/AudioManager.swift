import AVFoundation
import Foundation

final class AudioManager: ObservableObject {
    @Published private(set) var isMuted = false

    private var player: AVAudioPlayer?
    private var clickPlayer: AVAudioPlayer?
    private var cheerPlayer: AVAudioPlayer?

    init() {
        configureSession()
        prepareBGM()
        playIfNeeded()
    }

    func playClick() {
        guard !isMuted else { return }
        clickPlayer?.currentTime = 0
        clickPlayer?.play()
    }

    /// 通关瞬间短欢呼（与 BGM 混播）。
    func playWinCheer() {
        guard !isMuted else { return }
        cheerPlayer?.currentTime = 0
        cheerPlayer?.play()
    }

    func toggleMute() {
        isMuted.toggle()
        playIfNeeded()
    }

    func setMuted(_ muted: Bool) {
        isMuted = muted
        playIfNeeded()
    }

    private func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            // Keep silent if audio session fails.
        }
    }

    private func prepareBGM() {
        let url = Bundle.main.url(forResource: "Soft Cloud Hop", withExtension: "mp3")
            ?? Bundle.main.url(forResource: "bgm_soft_loop", withExtension: "wav")
            ?? Bundle.main.url(forResource: "bgm_soft_loop", withExtension: "mp3")
        guard let url else {
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.volume = 0.2
            player?.prepareToPlay()
        } catch {
            player = nil
        }

        if let clickURL = Bundle.main.url(forResource: "tap_click", withExtension: "wav"),
           let cp = try? AVAudioPlayer(contentsOf: clickURL) {
            cp.volume = 0.45
            cp.prepareToPlay()
            clickPlayer = cp
        }

        if let cheerURL = Bundle.main.url(forResource: "win_cheer", withExtension: "wav"),
           let ch = try? AVAudioPlayer(contentsOf: cheerURL) {
            ch.volume = 0.62
            ch.numberOfLoops = 0
            ch.prepareToPlay()
            cheerPlayer = ch
        }
    }

    private func playIfNeeded() {
        guard let player else { return }
        if isMuted {
            player.pause()
        } else {
            player.play()
        }
    }
}
