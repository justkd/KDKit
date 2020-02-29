import AudioKit

class KDDrip: KDInstrument {

    private(set) var instrument: AKDrip = AKDrip()

    var amplitude: Double {
        get { return self.instrument.amplitude }
        set (value) { self.instrument.amplitude = value }
    }

    var rampDuration: Double {
        get { return self.instrument.rampDuration }
        set (value) { self.instrument.rampDuration = value }
    }

    var intensity: Double {
        get { return self.instrument.intensity }
        set (value) { self.instrument.intensity = value }
    }

    var dampingFactor: Double {
        get { return self.instrument.dampingFactor }
        set (value) { self.instrument.dampingFactor = value }
    }

    var energyReturn: Double {
        get { return self.instrument.energyReturn }
        set (value) { self.instrument.energyReturn = value }
    }

    var mainResonantFrequency: Double {
        get { return self.instrument.mainResonantFrequency }
        set (value) { self.instrument.mainResonantFrequency = value }
    }

    var firstResonantFrequency: Double {
        get { return self.instrument.firstResonantFrequency }
        set (value) { self.instrument.firstResonantFrequency = value }
    }

    var secondResonantFrequency: Double {
        get { return self.instrument.secondResonantFrequency }
        set (value) { self.instrument.secondResonantFrequency = value }
    }

    struct Specs {
        var intensity: Double,
            dampingFactor: Double,
            energyReturn: Double,
            mainResonantFrequency: Double,
            firstResonantFrequency: Double,
            secondResonantFrequency: Double

        init(intensity: Double = 0.5,
             dampingFactor: Double = 0.5,
             energyReturn: Double = 0.5,
             mainResonantFrequency: Double = 350,
             firstResonantFrequency: Double = 550,
             secondResonantFrequency: Double = 800) {

            self.intensity = intensity
            self.dampingFactor = dampingFactor
            self.energyReturn = energyReturn
            self.mainResonantFrequency = mainResonantFrequency
            self.firstResonantFrequency = firstResonantFrequency
            self.secondResonantFrequency = secondResonantFrequency
        }

        static func random() -> KDDrip.Specs {
            return KDDrip.Specs(intensity: Roll.randomDouble() * 1.0,
                                dampingFactor: Roll.randomDouble() * 1.0,
                                energyReturn: Roll.randomDouble() * 0.5,
                                mainResonantFrequency: (Roll.randomDouble() * 300) + 50,
                                firstResonantFrequency: (Roll.randomDouble() * 300) + 250,
                                secondResonantFrequency: (Roll.randomDouble() * 300) + 500)
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

// //////////////////////////////
// MARK: Set
// //////////////////////////////

    func set(_ specs: Specs) {
        self.intensity = specs.intensity
        self.dampingFactor = specs.dampingFactor
        self.energyReturn = specs.energyReturn
        self.mainResonantFrequency = specs.mainResonantFrequency
        self.firstResonantFrequency = specs.firstResonantFrequency
        self.secondResonantFrequency = specs.secondResonantFrequency
    }

// //////////////////////////////
// MARK: Private
// //////////////////////////////

    private func connect() {
        self.instrument = AKDrip()
        self.rampDuration = 0
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
