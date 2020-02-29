import Foundation
import AudioKit

class KDTimePitch: KDFXUnit {

    private(set) var fx: AKTimePitch = AKTimePitch()

    /** Rate (rate) ranges from 0.03125 to 32.0 (Default: 1.0) */
    var rate: Double {
        get { return self._rate }
        set (value) {
            self._rate = value
            self.fx.rate = value
        }
    }
    private var _rate: Double = 1.0

    /** Pitch (semi-tones) ranges from -24.0 to 24.0 (Default: 0.0) */
    var pitch: Double {
        get { return self._pitch }
        set (value) {
            self._pitch = value
            self.fx.pitch = value
        }
    }
    private var _pitch: Double = 0.0

    /** Overlap (generic) ranges from 3.0 to 32.0 (Default: 8.0) */
    var overlap: Double {
        get { return self._overlap }
        set (value) {
            self._overlap = value
            self.fx.overlap = value
        }
    }
    private var _overlap: Double = 8.0

// //////////////////////////////
// MARK: Init
// //////////////////////////////

    override init() {
        super.init()
        self.setOutput(AKMixer(self.fx))
        self.connect()
    }

    init(rate: Double, pitch: Double) {
        super.init()
        self.connect()
        self.pitch = pitch
        self.rate = rate
    }

    convenience init(rate: Double) {
        self.init(rate: rate, pitch: 0.0)
    }

    convenience init(pitch: Double) {
        self.init(rate: 1.0, pitch: pitch)
    }

// //////////////////////////////
// MARK: FX
// //////////////////////////////

    private func updateParamsForNewFX() {
        self.fx.rate = self.rate
        self.fx.pitch = self.pitch
        self.fx.overlap = self.overlap
    }

    private func connect() {
        self.fx = AKTimePitch()
        self.updateParamsForNewFX()
        self.connectToOutput(input: self.fx)
    }

    override func chainFrom(input: KDInstrument) {
        self.fx = AKTimePitch(input.output)
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
