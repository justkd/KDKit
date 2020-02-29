import Foundation
import AudioKit

class KDInstrument {

    var tag: Int?
    var name: String?

    private(set) var output: AKMixer = AKMixer()
    private(set) var adDuration: Double = 0
    private(set) var adrDuration: Double = 0

    private(set) var envelope: AKAmplitudeEnvelope = AKAmplitudeEnvelope()

    /** Volume of the output `AKMixer`. */
    var volume: Double {
        get { return self._volume }
        set (value) {
            self._volume = value
            self.output.volume = volume
        }
    }
    private var _volume: Double = 1.0

    /** ADSR envelope. */
    var adsr: ADSR {
        get { return self._adsr }
        set (value) {
            self._adsr = value
            self.prepareEnvelopeWithADSR()
            self.setAdDuration()
            self.setAdrDuration()
        }
    }
    private var _adsr: ADSR = ADSR.defaultShort()

// //////////////////////////////
// MARK: Init
// //////////////////////////////
    init() {
        self.setAdDuration()
        self.setAdrDuration()
    }

    convenience init(_ adsr: ADSR) {
        self.init()
        self.adsr = adsr
    }

    convenience init(a: Double, d: Double, s: Double, r: Double) {
        self.init(ADSR(a: a, d: d, s: s, r: r))
    }

// //////////////////////////////
// MARK: Output
// //////////////////////////////

    func detachOutput() {
        self.output.detach()
    }

    func connectToOutput(input: AKNode) {
        //self.output.detach()
        self.output.connect(input: input)
    }

    func setEnvelope(_ node: AKNode) {
        self.envelope = AKAmplitudeEnvelope(node)
        self.envelope.rampDuration = 0
        self.prepareEnvelopeWithADSR()
    }

    func setOutput(_ mixer: AKMixer) {
        self.output = mixer
    }

    func off() {
        // should be overridden in subclasses
        // this should be a master off for the instrument, and should turn off AKNodes after the decay
    }

// //////////////////////////////
// MARK: Set
// //////////////////////////////

    func setADSR(a: Double, d: Double, s: Double, r: Double) {
        self.adsr = ADSR(a: a, d: d, s: s, r: r)
    }

    func setAttackDuration(_ duration: Double) {
        self.adsr.a = duration
        self.envelope.attackDuration = duration
        self.setAdDuration()
        self.setAdrDuration()
    }

    func setDecayDuration(_ duration: Double) {
        self.adsr.d = duration
        self.envelope.decayDuration = duration
        self.setAdDuration()
        self.setAdrDuration()
    }

    func setSustainLevel(_ level: Double) {
        self.adsr.s = level
        self.envelope.sustainLevel = level
    }

    func setReleaseDuration(_ duration: Double) {
        self.adsr.r = duration
        self.envelope.releaseDuration = duration
        self.setAdrDuration()
    }


// //////////////////////////////
// MARK: Private
// //////////////////////////////

    private func prepareEnvelopeWithADSR() {
        self.envelope.attackDuration = self.adsr.a
        self.envelope.decayDuration = self.adsr.d
        self.envelope.sustainLevel = self.adsr.s
        self.envelope.releaseDuration = self.adsr.r
    }

    private func setAdDuration() {
        self.adDuration = self.adsr.a + self.adsr.d
    }

    private func setAdrDuration() {
        self.adrDuration = self.adsr.a + self.adsr.d + self.adsr.r
    }

}
