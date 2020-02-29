import Foundation
import AudioKit

class KDReverb: KDFXUnit {

    private(set) var fx: AKReverb2 = AKReverb2()

    /** Gain (Decibels) ranges from -20 to 20 (Default: 0) */
    var gain: Double {
        get { return self._gain }
        set (value) {
            self._gain = value
            self.fx.gain = value
        }
    }
    private var _gain: Double = 0.0

    /** Min Delay Time (Secs) ranges from 0.0001 to 1.0 (Default: 0.008) */
    var minDelayTime: Double {
        get { return self._minDelayTime }
        set (value) {
            self._minDelayTime = value
            self.fx.minDelayTime = value
        }
    }
    private var _minDelayTime: Double = 0.008

    /** Max Delay Time (Secs) ranges from 0.0001 to 1.0 (Default: 0.050) */
    var maxDelayTime: Double {
        get { return self._maxDelayTime }
        set (value) {
            self._maxDelayTime = value
            self.fx.maxDelayTime = value
        }
    }
    private var _maxDelayTime: Double = 0.05

    /** Decay Time At0 Hz (Secs) ranges from 0.001 to 20.0 (Default: 1.0) */
    var decayTimeAt0Hz: Double {
        get { return self._decayTimeAt0Hz }
        set (value) {
            self._decayTimeAt0Hz = value
            self.fx.decayTimeAt0Hz = value
        }
    }
    private var _decayTimeAt0Hz: Double = 1.0

    /** Decay Time At Nyquist (Secs) ranges from 0.001 to 20.0 (Default: 0.5) */
    var decayTimeAtNyquist: Double {
        get { return self._decayTimeAtNyquist }
        set (value) {
            self._decayTimeAtNyquist = value
            self.fx.decayTimeAtNyquist = value
        }
    }
    private var _decayTimeAtNyquist: Double = 0.5

    /** Randomize Reflections (Integer) ranges from 1 to 1000 (Default: 1) */
    var randomizeReflections: Double {
        get { return self._randomizeReflections }
        set (value) {
            self._randomizeReflections = value
            self.fx.randomizeReflections = value
        }
    }
    private var _randomizeReflections: Double = 1.0

    /** Dry/Wet Mix (Normalized Value) ranges from 0 to 1 (Default: 0.5) */
    var dryWetMix: Double {
        get { return self._dryWetMix }
        set (value) {
            self._dryWetMix = value
            self.fx.dryWetMix = value
        }
    }
    private var _dryWetMix: Double = 0.5

    /**
     Struct to hold values describing KDReverb properties.

     Gain (Decibels) ranges from -20 to 20 (Default: 0)

     Min Delay Time (Secs) ranges from 0.0001 to 1.0 (Default: 0.008)

     Max Delay Time (Secs) ranges from 0.0001 to 1.0 (Default: 0.050)

     Decay Time At0 Hz (Secs) ranges from 0.001 to 20.0 (Default: 1.0)

     Decay Time At Nyquist (Secs) ranges from 0.001 to 20.0 (Default: 0.5)

     Randomize Reflections (Integer) ranges from 1 to 1000 (Default: 1)

     Dry Wet Mix (CrossFade) ranges from 0 to 1 (Default: 0.5)
     */
    struct Specs {
        var gain: Double
        var minDelayTime: Double
        var maxDelayTime: Double
        var decayTimeAt0Hz: Double
        var decayTimeAtNyquist: Double
        var randomizeReflections: Double
        var dryWetMix: Double

        init(gain: Double = 0, minDelayTime: Double = 0.008, maxDelayTime: Double = 0.05, decayTimeAt0Hz: Double = 1.0, decayTimeAtNyquist: Double = 0.5, randomizeReflections: Double = 1.0, dryWetMix: Double = 0.5) {
            self.gain = gain
            self.minDelayTime = minDelayTime
            self.maxDelayTime = maxDelayTime
            self.decayTimeAt0Hz = decayTimeAt0Hz
            self.decayTimeAtNyquist = decayTimeAtNyquist
            self.randomizeReflections = randomizeReflections
            self.dryWetMix = dryWetMix
        }
    }

// //////////////////////////////
// MARK: Init
// //////////////////////////////

    override init() {
        super.init()
        self.setOutput(AKMixer(self.fx))
        self.connect()
    }

    convenience init(_ specs: Specs) {
        self.init()
        self.setSpecs(specs)
    }

    func setSpecs(_ specs: Specs) {
        self.gain = specs.gain
        self.minDelayTime = specs.minDelayTime
        self.maxDelayTime = specs.maxDelayTime
        self.decayTimeAt0Hz = specs.decayTimeAt0Hz
        self.decayTimeAtNyquist = specs.decayTimeAtNyquist
        self.randomizeReflections = specs.randomizeReflections
        self.dryWetMix = specs.dryWetMix
    }

// //////////////////////////////
// MARK: Oscillator
// //////////////////////////////

    private func connect() {
        self.fx = AKReverb2(dryWetMix: self.dryWetMix, gain: self.gain, minDelayTime: self.minDelayTime, maxDelayTime: self.maxDelayTime, decayTimeAt0Hz: self.decayTimeAt0Hz, decayTimeAtNyquist: self.decayTimeAtNyquist, randomizeReflections: self.randomizeReflections)
        self.connectToOutput(input: self.fx)
    }

    override func chainFrom(input: KDInstrument) {
        self.fx = AKReverb2(input.output, dryWetMix: self.dryWetMix, gain: self.gain, minDelayTime: self.minDelayTime, maxDelayTime: self.maxDelayTime, decayTimeAt0Hz: self.decayTimeAt0Hz, decayTimeAtNyquist: self.decayTimeAtNyquist, randomizeReflections: self.randomizeReflections)
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
