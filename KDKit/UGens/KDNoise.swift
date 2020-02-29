import Foundation
import AudioKit

class KDNoise: KDInstrument {

    private(set) var whiteNoise: AKWhiteNoise?
    private(set) var pinkNoise: AKPinkNoise?
    private(set) var brownNoise: AKBrownianNoise?

    enum NoiseType {
        case white
        case pink
        case brown
    }

    /** Type of noise. `.white`, `.pink`, or `.brown`. (Default: .white) */
    var type: NoiseType {
        get { return self._type }
        set (value) {
            self._type = value
            self.connectOscillator()
            self.amplitude = self._amplitude
        }
    }
    private var _type: NoiseType = .white

    /** Noise amplitude. Independent from `self.volume` which is a shortcut for the `AKMixer` `self.output.volume`. */
    var amplitude: Double {
        get { return self._amplitude }
        set (value) {
            self._amplitude = value

            switch self.type {
            case .white:
                self.whiteNoise?.amplitude = value
            case .pink:
                self.pinkNoise?.amplitude = value
            case .brown:
                self.brownNoise?.amplitude = value
            }
        }
    }
    private var _amplitude: Double = 1.0

// //////////////////////////////
// MARK: Init
// //////////////////////////////

    override init() {
        super.init()
        self.setOutput(AKMixer(self.envelope))
        self.adsr = ADSR.defaultLong()
        self.connectOscillator()
    }

    init(_ type: NoiseType) {
        super.init()
        self.type = type
        self.off()
        self.connectOscillator()
    }

    convenience init(type: NoiseType = .white, _ adsr: ADSR = ADSR.defaultLong()) {
        self.init(type)
        self.adsr = adsr
    }

// //////////////////////////////
// MARK: Private
// //////////////////////////////

    private func connectOscillator() {
        switch self.type {
        case .white:
            self.whiteNoise = AKWhiteNoise()
            self.whiteNoise?.rampDuration = 0
            guard self.whiteNoise != nil else { break }
            self.setEnvelope(self.whiteNoise!)
        case .pink:
            self.pinkNoise = AKPinkNoise()
            self.pinkNoise?.rampDuration = 0
            guard self.pinkNoise != nil else { break }
            self.setEnvelope(self.pinkNoise!)
        case .brown:
            self.brownNoise = AKBrownianNoise()
            self.brownNoise?.rampDuration = 0
            guard self.brownNoise != nil else { break }
            self.setEnvelope(self.brownNoise!)
        }
        self.connectToOutput(input: self.envelope)
    }

// //////////////////////////////
// MARK: Play
// //////////////////////////////

    func play() {
        if self.whiteNoise != nil { self.whiteNoise!.play() }
        if self.pinkNoise != nil { self.pinkNoise!.play() }
        if self.brownNoise != nil { self.brownNoise!.play() }

        self.envelope.play()
    }

    func stop() {
        self.off()
    }

    override func off() {
        self.envelope.stop()

        waitFor(duration: self.adsr.r * 8, then: {
            if !self.envelope.isPlaying {
                if self.whiteNoise != nil { self.whiteNoise!.stop() }
                if self.pinkNoise != nil { self.pinkNoise!.stop() }
                if self.brownNoise != nil { self.brownNoise!.stop() }
            }
        })
    }

}
