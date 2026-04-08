import AVFoundation

/// Synthesizes short, cute notification sounds — zero audio file dependencies.
/// Each sound is a tiny melody made from sine waves with envelope shaping.
enum CuteSound {
    private static var engine: AVAudioEngine?
    private static var playerNode: AVAudioPlayerNode?

    /// Available sound types
    enum Kind: CaseIterable {
        case mew        // soft cat meow
        case boop       // playful boop
        case twinkle    // tiny sparkle
        case bubble     // bubbly pop
        case chirp      // little bird chirp
        case windChime  // gentle wind chime
        case purr       // soft purring
        case droplet    // water droplet
        case xylophone  // xylophone note
        case squeaky    // tiny squeaky toy
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
        case .mew:        return synthMew(sampleRate: sampleRate)
        case .boop:       return synthBoop(sampleRate: sampleRate)
        case .twinkle:    return synthTwinkle(sampleRate: sampleRate)
        case .bubble:     return synthBubble(sampleRate: sampleRate)
        case .chirp:      return synthChirp(sampleRate: sampleRate)
        case .windChime:  return synthWindChime(sampleRate: sampleRate)
        case .purr:       return synthPurr(sampleRate: sampleRate)
        case .droplet:    return synthDroplet(sampleRate: sampleRate)
        case .xylophone:  return synthXylophone(sampleRate: sampleRate)
        case .squeaky:    return synthSqueaky(sampleRate: sampleRate)
        }
    }

    /// Soft descending "mew~" — mimics a gentle cat meow
    private static func synthMew(sampleRate: Double) -> [Float] {
        let duration = 0.50
        let count = Int(sampleRate * duration)
        var buf = [Float](repeating: 0, count: count)

        for i in 0..<count {
            let t = Double(i) / sampleRate
            let progress = t / duration

            // Frequency slides down from ~900Hz to ~450Hz (meow contour)
            let freq = 900 - 450 * progress
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
            if progress < 0.06 {
                env = Float(progress / 0.06)
            } else if progress < 0.5 {
                env = 1.0
            } else {
                env = Float((1.0 - progress) / 0.5)
            }

            buf[i] = wave * env * 0.15
        }
        return buf
    }

    /// Playful "boop!" — short rising tone
    private static func synthBoop(sampleRate: Double) -> [Float] {
        let duration = 0.28
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

    /// Tiny sparkle — two quick high notes
    private static func synthTwinkle(sampleRate: Double) -> [Float] {
        let duration = 0.45
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
        let duration = 0.35
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

    /// Little bird chirp — two rising tweets
    private static func synthChirp(sampleRate: Double) -> [Float] {
        let duration = 0.42
        let count = Int(sampleRate * duration)
        var buf = [Float](repeating: 0, count: count)

        for i in 0..<count {
            let t = Double(i) / sampleRate
            let progress = t / duration

            // Two chirps: first at 0-0.4, second at 0.5-0.9
            let inFirstChirp = progress < 0.4
            let inSecondChirp = progress >= 0.5 && progress < 0.9

            if inFirstChirp || inSecondChirp {
                let chirpProgress = inFirstChirp ? progress / 0.4 : (progress - 0.5) / 0.4
                // Rising frequency for each chirp
                let baseFreq: Double = inFirstChirp ? 2200 : 2600
                let freq = baseFreq + 400 * chirpProgress
                let phase = t * 2 * .pi * freq

                let wave = Float(sin(phase) * 0.5 + sin(phase * 2.01) * 0.15)

                let env: Float
                if chirpProgress < 0.1 {
                    env = Float(chirpProgress / 0.1)
                } else {
                    env = Float(pow(1.0 - chirpProgress, 1.8))
                }

                buf[i] = wave * env * 0.10
            }
        }
        return buf
    }

    /// Gentle wind chime — descending harmonic tones
    private static func synthWindChime(sampleRate: Double) -> [Float] {
        let duration = 0.65
        let count = Int(sampleRate * duration)
        var buf = [Float](repeating: 0, count: count)

        // Three overlapping chime notes
        let notes: [(freq: Double, start: Double, length: Double)] = [
            (1047, 0.0, 0.55),   // C6
            (1319, 0.08, 0.50),  // E6
            (1568, 0.16, 0.45),  // G6
        ]

        for i in 0..<count {
            let t = Double(i) / sampleRate
            var sample: Float = 0

            for note in notes {
                let noteT = t - note.start
                guard noteT >= 0 && noteT < note.length else { continue }
                let noteProgress = noteT / note.length

                let phase = noteT * 2 * .pi * note.freq
                let wave = Float(sin(phase) * 0.4 + sin(phase * 2.0) * 0.12 + sin(phase * 3.0) * 0.05)

                let env: Float
                if noteProgress < 0.03 {
                    env = Float(noteProgress / 0.03)
                } else {
                    env = Float(pow(1.0 - noteProgress, 2.0))
                }

                sample += wave * env * 0.08
            }

            buf[i] = sample
        }
        return buf
    }

    /// Soft purring — low rumbling vibration
    private static func synthPurr(sampleRate: Double) -> [Float] {
        let duration = 0.55
        let count = Int(sampleRate * duration)
        var buf = [Float](repeating: 0, count: count)

        for i in 0..<count {
            let t = Double(i) / sampleRate
            let progress = t / duration

            // Low frequency purr: ~28Hz modulating ~220Hz
            let purrMod = sin(t * 2 * .pi * 28) * 0.5 + 0.5
            let freq = 220.0 + sin(t * 2 * .pi * 3.0) * 15
            let phase = t * 2 * .pi * freq

            let wave = Float(
                sin(phase) * 0.5 * purrMod
              + sin(phase * 1.5) * 0.15 * purrMod
              + sin(phase * 0.5) * 0.2 * purrMod
            )

            // Gentle fade in and out
            let env: Float
            if progress < 0.1 {
                env = Float(progress / 0.1)
            } else if progress < 0.7 {
                env = 1.0
            } else {
                env = Float((1.0 - progress) / 0.3)
            }

            buf[i] = wave * env * 0.13
        }
        return buf
    }

    /// Water droplet — a crisp "plink" with resonance
    private static func synthDroplet(sampleRate: Double) -> [Float] {
        let duration = 0.40
        let count = Int(sampleRate * duration)
        var buf = [Float](repeating: 0, count: count)

        for i in 0..<count {
            let t = Double(i) / sampleRate
            let progress = t / duration

            // High initial frequency that quickly drops (water hitting surface)
            let freq = 1800 * pow(0.15, progress * 2) + 400
            let phase = t * 2 * .pi * freq

            let wave = Float(
                sin(phase) * 0.6
              + sin(phase * 2.0) * 0.1
            )

            // Very fast attack, resonant decay
            let env: Float
            if progress < 0.01 {
                env = Float(progress / 0.01)
            } else {
                env = Float(pow(1.0 - progress, 3.0))
            }

            buf[i] = wave * env * 0.14
        }
        return buf
    }

    /// Xylophone note — bright, clear tone with harmonics
    private static func synthXylophone(sampleRate: Double) -> [Float] {
        let duration = 0.50
        let count = Int(sampleRate * duration)
        var buf = [Float](repeating: 0, count: count)

        for i in 0..<count {
            let t = Double(i) / sampleRate
            let progress = t / duration

            // G5 note (784Hz) with inharmonic overtones typical of xylophone
            let freq = 784.0
            let phase = t * 2 * .pi * freq

            let wave = Float(
                sin(phase) * 0.5
              + sin(phase * 2.76) * 0.18   // inharmonic partial
              + sin(phase * 5.4) * 0.06    // bright partial
            )

            // Quick attack, medium exponential decay
            let env: Float
            if progress < 0.005 {
                env = Float(progress / 0.005)
            } else {
                env = Float(exp(-progress * 5.0))
            }

            buf[i] = wave * env * 0.13
        }
        return buf
    }

    /// Tiny squeaky toy — quick pitch bend up
    private static func synthSqueaky(sampleRate: Double) -> [Float] {
        let duration = 0.30
        let count = Int(sampleRate * duration)
        var buf = [Float](repeating: 0, count: count)

        for i in 0..<count {
            let t = Double(i) / sampleRate
            let progress = t / duration

            // Rapid upward pitch bend (squeaky toy compression)
            let freq = 600 + 1200 * pow(progress, 0.5)
            let phase = t * 2 * .pi * freq

            let wave = Float(
                sin(phase) * 0.55
              + sin(phase * 1.99) * 0.2
              + sin(phase * 3.01) * 0.08
            )

            // Quick attack, bouncy decay
            let env: Float
            if progress < 0.08 {
                env = Float(progress / 0.08)
            } else {
                let decay = pow(1.0 - progress, 1.5)
                let bounce = 1.0 + sin(progress * .pi * 8) * 0.1 * (1.0 - progress)
                env = Float(decay * bounce)
            }

            buf[i] = wave * env * 0.11
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
