import AudioKit

class KDSynthKick: KDInstrument {

    private(set) var instrument: AKSynthKick = AKSynthKick()

    /** Sets frequency in Hz for the given midi value. */
    var midiNote: MIDINoteNumber {
        get { return self._midiNote }
        set (value) {
            self._midiNote = value
        }
    }
    private var _midiNote: MIDINoteNumber = 24

    /** Default MIDI velocity is used when no velocity is passed to `play()`. Passing a velocity to `play()` does not set `self.defaultVelocity`. (Default: 120) */
    var defaultVelocity: MIDIVelocity {
        get { return self._defaultVelocity }
        set (value) {
            self._defaultVelocity = value
        }
    }
    private var _defaultVelocity: MIDIVelocity = 120

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
        self.instrument = AKSynthKick()
        self.setEnvelope(self.instrument)
        self.connectToOutput(input: self.envelope)
    }

// //////////////////////////////
// MARK: Play
// //////////////////////////////

    func play() {
        self.stop()
        self.instrument.play(noteNumber: self.midiNote, velocity: self.defaultVelocity)
        self.envelope.start()
    }

    /**
     Sets `self.midiNote` before playing.
     */
    func play(midiNote: MIDINoteNumber) {
        self.stop()
        self.midiNote = midiNote
        self.instrument.play(noteNumber: self.midiNote, velocity: self.defaultVelocity)
        self.envelope.start()
    }

    /**
     Sets `self.midiNote` before playing. Uses the passed velocity parameter, but does not set `self.defaultVelocity`.
     */
    func play(midiNote: MIDINoteNumber, velocity: MIDIVelocity) {
        self.stop()
        self.midiNote = midiNote
        self.instrument.play(noteNumber: self.midiNote, velocity: velocity)
        self.envelope.start()
    }

    func stop() {
        self.off()
    }

    override func off() {
        self.instrument.stop(noteNumber: self.midiNote)
        self.envelope.stop()
    }

}
