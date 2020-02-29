import AudioKit

class KDMetalBar: KDInstrument {

    private(set) var instrument: AKMetalBar = AKMetalBar()

    enum BoundaryCondition: Double {
        case clamped = 1
        case pivoting = 2
        case free = 3
    }

    var rampDuration: Double {
        get { return self.instrument.rampDuration }
        set (value) { self.instrument.rampDuration = value }
    }

    /**
     Boundary condition at left end of bar. `.clamped`, `.pivoting`, or `.free`. Default `.clamped`.
     */
    var leftBoundaryCondition: BoundaryCondition {
        get { return KDMetalBar.BoundaryCondition(rawValue: self.instrument.leftBoundaryCondition)! }
        set (value) { self.instrument.leftBoundaryCondition = value.rawValue }
    }

    /**
     Boundary condition at right end of bar. `.clamped`, `.pivoting`, or `.free`. Default `.clamped`.
     */
    var rightBoundaryCondition: BoundaryCondition {
        get { return KDMetalBar.BoundaryCondition(rawValue: self.instrument.rightBoundaryCondition)! }
        set (value) { self.instrument.rightBoundaryCondition = value.rawValue }
    }

    /**
     30db decay time (in seconds). Range `0.0 - 10.0`. Default `3.0`.
     */
    var decayDuration: Double {
        get { return self.instrument.decayDuration }
        set (value) { self.instrument.decayDuration = value }
    }

    /**
     Speed of scanning the output location. Range `0.0 - 100.0`. Default `0.25`.
     */
    var scanSpeed: Double {
        get { return self.instrument.scanSpeed }
        set (value) { self.instrument.scanSpeed = value }
    }

    /**
     Position along bar that strike occurs. Range `0.0 - 1.0`. Default `0.2`.
     */
    var position: Double {
        get { return self.instrument.position }
        set (value) { self.instrument.position = value }
    }

    /**
     Normalized strike velocity. Range `0.0 - 1000.0`. Default `500.0`.
     */
    var strikeVelocity: Double {
        get { return self.instrument.strikeVelocity }
        set (value) { self.instrument.strikeVelocity = value }
    }

    /**
     Spatial width of strike. Range `0.0 - 1.0`. Default `0.05`.
     */
    var strikeWidth: Double {
        get { return self.instrument.strikeWidth }
        set (value) { self.instrument.strikeWidth = value }
    }

    /**
     Tells whether the node is processing (ie. started, playing, or active)
     */
    var isStarted: Bool { get { return self.instrument.isStarted } }

    struct Specs {
        var leftBoundaryCondition: BoundaryCondition,
            rightBoundaryCondition: BoundaryCondition,
            decayDuration: Double,
            scanSpeed: Double,
            position: Double,
            strikeVelocity: Double,
            strikeWidth: Double

        init(leftBoundaryCondition: BoundaryCondition = .clamped,
             rightBoundaryCondition: BoundaryCondition = .clamped,
             decayDuration: Double = 3.0,
             scanSpeed: Double = 0.25,
             position: Double = 0.2,
             strikeVelocity: Double = 500.0,
             strikeWidth: Double = 0.05) {

            self.leftBoundaryCondition = leftBoundaryCondition
            self.rightBoundaryCondition = rightBoundaryCondition
            self.decayDuration = decayDuration
            self.scanSpeed = scanSpeed
            self.position = position
            self.strikeVelocity = strikeVelocity
            self.strikeWidth = strikeWidth
        }

        static func random() -> KDMetalBar.Specs {
            return KDMetalBar.Specs(leftBoundaryCondition: KDMetalBar.BoundaryCondition(rawValue: Double(Roll.D(3)))!,
                                    rightBoundaryCondition: KDMetalBar.BoundaryCondition(rawValue: Double(Roll.D(3)))!,
                                    decayDuration: Roll.randomDouble() * 10,
                                    scanSpeed: Roll.randomDouble() * 100,
                                    position: Roll.randomDouble(),
                                    strikeVelocity: Roll.randomDouble() * 1000,
                                    strikeWidth: Roll.randomDouble())
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
        self.leftBoundaryCondition = specs.leftBoundaryCondition
        self.rightBoundaryCondition = specs.rightBoundaryCondition
        self.decayDuration = specs.decayDuration
        self.scanSpeed = specs.scanSpeed
        self.position = specs.position
        self.strikeVelocity = specs.strikeVelocity
        self.strikeWidth = specs.strikeWidth
    }

// //////////////////////////////
// MARK: Private
// //////////////////////////////

    private func connect() {
        self.instrument = AKMetalBar()
        self.set(Specs(leftBoundaryCondition: .clamped,
                       rightBoundaryCondition: .clamped,
                       decayDuration: 0.1, // 0 - 10
                       scanSpeed: 0.5, // 0 - 100
                       position: 0.5, // 0 - 1
                       strikeVelocity: 20, // 0 - 1000
                       strikeWidth: 0.5)) // 0 - 1
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
