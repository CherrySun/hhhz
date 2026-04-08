import AVFoundation

/// Synthesizes short, cute notification sounds — zero audio file dependencies.
/// Each sound is a tiny melody made from sine waves with envelope shaping.
enum CuteSound {
    private static var engine: AVAudioEngine?
    private static var playerNode: AVAudioPlayerNode?

    /// Available sound types
    enum Kind: CaseIterable {
        case mew       // soft cat meow
        case boop      // playful boop
        case twinkle   // tiny sparkle
        case bubble    // bubbly pop
    }

    /// Play a random cute sound at gentle volume
    static func playRandom() {
        let kind = Kind.allCases.randomElement()!
        play(kind)
    }

    static func play(_ kind: Kind) {
        let sampleRate: Double = 44100
        let buffer = generateBuffer(kind: kind, sampleRate: sampleRate)
        playBuffer(buffer, sampleRate: sampleRate)
    }

    // MARK: - Synthesis

    private static func generateBuffer(kind: Kind, sampleRate: Double) -> [Float] {
        switch kind {
        case .mew:      return synthMew(sampleRate: sampleRate)
        case .boop:     return synthBoop(sampleRate: sampleRate)
        case .twinkle:  return synthTwinkle(sampleRate: sampleRate)
        case .bubble:   return synthBubble(sampleRate: sampleRate)
        }
    }

    /// Soft descending "mew~" — mimics a gentle cat meow
    private static func synthMew(sampleRate: Double) -> [Float] {
        let duration = 0.35
        let count = Int(sampleRate * duration)
        var buf = [Float](repeating: 0, count: count)

        for i in 0..<count {
            let t = Double(i) / sampleRate
            let progress = t / duration

            // Frequency slides down from ~900Hz to ~500Hz (meow contour)
            let freq = 900 - 400 * progress
            // Add slight vibrato for organic feel
            let vibrato = sin(t * 2 * .pi * 5.5) * 15
            let phase = t * 2 * .pi * (freq + vibrato)

            // Mix fundamental + soft harmonics
            let wave = Float(
                sin(phase) * 0.6
              + sin(phase * 2.02) * 0.2
              + sin(phase * 3.01) * 0.08
            )

            // Envelope: quick attack, sustained, gentle fade
            let env: Float
            if progress < 0.08 {
                env = Float(progress / 0.08)
            } else if progress < 0.6 {
                env = 1.0
            } else {
                env = Float((1.0 - progress) / 0.4)
            }

            buf[i] = wave * env * 0.15  // gentle volume
        }
        return buf
    }

    /// Playful "boop!" — short rising tone
    private static func synthBoop(sampleRate: Double) -> [Float] {
        let duration = 0.18
        let count = Int(sampleRate * duration)
        var buf = [Float](repeating: 0, count: count)

        for i in 0..<count {
            let t = Double(i) / sampleRate
            let progress = t / duration

            // Quick rise from 400 to 800Hz
            let freq = 400 + 400 * progress * progress
            let phase = t * 2 * .pi * freq

            let wave = Float(sin(phase) * 0.7 + sin(phase * 2.0) * 0.2)

            // Snappy envelope
            let env: Float
            if progress < 0.05 {
                env = Float(progress / 0.05)
            } else {
                env = Float(pow(1.0 - progress, 2.0))
            }

            buf[i] = wave * env * 0.14
        }
        return buf
    }

    /// Tiny sparkle ✨ — two quick high notes
    private static func synthTwinkle(sampleRate: Double) -> [Float] {
        let duration = 0.32
        let count = Int(sampleRate * duration)
        var buf = [Float](repeating: 0, count: count)

        for i in 0..<count {
            let t = Double(i) / sampleRate
            let progress = t / duration

            // Two notes: E6 (1319Hz) then G6 (1568Hz)
            let freq: Double = progress < 0.45 ? 1319 : 1568
            let phase = t * 2 * .pi * freq

            let wave = Float(sin(phase) * 0.6 + sin(phase * 2.0) * 0.15)

            // Each note has its own envelope
            let noteProgress: Double
            if progress < 0.45 {
                noteProgress = progress / 0.45
            } else {
                noteProgress = (progress - 0.45) / 0.55
            }

            let env: Float
            if noteProgress < 0.06 {
                env = Float(noteProgress / 0.06)
            } else {
                env = Float(pow(1.0 - noteProgress, 1.5))
            }

            buf[i] = wave * env * 0.11
        }
        return buf
    }

    /// Bubbly pop — a soft low "plop"
    private static func synthBubble(sampleRate: Double) -> [Float] {
        let duration = 0.22
        let count = Int(sampleRate * duration)
        var buf = [Float](repeating: 0, count: count)

        for i in 0..<count {
            let t = Double(i) / sampleRate
            let progress = t / duration

            // Start at 600Hz, drop to 200Hz (bubble pop contour)
            let freq = 600 * pow(0.33, progress)
            let phase = t * 2 * .pi * freq

            let wave = Float(
                sin(phase) * 0.7
              + sin(phase * 1.5) * 0.15
              + sin(phase * 0.5) * 0.1
            )

            // Fast attack, quick decay
            let env: Float
            if progress < 0.03 {
                env = Float(progress / 0.03)
            } else {
                env = Float(pow(1.0 - progress, 2.5))
            }

            buf[i] = wave * env * 0.16
        }
        return buf
    }

    // MARK: - Playback

    private static func playBuffer(_ samples: [Float], sampleRate: Double) {
        let eng = AVAudioEngine()
        let player = AVAudioPlayerNode()
        eng.attach(player)

        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 1)!
        eng.connect(player, to: eng.mainMixerNode, format: format)

        guard let pcmBuffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: AVAudioFrameCount(samples.count)) else { return }
        pcmBuffer.frameLength = AVAudioFrameCount(samples.count)

        if let channelData = pcmBuffer.floatChannelData {
            samples.withUnsafeBufferPointer { src in
                channelData[0].update(from: src.baseAddress!, count: samples.count)
            }
        }

        do {
            try eng.start()
        } catch {
            return
        }

        player.play()
        player.scheduleBuffer(pcmBuffer) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                player.stop()
                eng.stop()
            }
        }

        // Keep references alive until playback completes
        self.engine = eng
        self.playerNode = player
    }
}
