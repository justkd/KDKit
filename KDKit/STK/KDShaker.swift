import AudioKit

class KDShaker: KDInstrument {

    private(set) var instrument: AKShaker = AKShaker()
    private(set) var midiNote: MIDINoteNumber = 0

    var amplitude: Double {
        get { return self.instrument.amplitude }
        set (value) { self.instrument.amplitude = value }
    }

//    var rampDuration: Double {
//        get { return self.instrument.rampDuration }
//        set (value) { self.instrument.rampDuration = value }
//    }

    var type: AKShakerType {
        get { return self.instrument.type }
        set (value) { self.instrument.type = value }
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

// //////////////////////////////
// MARK: Get Types
// //////////////////////////////

    public static func printTypes() {
        let types = [
            "maraca",
            "cabasa",
            "sekere",
            "tambourine",
            "sleighBells",
            "bambooChimes",
            "sandPaper",
            "sodaCan",
            "sticks",
            "crunch",
            "bigRocks",
            "littleRocks",
            "nextMug",
            "pennyInMug",
            "nickleInMug",
            "dimeInMug",
            "quarterInMug",
            "francInMug",
            "pesoInMug",
            "guiro",
            "wrench",
            "waterDrops",
            "tunedBambooChimes"
        ]
        print(types)
    }

// //////////////////////////////
// MARK: Private
// //////////////////////////////

    private func connect() {
        self.instrument = AKShaker()
        //self.instrument.rampDuration = 0
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

    func stop() {
        self.off()
    }

    override func off() {
        self.envelope.stop()
    }

}
