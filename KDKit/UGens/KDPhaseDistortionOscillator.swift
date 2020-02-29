import Foundation
import AudioKit

class KDPhaseDistortionOscillator: KDInstrument {

    private(set) var oscillator: AKPhaseDistortionOscillator = AKPhaseDistortionOscillator()

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

    /** Frequency in Hz. */
    var frequency: Double {
        get { return self._frequency }
        set (value) {
            self._frequency = value
            self.midiNote = MIDINoteNumber(frequency.frequencyToMIDINote())
            self.oscillator.frequency = value
        }
    }
    private var _frequency: Double = 0.0

    /** Sets frequency in Hz for the given midi value. */
    var midiNote: MIDINoteNumber {
        get { return self._midiNote }
        set (value) {
            self._midiNote = value
            self.frequency = midiNote.midiNoteToFrequency()
        }
    }
    private var _midiNote: MIDINoteNumber = 0

    /** Amount of distortion within the range (-1, 1). 0 is no distortion. (Default: 0) */
    var phaseDistortion: Double {
        get { return self._phaseDistortion }
        set (value) {
            self._phaseDistortion = value
            self.oscillator.phaseDistortion = value
        }
    }
    private var _phaseDistortion: Double = 0.0

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

    /** Set distortion within the range (-1, 1). 0 is no distortion. */
    convenience init(waveform: AKTableType = .sine, distortion: Double = 0, _ adsr: ADSR = ADSR.defaultLong()) {
        self.init(waveform)
        self.adsr = adsr
        self.phaseDistortion = distortion
    }

// //////////////////////////////
// MARK: Private
// //////////////////////////////

    private func connect() {
        self.oscillator = AKPhaseDistortionOscillator(waveform: AKTable(self.waveform))
        self.oscillator.rampDuration = self.portamento
        self.setEnvelope(self.oscillator)
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
        self.frequency = frequency
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
