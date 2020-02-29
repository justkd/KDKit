import AudioKit

class KDMandolin: KDInstrument {

    private(set) var instrument: AKMandolin = AKMandolin()

    enum Direction {
        case down
        case up
        case downUp
        case upDown
    }

    enum Style {
        case normal
        case acid
        case octaveUp
        case largeResonant
        case electric
        case smallDistorted
    }

    var style: Style {
        get { return self._style }
        set (value) {
            self._style = value
            switch value {
            case .normal:
                self.instrument.detach()
                self.envelope.detach()

                let ramp = self.instrument.rampDuration
                self.instrument = AKMandolin()
                self.instrument.rampDuration = ramp

                // Prime the instrument - mandolin seems to automatically play all notes when first making sound
                // This plays the instrument without running the envelope so the initial play doesn't actually sound
                self.chord = self._chord
                self.instrument.pluck(course: 0, position: 0.25, velocity: 0)

                self.setEnvelope(self.instrument)
                self.connectToOutput(input: self.envelope)
            case .acid:
                self.instrument.presetAcidMandolin()
            case .octaveUp:
                self.instrument.presetOctaveUpMandolin()
            case .largeResonant:
                self.instrument.presetLargeResonantMandolin()
            case .electric:
                self.instrument.presetElectricGuitarMandolin()
            case .smallDistorted:
                self.instrument.presetSmallBodiedDistortedMandolin()
            }
        }
    }
    var _style: Style = .normal

    var rampDuration: Double {
        get { return self.instrument.rampDuration }
        set (value) { self.instrument.rampDuration = value }
    }

    var velocity: MIDIVelocity {
        get { return self._velocity }
        set (value) { self._velocity = value }
    }
    private var _velocity: MIDIVelocity = 90

    var position: Double {
        get { return self._position }
        set (value) { self._position = value }
    }
    private var _position: Double = 0.5

    var chord: [MIDINoteNumber] {
        get { return _chord }
        set (value) {
            self._chord = value
            self.instrument.prepareChord(_chord[0], _chord[1], _chord[2], _chord[3])
        }
    }
    private var _chord: [MIDINoteNumber] = [48, 55, 60, 62]

    var duration: Double {
        get { return self._duration }
        set (value) { self._duration = value }
    }
    private var _duration: Double = 0.5

    var arpeggioPattern: [Int] {
        get { return self._arpeggioPattern }
        set (value) { self._arpeggioPattern = value }
    }
    private var _arpeggioPattern: [Int] = [0, 2, 1, 3]

    var strumDirection: Direction {
        get { return self._strumDirection }
        set (value) { self._strumDirection = value }
    }
    private var _strumDirection: Direction = .down

// //////////////////////////////
// MARK: Init
// //////////////////////////////

    override init() {
        super.init()
        self.setOutput(AKMixer(self.envelope))
        self.adsr = ADSR.defaultLong()
        self.connect()
    }

    convenience init(_ style: Style = .normal, _ adsr: ADSR = ADSR.defaultLong()) {
        self.init()
        self.adsr = adsr
        if style != .normal {
            self.style = style
        }
    }

// //////////////////////////////
// MARK: Private
// //////////////////////////////

    private func connect() {
        self.instrument = AKMandolin()
        self.rampDuration = 0

        // Prime the instrument - mandolin seems to automatically play all notes when first making sound
        // This plays the instrument without running the envelope so the initial play doesn't actually sound
        self.chord = [48, 55, 60, 62]
        self.instrument.pluck(course: 0, position: 0.25, velocity: 0)

        self.setEnvelope(self.instrument)
        self.connectToOutput(input: self.envelope)
    }

// //////////////////////////////
// MARK: Play
// //////////////////////////////

    /**
     Play all notes at the same time.

     Passing any parameter will set the corresponding property on this instance.
     */
    func play(_ fourNoteChord: [MIDINoteNumber]? = nil, position: Double? = nil, velocity: MIDIVelocity? = nil) {
        if fourNoteChord != nil {
            if fourNoteChord!.count < 4 { return } else { self.chord = fourNoteChord! }
        }

        if position != nil { self.position = position! }
        if velocity != nil { self.velocity = velocity! }

        let pos = self.position
        let vel = self.velocity

        self.instrument.strum(pos, velocity: vel)
        self.envelope.start()
    }

    /**
     Strum all notes according to the passed `direction`. `duration` represents the total duration for the strum, and each note will be played in order after waiting for `duration / numberOfEvents`. `numberOfEvents` is either `4` or `7` depending on `direction`.

     Passing any parameter will set the corresponding property on this instance.
     */
    func strum(_ fourNoteChord: [MIDINoteNumber]? = nil, duration: Double? = nil, direction: Direction? = nil, position: Double? = nil, velocity: MIDIVelocity? = nil) {

        if fourNoteChord != nil {
            if fourNoteChord!.count < 4 { return } else { self.chord = fourNoteChord! }
        }

        if position != nil { self.position = position! }
        if velocity != nil { self.velocity = velocity! }
        if duration != nil { self.duration = duration! }

        let pos = self.position
        let vel = self.velocity
        let dur = self.duration

        switch self.strumDirection {

        case .down:
            let numEvents = 4
            Score().start({
                self.instrument.pluck(course: 0, position: pos, velocity: vel)
            }).then(after: dur / numEvents, {
                self.instrument.pluck(course: 1, position: pos, velocity: vel)
            }).then(after: dur / numEvents, {
                self.instrument.pluck(course: 2, position: pos, velocity: vel)
            }).then(after: dur / numEvents, {
                self.instrument.pluck(course: 3, position: pos, velocity: vel)
            })

        case .up:
            let numEvents = 4
            Score().start({
                self.instrument.pluck(course: 3, position: pos, velocity: vel)
            }).then(after: dur / numEvents, {
                self.instrument.pluck(course: 2, position: pos, velocity: vel)
            }).then(after: dur / numEvents, {
                self.instrument.pluck(course: 1, position: pos, velocity: vel)
            }).then(after: dur / numEvents, {
                self.instrument.pluck(course: 0, position: pos, velocity: vel)
            })

        case .downUp:
            let numEvents = 7
            Score().start({
                self.instrument.pluck(course: 0, position: pos, velocity: vel)
            }).then(after: dur / numEvents, {
                self.instrument.pluck(course: 1, position: pos, velocity: vel)
            }).then(after: dur / numEvents, {
                self.instrument.pluck(course: 2, position: pos, velocity: vel)
            }).then(after: dur / numEvents, {
                self.instrument.pluck(course: 3, position: pos, velocity: vel)
            }).then(after: dur / numEvents, {
                self.instrument.pluck(course: 2, position: pos, velocity: vel)
            }).then(after: dur / numEvents, {
                self.instrument.pluck(course: 1, position: pos, velocity: vel)
            }).then(after: dur / numEvents, {
                self.instrument.pluck(course: 0, position: pos, velocity: vel)
            })

        case .upDown:
            let numEvents = 7
            Score().start({
                self.instrument.pluck(course: 3, position: pos, velocity: vel)
            }).then(after: dur / numEvents, {
                self.instrument.pluck(course: 2, position: pos, velocity: vel)
            }).then(after: dur / numEvents, {
                self.instrument.pluck(course: 1, position: pos, velocity: vel)
            }).then(after: dur / numEvents, {
                self.instrument.pluck(course: 0, position: pos, velocity: vel)
            }).then(after: dur / numEvents, {
                self.instrument.pluck(course: 1, position: pos, velocity: vel)
            }).then(after: dur / numEvents, {
                self.instrument.pluck(course: 2, position: pos, velocity: vel)
            }).then(after: dur / numEvents, {
                self.instrument.pluck(course: 3, position: pos, velocity: vel)
            })
        }

        self.envelope.start()
    }

    /**
     Arpeggiate all notes according to the passed `pattern`. `duration` represents the total duration for the strum, and each note will be played in order after waiting for `duration / 4`. `pattern` is a four count array describing the order that strings should be played.

     Passing any parameter will set the corresponding property on this instance.
     */
    func arpeggio(_ fourNoteChord: [MIDINoteNumber]? = nil, duration: Double? = nil, pattern: [Int]? = nil, position: Double? = nil, velocity: MIDIVelocity? = nil) {

        if fourNoteChord != nil {
            if fourNoteChord!.count < 4 { return } else { self.chord = fourNoteChord! }
        }

        if position != nil { self.position = position! }
        if velocity != nil { self.velocity = velocity! }
        if duration != nil { self.duration = duration! }
        if pattern != nil { self.arpeggioPattern = pattern! }

        let pos = self.position
        let vel = self.velocity
        let dur = self.duration
        let pat = self.arpeggioPattern

        let numEvents = 4
        Score().start({
            self.instrument.pluck(course: pat[0], position: pos, velocity: vel)
        }).then(after: dur / numEvents, {
            self.instrument.pluck(course: pat[1], position: pos, velocity: vel)
        }).then(after: dur / numEvents, {
            self.instrument.pluck(course: pat[2], position: pos, velocity: vel)
        }).then(after: dur / numEvents, {
            self.instrument.pluck(course: pat[3], position: pos, velocity: vel)
        })

        self.envelope.start()
    }

    /**
     Pluck a single string. The note is determined by the current `self.chord`.

     Passing any parameter will set the corresponding property on this instance.
     */
    func pluck(string: Int, position: Double? = nil, velocity: MIDIVelocity? = nil) {
        let pos = (position != nil ? position : self.position)!
        let vel = (velocity != nil ? velocity : self.velocity)!

        self.instrument.pluck(course: string, position: pos, velocity: vel)
        self.envelope.start()
    }

    /**
     Change the note for a single string. Synonomous with `self.chord[string] = note`.
     */
    func prepare(string: Int, note: MIDINoteNumber) {
        self.chord[string] = note
    }

    /**
     Change the notes for all strings. Synonomous with `self.chord = chord`.
     */
    func prepare(chord: [MIDINoteNumber]) {
        self.chord = chord
    }

    func stop() {
        self.off()
    }

    override func off() {
        self.envelope.stop()
    }

}
