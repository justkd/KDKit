import Foundation
import AudioKit

class KDDelay: KDFXUnit {

    private(set) var fx: AKDelay = AKDelay()

    /** Dry/Wet Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5) */
    var dryWetMix: Double {
        get { return self._dryWetMix }
        set (value) {
            self._dryWetMix = value
            self.fx.dryWetMix = value
        }
    }
    private var _dryWetMix: Double = 0.5

    /** Delay time in seconds (Default: 1) */
    var time: Double {
        get { return self._time }
        set (value) {
            self._time = value
            self.fx.time = value
        }
    }
    private var _time: Double = 1.0

    /** Feedback (Normalized Value) ranges from 0 to 1 (Default: 0.5) */
    var feedback: Double {
        get { return self._feedback }
        set (value) {
            self._feedback = value
            self.fx.feedback = value
        }
    }
    private var _feedback: Double = 0.5

    /** Low pass cut-off frequency in Hertz (Default: 15000) */
    var lowPassCutoff: Double {
        get { return self._lowPassCutoff }
        set (value) {
            self._lowPassCutoff = value
            self.fx.lowPassCutoff = value
        }
    }
    private var _lowPassCutoff: Double = 15000

// //////////////////////////////
// MARK: Init
// //////////////////////////////

    override init() {
        super.init()
        self.setOutput(AKMixer(self.fx))
        self.connect()
    }

    init(_ time: Double) {
        super.init()
        self.connect()
        self.time = time
    }

// //////////////////////////////
// MARK: FX
// //////////////////////////////

    private func updateParamsForNewFX() {
        self.fx.time = self.time
        self.fx.feedback = self.feedback
        self.fx.lowPassCutoff = self.lowPassCutoff
        self.fx.dryWetMix = self.dryWetMix
    }

    private func connect() {
        self.fx = AKDelay()
        self.updateParamsForNewFX()
        self.connectToOutput(input: self.fx)
    }

    override func chainFrom(input: KDInstrument) {
        self.fx = AKDelay(input.output)
        self.updateParamsForNewFX()
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
