import Foundation
import AudioKit

class KDFMOscillator: KDInstrument {

    private(set) var oscillator: AKFMOscillator = AKFMOscillator()

    /** Default `.sine`.
     ```
     .sine
     .triangle
     .square
     .sawtooth
     .reverseSawtooth
     .positiveSine
     .positiveTriangle
     .positiveSquare
     .positiveSawtooth
     .positiveReverseSawtooth
     .zero
     ```
     */
    var waveform: AKTableType {
        get { return self._waveform }
        set (value) {
            self._waveform = value
            self.output.disconnectInput()
            self.connect()
        }
    }
    private var _waveform: AKTableType = .sine

    /** Amplitude of `self.oscillator`. Independent from `self.volume` which is a shortcut for the `AKMixer` `self.output.volume`. */
    var amplitude: Double {
        get { return self._amplitude }
        set (value) {
            self._amplitude = value
            self.oscillator.amplitude = value
        }
    }
    private var _amplitude: Double = 1.0

    /** Glide between frequencies when changing in real time. Sets `.rampDuration` for `self.oscillator` (`AKOscillator`). */
    var portamento: Double {
        get { return self._portamento }
        set (value) {
            self._portamento = value
            self.oscillator.rampDuration = value
        }
    }
    private var _portamento: Double = 0.0

    /** Base frequency in Hz. */
    var baseFrequency: Double {
        get { return self._baseFrequency }
        set (value) {
            self._baseFrequency = value
            self.midiNote = MIDINoteNumber(baseFrequency.frequencyToMIDINote())
            self.oscillator.baseFrequency = value
        }
    }
    private var _baseFrequency: Double = 0.0

    /** Sets base frequency in Hz for the given midi value. */
    var midiNote: MIDINoteNumber {
        get { return self._midiNote }
        set (value) {
            self._midiNote = value
            self.baseFrequency = midiNote.midiNoteToFrequency()
        }
    }
    private var _midiNote: MIDINoteNumber = 0

    /** This multiplied by the baseFrequency gives the carrier frequency. (Default: 2.0) */
    var harmonicityRatio: Double {
        get { return self._harmonicityRatio }
        set (value) {
            self._harmonicityRatio = value
            self.oscillator.carrierMultiplier = value
        }
    }
    private var _harmonicityRatio: Double = 2.0

    /** This multiplied by the modulating frequency gives the modulation amplitude. (Default: 2.0) */
    var modulationIndex: Double {
        get { return self._modulationIndex }
        set (value) {
            self._modulationIndex = value
            self.oscillator.modulationIndex = value
        }
    }
    private var _modulationIndex: Double = 2.0

    /** This multiplied by the baseFrequency gives the modulating frequency. (Default: 1.0) */
    var modulatorMultiplier: Double {
        get { return self._modulatorMultiplier }
        set (value) {
            self._modulatorMultiplier = value
            self.oscillator.modulatingMultiplier = value
        }
    }
    private var _modulatorMultiplier: Double = 1.0

// //////////////////////////////
// MARK: Init
// //////////////////////////////

    override init() {
        super.init()
        self.setOutput(AKMixer(self.envelope))
        self.adsr = ADSR.defaultLong()
        self.connect()
    }

    init(_ waveform: AKTableType) {
        super.init()
        self.waveform = waveform
        self.connect()
    }

    convenience init(waveform: AKTableType = .sine, _ fm: FM = FM(), _ adsr: ADSR = ADSR.defaultLong()) {
        self.init(waveform)
        self.adsr = adsr
        self.setFM(fm)
    }

// //////////////////////////////
// MARK: Set
// //////////////////////////////

    func setFM(_ fm: FM) {
        self.harmonicityRatio = fm.harmonicityRatio
        self.modulationIndex = fm.modulationIndex
        self.modulatorMultiplier = fm.modulatorMultiplier
    }

// //////////////////////////////
// MARK: Private
// //////////////////////////////

    private func connect() {
        self.oscillator = AKFMOscillator(waveform: AKTable(self.waveform))
        self.oscillator.rampDuration = self.portamento
        self.setEnvelope(self.oscillator)

        self.oscillator.carrierMultiplier = 1.0
        self.oscillator.modulatingMultiplier = 1.0
        self.oscillator.modulationIndex = 1.0

        self.connectToOutput(input: self.envelope)
    }

// //////////////////////////////
// MARK: Play
// //////////////////////////////

    func play() {
        if !self.oscillator.isPlaying {
            self.oscillator.play()
        }

        self.envelope.play()
    }

    func play(midiNote: MIDINoteNumber) {
        self.midiNote = midiNote
        self.play()
    }

    func play(frequency: Double) {
        self.baseFrequency = frequency
        self.play()
    }

    func stop() {
        self.off()
    }

    override func off() {
        self.envelope.stop()

        waitFor(duration: self.adsr.r * 8, then: {
            if !self.envelope.isPlaying {
                self.oscillator.stop()
            }
        })
    }

}
