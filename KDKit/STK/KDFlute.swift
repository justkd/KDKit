import AudioKit

class KDFlute: KDInstrument {

    private(set) var instrument: AKFlute = AKFlute()

    /** Amplitude of `self.instrument`. Independent from `self.volume` which is a shortcut for the `AKMixer` `self.output.volume`. */
    var amplitude: Double {
        get { return self._amplitude }
        set (value) {
            self._amplitude = value
            self.instrument.amplitude = value
        }
    }
    private var _amplitude: Double = 1.0

    /** Frequency in Hz. */
    var frequency: Double {
        get { return self._frequency }
        set (value) {
            self._frequency = value
            self.midiNote = MIDINoteNumber(frequency.frequencyToMIDINote())
            self.instrument.frequency = value
        }
    }
    private var _frequency: Double = 0.0

    /** Sets frequency in Hz for the given midi value. */
    var midiNote: MIDINoteNumber {
        get { return self._midiNote }
        set (value) {
            self._midiNote = value
            self._frequency = midiNote.midiNoteToFrequency()
        }
    }
    private var _midiNote: MIDINoteNumber = 0

// //////////////////////////////
// MARK: Init
// //////////////////////////////

    override init() {
        super.init()
        self.setOutput(AKMixer(self.envelope))
        self.adsr = ADSR.defaultShort()
        self.connect()
    }

    convenience init(_ adsr: ADSR = ADSR.defaultShort()) {
        self.init()
        self.adsr = adsr
    }

// //////////////////////////////
// MARK: Private
// //////////////////////////////

    private func connect() {
        self.instrument = AKFlute()
        self.instrument.rampDuration = 0
        self.setEnvelope(self.instrument)
        self.connectToOutput(input: self.envelope)
    }

// //////////////////////////////
// MARK: Play
// //////////////////////////////

    func play() {
        self.instrument.trigger()
        self.envelope.start()
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
    }

}
