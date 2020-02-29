import Foundation
import AudioKit

class KDSimpleReverb: KDFXUnit {

    private(set) var fx: AKReverb = AKReverb()

    /** Dry/Wet Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5) */
    var dryWetMix: Double {
        get { return self._dryWetMix }
        set (value) {
            self._dryWetMix = value
            self.fx.dryWetMix = value
        }
    }
    private var _dryWetMix: Double = 0.5

// //////////////////////////////
// MARK: Init
// //////////////////////////////

    override init() {
        super.init()
        self.setOutput(AKMixer(self.fx))
        self.connect()
    }

    init(_ dryWetMix: Double) {
        super.init()
        self.connect()
        self.dryWetMix = dryWetMix
    }

    convenience init(dryWetMix: Double) {
        self.init(dryWetMix)
    }

// //////////////////////////////
// MARK: FX
// //////////////////////////////

    private func connect() {
        self.fx = AKReverb(dryWetMix: self.dryWetMix)
        self.connectToOutput(input: self.fx)
    }

    override func chainFrom(input: KDInstrument) {
        self.fx = AKReverb(input.output, dryWetMix: self.dryWetMix)
        self.connectToOutput(input: self.fx)
    }

// //////////////////////////////
// MARK: Play
// //////////////////////////////

    /**
     The `on()` and `off()` functions work as a bypass. They wont' disconnect any outputs or stop signal flow, but simply toggle the bypass for the fx unit.
     */
    func on() {
        self.fx.play()
    }

    /**
     The `on()` and `off()` functions work as a bypass. They wont' disconnect any outputs or stop signal flow, but simply toggle the bypass for the fx unit.
     */
    override func off() {
        self.fx.stop()
    }

    /**
     Shortcut for `on()` and `off()`.
     */
    func bypass(_ bypass: Bool) {
        bypass == true ? self.off() : self.on()
    }

// //////////////////////////////
// MARK: Coder
// //////////////////////////////

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
