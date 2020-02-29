import UIKit
import AudioKit

typealias Callback = () -> ()
typealias Chord = [MIDINoteNumber]

// //////////////////////////////
// MARK: AudioKit
// //////////////////////////////
/**
 Setup and run AudioKit with array of `AKNode`.
 */
func startAudioKit(withOutputs: [AKNode]) {
    do {
        let mixer = AKMixer(withOutputs)
        AudioKit.output = mixer
        try AudioKit.start()
    } catch {
        AKLog("AudioKit did not start!")
    }
}

/**
 Setup and run AudioKit with `AKMixer`.
 */
func startAudioKit(withMixer: AKMixer) {
    do {
        AudioKit.output = withMixer
        try AudioKit.start()
    } catch {
        AKLog("AudioKit did not start!")
    }
}

/**
 Struct to hold values for ADSR envelope conforming to AudioKit expectations. Attack, Decay, and Release are time values, and Sustain is a normalized gain value.
 */
struct ADSR {
    var a: Double, d: Double, s: Double, r: Double

    init(a: Double = 0.02, d: Double = 0.1, s: Double = 0.85, r: Double = 0.1) {
        self.a = a
        self.d = d
        self.s = s
        self.r = r
    }

    init(_ a: Double = 0.02, _ d: Double = 0.1, _ s: Double = 0.85, _ r: Double = 0.1) {
        self.init(a: a, d: d, s: s, r: r)
    }

    /**
     `return ADSR(a: 0.02, d: 0.1, s: 0.85, r: 0.1)`
     */
    static func defaultShort() -> ADSR {
        return ADSR(a: 0.02, d: 0.1, s: 0.85, r: 0.1)
    }

    /**
     `return ADSR(a: 0.1, d: 0.0, s: 1.0, r: 0.3)`
     */
    static func defaultLong() -> ADSR {
        return ADSR(a: 0.1, d: 0.0, s: 1.0, r: 0.3)
    }
}

struct MIDINoteProperties {
    var frequency: Double
    var velocity: MIDIVelocity

    init(frequency: Double, velocity: MIDIVelocity) {
        self.frequency = frequency
        self.velocity = velocity
    }
}

struct FM {
    var harmonicityRatio: Double,
        modulatorMultiplier: Double,
        modulationIndex: Double

    init(harmonicityRatio: Double = 1.0, modulationIndex: Double = 1.0, modulatorMultiplier: Double = 1.0) {
        self.harmonicityRatio = harmonicityRatio
        self.modulationIndex = modulationIndex
        self.modulatorMultiplier = modulatorMultiplier
    }

    init(_ harmonicityRatio: Double = 1.0, _ modulationIndex: Double = 1.0, _ modulatorMultiplier: Double = 1.0) {
        self.init(harmonicityRatio: harmonicityRatio, modulationIndex: modulationIndex, modulatorMultiplier: modulatorMultiplier)
    }
}

extension Array where Element == MIDINoteNumber {

    mutating func modulate(_ amount: Int) -> [MIDINoteNumber] {
        return self.map({ MIDINoteNumber(Int($0) + amount) })
    }

}

// //////////////////////////////
// MARK: App Utility
// //////////////////////////////

// This extension lets us mimic a stored property on AppDelegate, and allows us to publicly set and get `orientationLock`.
// See KD.restrictTo(orientation:)
extension AppDelegate {
    private static var _orientationLock = UIInterfaceOrientationMask.all

    var orientationLock: UIInterfaceOrientationMask {
        get {
            return AppDelegate._orientationLock
        }
        set(orientation) {
            AppDelegate._orientationLock = orientation
        }
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate._orientationLock
    }
}

struct KD {

    static func getTopViewController() -> UIViewController {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while topController?.presentedViewController != nil {
            topController = topController?.presentedViewController
        }
        return topController!
    }

    /**
     Restrict auto rotate to the passed orientation. Automatically rotates to an appropriate orientation.

     In order to ensure an acceptable orientation is ready when a view controller is loaded, this should be called in `viewDidLoad()`, and other view dependent code in `viewWillAppear(_ animated: Bool)`.

     Example:
     ```
     override func viewDidLoad() {
        super.viewDidLoad()
        KD.restrictTo(orientation: .landscapeLeft)
     }

     override func viewWillAppear(_ animated: Bool) {
        makeViews()
     }
     ```

     Otherwise, view controllers should override `didRotate(from fromInterfaceOrientation: UIInterfaceOrientation)` in order to ensure drawing code occurs *after* the rotation and will use proper geometry.
     */
    static func restrictTo(orientation: UIInterfaceOrientationMask) {
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            let lastOrientation = delegate.orientationLock
            delegate.orientationLock = orientation

            if lastOrientation != orientation {
                switch orientation {
                case .landscape:
                    if lastOrientation == .landscapeLeft || lastOrientation == .landscapeRight { break }
                    rotateTo(orientation: .landscapeLeft)
                case .landscapeLeft:
                    rotateTo(orientation: .landscapeLeft)
                case .landscapeRight:
                    rotateTo(orientation: .landscapeRight)
                case .allButUpsideDown:
                    if lastOrientation == .portraitUpsideDown {
                        rotateTo(orientation: .portrait)
                    }
                case .portraitUpsideDown:
                    rotateTo(orientation: .portraitUpsideDown)
                default:
                    break
                }
            }
        }
    }

    /**
     Rotate the current view controller to the passed orientation.
     */
    static func rotateTo(orientation: UIInterfaceOrientation) {
        UIDevice.current.setValue(orientation.rawValue, forKey: "orientation")
    }

}

// //////////////////////////////
// MARK: GCD
// //////////////////////////////

func waitFor(duration: Double, then: @escaping Callback) {
    DispatchQueue.global(qos: .background).async {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            then()
        }
    }
}

func async(_ function: @escaping Callback) {
    DispatchQueue.global(qos: .background).async {
        DispatchQueue.main.async {
            function()
        }
    }
}

// //////////////////////////////
// MARK: Numbers
// //////////////////////////////

func roundValue(value: Double, places: Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return round(value * divisor) / divisor
}

func roundValue(value: Float, places: Int) -> Float {
    let divisor = pow(10.0, Float(places))
    return round(value * divisor) / divisor
}

func roundValue(value: CGFloat, places: Int) -> CGFloat {
    let divisor = pow(10.0, CGFloat(places))
    return round(value * divisor) / divisor
}

func roundValue(point: CGPoint, places: Int) -> CGPoint {
    let divisor = pow(10.0, CGFloat(places))
    return CGPoint(x: round(point.x * divisor) / divisor, y: round(point.y * divisor) / divisor)
}

func roundValue(_ value: Double, _ places: Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return round(value * divisor) / divisor
}

func roundValue(_ value: Float, _ places: Int) -> Float {
    let divisor = pow(10.0, Float(places))
    return round(value * divisor) / divisor
}

func roundValue(_ value: CGFloat, _ places: Int) -> CGFloat {
    let divisor = pow(10.0, CGFloat(places))
    return round(value * divisor) / divisor
}

func roundValue(_ point: CGPoint, _ places: Int) -> CGPoint {
    let divisor = pow(10.0, CGFloat(places))
    return CGPoint(x: round(point.x * divisor) / divisor, y: round(point.y * divisor) / divisor)
}

// //////////////////////////////

func clip(value: Int, bounds: (Int, Int)) -> Int {
    let (minValue, maxValue) = bounds
    return max(minValue, min(value, maxValue))
}

func clip(value: Double, bounds: (Double, Double)) -> Double {
    let (minValue, maxValue) = bounds
    return max(minValue, min(value, maxValue))
}

func clip(value: Float, bounds: (Float, Float)) -> Float {
    let (minValue, maxValue) = bounds
    return max(minValue, min(value, maxValue))
}

func clip(value: CGFloat, bounds: (CGFloat, CGFloat)) -> CGFloat {
    let (minValue, maxValue) = bounds
    return max(minValue, min(value, maxValue))
}

// //////////////////////////////
func scale(input: Int, inputRange: (Int, Int), outputRange: (Int, Int)) -> Int {
    let (iLo, iHi) = inputRange
    let (oLo, oHi) = outputRange
    return ((input - iLo) / (iHi - iLo)) * ((oHi - oLo)) + oLo
}

func scale(input: Double, inputRange: (Double, Double), outputRange: (Double, Double)) -> Double {
    let (iLo, iHi) = inputRange
    let (oLo, oHi) = outputRange
    return ((input - iLo) / (iHi - iLo)) * ((oHi - oLo)) + oLo
}

func scale(input: Float, inputRange: (Float, Float), outputRange: (Float, Float)) -> Float {
    let (iLo, iHi) = inputRange
    let (oLo, oHi) = outputRange
    return ((input - iLo) / (iHi - iLo)) * ((oHi - oLo)) + oLo
}

func scale(input: CGFloat, inputRange: (CGFloat, CGFloat), outputRange: (CGFloat, CGFloat)) -> CGFloat {
    let (iLo, iHi) = inputRange
    let (oLo, oHi) = outputRange
    return ((input - iLo) / (iHi - iLo)) * ((oHi - oLo)) + oLo
}

// //////////////////////////////
// MARK: View Geometry
// //////////////////////////////
/** Returns `view.bounds.size.width`. */
func vw (_ view: UIView) -> CGFloat {
    return view.bounds.size.width
}

/** Returns `view.bounds.size.height`. */
func vh (_ view: UIView) -> CGFloat {
    return view.bounds.size.height
}

/** Returns `view.frame.origin.x`. */
func vx (_ view: UIView) -> CGFloat {
    return view.frame.origin.x
}

/** Returns `view.frame.origin.y`. */
func vy (_ view: UIView) -> CGFloat {
    return view.frame.origin.y
}

/** Returns the center point of the passed view in relation to its own bounds `x: view.bounds.width / 2, y: view.bounds.height / 2`. */
func vc (_ view: UIView) -> CGPoint {
    return CGPoint(x: view.bounds.size.width / 2, y: view.bounds.size.height / 2)
}

/** Vertically append a view to another. This determines the bottom edge of the upper view and sets the Y coordinate for the appending view. */
func appendView (_ view: UIView, toView: UIView, withMarginY: CGFloat, andIndentX: CGFloat) {
    let frame: CGRect = CGRect(x: toView.bounds.origin.x + andIndentX,
                               y: toView.frame.origin.y + toView.frame.size.height + withMarginY,
                               width: view.frame.size.width,
                               height: view.frame.size.height)
    view.frame = frame
}

// //////////////////////////////
// MARK: Colors
// //////////////////////////////
/**
 Color helper function.

 Returns a `UIColor` for the given rgba values. Accepts values scaled (0-1) or (0-255).
 */
func rgba (_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat) -> UIColor {
    var components: Array<CGFloat> = [r, g, b, a]

    for (index, value) in components.enumerated() {
        if value > 1 {
            components[index] = value / 255.0
        }
    }

    return UIColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])
}

/**
 Color helper function.

 Returns a `UIColor` for the given 6-figure hex value. Accepts strings with or without the "#" prefix.
 */
func hex (_ hex: String) throws -> UIColor {

    enum HexError: Error {
        case mustHaveSixDigits
    }

    var code: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if (code.hasPrefix("#")) {
        code.remove(at: code.startIndex)
    }

    if (code.count != 6) {
        throw HexError.mustHaveSixDigits
    }

    var rgbValue: UInt32 = 0
    Scanner(string: code).scanHexInt32(&rgbValue)

    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

extension UIColor {
    /**
     UIColor extension. Inverts the rgb values and returns a new color.
     */
    func invert () -> UIColor {
        guard var components = self.cgColor.components else { return self }
        for (index, value) in components.enumerated() {
            if index < 3 {
                components[index] = 1.0 - value
            }
        }
        return UIColor(red: components[0], green: components[1], blue: components[2], alpha: components[3])
    }
}

// //////////////////////////////
// MARK: Gestures
// //////////////////////////////
/**
 Struct to hold shadow values for `UIView.layer`. Any `nil` parameters will use the default values as follows:
 ```
 radius = 1.0
 offset = CGSize(width: 1.0, height: 2.0)
 color = KDColor.grey
 opacity = 0.9
 ```
 Defaults are stored as a global value and can be changed.
 */
struct Shadow {
    var radius: CGFloat,
        offset: CGSize,
        color: UIColor,
        opacity: Float

    static var defaults = (radius: CGFloat(1.0),
                           offset: CGSize(width: 1.0, height: 2.0),
                           color: KDColor.grey,
                           opacity: Float(0.9))

    init(radius: CGFloat?, offset: CGSize?, color: UIColor?, opacity: Float?) {
        self.radius = radius != nil ? radius! : Shadow.defaults.radius
        self.offset = offset != nil ? offset! : Shadow.defaults.offset
        self.color = color != nil ? color! : Shadow.defaults.color
        self.opacity = opacity != nil ? opacity! : Shadow.defaults.opacity
    }

    init(radius: CGFloat?, offset: (CGFloat?, CGFloat?), color: UIColor?, opacity: Float?) {
        let (xo, yo) = offset
        let x = xo != nil ? xo! : Shadow.defaults.offset.width
        let y = yo != nil ? yo! : Shadow.defaults.offset.height
        self.init(radius: radius, offset: CGSize(width: x, height: y), color: color, opacity: opacity)
    }

    init(radius: CGFloat?, offset: (CGFloat?, CGFloat?), color: UIColor?) {
        self.init(radius: radius, offset: offset, color: color, opacity: nil)
    }

    init(radius: CGFloat?, offset: (CGFloat?, CGFloat?)) {
        self.init(radius: radius, offset: offset, color: nil, opacity: nil)
    }

    init(radius: CGFloat?) {
        self.init(radius: radius, offset: (nil, nil), color: nil, opacity: nil)
    }

    init(offset: (CGFloat?, CGFloat?)) {
        self.init(radius: nil, offset: offset, color: nil, opacity: nil)
    }

    init() {
        self.init(radius: nil, offset: (nil, nil), color: nil, opacity: nil)
    }
}

// //////////////////////////////
// MARK: Gestures
// //////////////////////////////
extension UIGestureRecognizer {

    // Add a type property. This is set when a KDView gesture calls its callback. This simplifies being able to identify the sender when a view has multiple recognizers.
    enum GestureType {
        case none
        case tap
        case longPress
        case swipe
        case pan
        case pinch
    }

    struct Holder {
        static var type: GestureType = .none
    }

    var type: GestureType {
        get {
            return Holder.type
        }
        set(type) {
            Holder.type = type
        }
    }

}

// //////////////////////////////
// MARK: UIImage
// //////////////////////////////
extension UIImage {
    func resizeImage(_ scale: CGFloat) -> UIImage? {
        return resizeImage(CGSize(width: self.size.width * scale, height: self.size.height * scale))
    }

    func resizeImage(_ newSize: CGSize) -> UIImage? {
        func isSameSize(_ newSize: CGSize) -> Bool {
            return size == newSize
        }

        func scaleImage(_ newSize: CGSize) -> UIImage? {
            func getScaledRect(_ newSize: CGSize) -> CGRect {
                let ratio = max(newSize.width / size.width, newSize.height / size.height)
                let width = size.width * ratio
                let height = size.height * ratio
                return CGRect(x: 0, y: 0, width: width, height: height)
            }

            func _scaleImage(_ scaledRect: CGRect) -> UIImage? {
                UIGraphicsBeginImageContextWithOptions(scaledRect.size, false, 0.0);
                draw(in: scaledRect)
                let image = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
                UIGraphicsEndImageContext()
                return image
            }
            return _scaleImage(getScaledRect(newSize))
        }

        return isSameSize(newSize) ? self : scaleImage(newSize)!
    }
}

// //////////////////////////////
// MARK: Dictionary
// //////////////////////////////
extension Dictionary {
    var stringRepresentation: String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted]) else { return nil }
        return String(data: data, encoding: .ascii)
    }
}

// //////////////////////////////
// MARK: Array
// //////////////////////////////
extension Array {
    var stringRepresentation: String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: []) else { return nil }
        return String(data: data, encoding: .ascii)
    }
}

// //////////////////////////////
// MARK: String
// //////////////////////////////
extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .ascii) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    func convertToArray() -> [String]? {
        if let data = self.data(using: .ascii) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
