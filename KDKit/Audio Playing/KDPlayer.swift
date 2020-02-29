import AudioKit

class KDPlayer: KDInstrument {

    private(set) var instrument: AKPlayer!
    private(set) var file: String = ""

    /** Determine if the player loops continuously (Default: true) */
    var loop: Bool {
        get { return self._loop }
        set (value) {
            self._loop = value
            self.instrument.isLooping = value
        }
    }
    private var _loop: Bool = true

    // The AKPlayer+Buffering reverseBuffer() doesn't respect the isLooping bool. Unless AK fixes this,
    // you can create a manual loop using Score().on()
    /** Determine if the player reverses the audio (Default: false) */
    var reverse: Bool {
        get { return self._reverse }
        set (value) {
            self._reverse = value
            self.instrument.isReversed = value
        }
    }
    private var _reverse: Bool = false

    /** Set the pan position (Default: 0.0) */
    var pan: Double {
        get { return self._pan }
        set (value) {
            self._pan = value
            self.instrument.pan = value
        }
    }
    private var _pan: Double = 0.0

    /** Completion handler called when the audio file is finished. Only if looping is false. */
    var onDone: (() -> ())? {
        get { return self._onDone }
        set (value) {
            self._onDone = value
            self.instrument.completionHandler = value
        }
    }
    private var _onDone: (() -> ())?

    private var internalURL: AKAudioFile?

// //////////////////////////////
// MARK: Init
// //////////////////////////////

    init(_ file: String) {
        super.init()
        self.setOutput(AKMixer(self.envelope))
        self.adsr = ADSR.defaultLong()
        self.file = file

        self.internalURL = try? AKAudioFile(readFileName: file)
        self.internalURL != nil ? self.connect() : print("KDPlayer: Error locating audio file.")
    }

    convenience init(_ file: String, _ adsr: ADSR = ADSR.defaultLong()) {
        self.init(file)
        self.adsr = adsr
    }

// //////////////////////////////
// MARK: Player
// //////////////////////////////

    private func connect() {
        self.instrument = AKPlayer(audioFile: self.internalURL!)
        self.instrument.isLooping = self.loop
        self.instrument.isReversed = self.reverse
        self.instrument.pan = self.pan
        self.setEnvelope(self.instrument!)
        self.connectToOutput(input: self.envelope)
    }

// //////////////////////////////
// MARK: Play
// //////////////////////////////

    func play() {
        if self.instrument != nil {
            self.instrument!.play()
            self.envelope.start()
        }
    }

    func stop() {
        self.off()
    }

    override func off() {
        self.envelope.stop()
    }

}
