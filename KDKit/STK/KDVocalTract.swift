import AudioKit

class KDVocalTract: KDInstrument {

    private(set) var instrument: AKVocalTract = AKVocalTract()

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

    var tonguePosition: Double {
        get { return self.instrument.tonguePosition }
        set (value) { self.instrument.tonguePosition = value }
    }

    var tongueDiameter: Double {
        get { return self.instrument.tongueDiameter }
        set (value) { self.instrument.tongueDiameter = value }
    }

    var tenseness: Double {
        get { return self.instrument.tenseness }
        set (value) { self.instrument.tenseness = value }
    }

    var nasality: Double {
        get { return self.instrument.nasality }
        set (value) { self.instrument.nasality = value }
    }

    var rampDuration: Double {
        get { return self.instrument.rampDuration }
        set (value) { self.instrument.rampDuration = value }
    }

    struct Specs {
        var tonguePosition: Double,
            tongueDiameter: Double,
            tenseness: Double,
            nasality: Double

        init(tonguePosition: Double = 0.25,
             tongueDiameter: Double = 0.2,
             tenseness: Double = 0.88,
             nasality: Double = 0.1) {
            self.tonguePosition = tonguePosition
            self.tongueDiameter = tongueDiameter
            self.tenseness = tenseness
            self.nasality = nasality
        }
    }

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

    convenience init(_ specs: Specs = Specs(), _ adsr: ADSR = ADSR.defaultShort()) {
        self.init()
        self.set(specs)
        self.adsr = adsr
    }

// //////////////////////////////
// MARK: Set
// //////////////////////////////

    func set(_ specs: Specs) {
        self.tongueDiameter = specs.tongueDiameter
        self.tonguePosition = specs.tonguePosition
        self.nasality = specs.nasality
        self.tenseness = specs.tenseness
    }

// //////////////////////////////
// MARK: Private
// //////////////////////////////

    private func connect() {
        self.instrument = AKVocalTract(frequency: self.frequency,
                                       tonguePosition: 0.25,
                                       tongueDiameter: 0.2,
                                       tenseness: 0.88,
                                       nasality: 0.1)
        self.instrument.rampDuration = 0
        self.midiNote = 60
        self.setEnvelope(self.instrument)
        self.connectToOutput(input: self.envelope)
    }

// //////////////////////////////
// MARK: Play
// //////////////////////////////

    func play() {
        self.instrument.start()
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
        self.instrument.stop()
        self.envelope.stop()
    }

}
