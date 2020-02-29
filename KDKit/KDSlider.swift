import UIKit

class KDSlider: KDView {

    var onTouchDown: ((UILongPressGestureRecognizer) -> ())?,
        onTouchChange: ((UILongPressGestureRecognizer) -> ())?,
        onTouchUp: ((UILongPressGestureRecognizer) -> ())?

    var onChange: ((KDSlider) -> ())?,
        onLabelShift: ((KDSlider) -> ())?

    private var lastTouchLoc: CGPoint?

    private(set) var knob: KDImageView,
        knobColor: UIColor = KDColor.greys(6),
        knobSize: CGFloat = 0

    private(set) var track: KDImageView,
        trackColor: UIColor = KDColor.black,
        trackThickness: CGFloat = 0

    private var internalValue: Double = 0

    private(set) var value: Double = 0,
        minValue: Double = 0,
        maxValue: Double = 1,
        position: Double = 0

    private(set) var isVertical: Bool,
        precision: Int = 2

    var animationDuration: Double = 0.1
    var animateKnobPosition: Bool = true

    enum LabelShiftDirection {
        case up
        case down
        case left
        case right
    }

    private(set) var label: KDLabel,
        labelColor: UIColor = KDColor.greys(6),
        labelShiftDirection: LabelShiftDirection = .up,
        labelShiftsDirectionOnTouch: Bool = true,
        labelIsShifted: Bool = false

    // //////////////////////////////
    // MARK: Init
    // //////////////////////////////

    override init(frame: CGRect) {

        self.isVertical = frame.size.width < frame.size.height
        let a = !self.isVertical ? 0 : frame.size.width / 2,
            b = !self.isVertical ? frame.size.height / 2 : 0
        let roundness = !self.isVertical ? b : a

        self.labelShiftDirection = !self.isVertical ? .up : .left

        self.knob = KDImageView(frame: CGRect.zero)
        self.track = KDImageView(frame: CGRect.zero)
        self.label = KDLabel(frame: CGRect.zero)

        /* ******************* */
        super.init(frame: frame)

        self.trackThickness = !self.isVertical ? frame.size.height : frame.size.width
        let trackRect = !self.isVertical ? CGRect(x: 0, y: 0, width: frame.size.width, height: self.trackThickness) : CGRect(x: 0, y: 0, width: self.trackThickness, height: frame.size.height)
        self.track = KDImageView(frame: trackRect)
        self.track.setBackgroundColor(self.trackColor)
            .setRoundness(roundness)
        self.track.addToSuperview(self)
        self.track.centerOnParent()

        self.knobSize = (!self.isVertical ? self.track.frame.size.height : self.track.frame.size.width) * 1.75
        self.knobSize = self.knobSize < 25 ? 25 : self.knobSize
        self.knob = KDImageView(frame: CGRect(x: 0, y: 0, width: self.knobSize, height: self.knobSize))
        self.knob.addToSuperview(self)
        self.setKnobSize(self.knobSize)

        let labelFrame = CGRect(x: 0, y: 0, width: vw(self.knob), height: vh(self.knob) / 2)
        self.label = KDLabel(frame: labelFrame, font: UIFont.systemFont(ofSize: 12), text: "", .center)
        self.label.setBackgroundColor(self.knobColor)
        self.label.layer.cornerRadius = vh(self.label) / 2
        self.label.layer.masksToBounds = true

        //self.setRoundness(roundness)

        self.useHiddenTouch = true
        let lp = UILongPressGestureRecognizer(target: self, action: #selector(didHiddenLongPress(sender:)))
        lp.minimumPressDuration = 0
        self.addGestureRecognizer(lp)

        self.onHiddenTouch = { this in

            if this.gestureRecognizer?.type == .longPress {

                guard let sender = this.gestureRecognizer as! UILongPressGestureRecognizer? else { return }
                let loc = sender.location(in: self)
                let position = !self.isVertical ? clip(value: loc.x, bounds: (0, vw(self))) : clip(value: loc.y, bounds: (0, vh(self)))

                if sender.state == .began {
                    self.lastTouchLoc = sender.location(in: self)
                    self.onTouchDown?(sender)
                    self.moveKnobAndUpdateValue(position)
                    self.shiftLabel(reset: false)
                }

                if sender.state == .changed {
                    if sender.location(in: self) != self.lastTouchLoc {
                        self.lastTouchLoc = sender.location(in: self)
                        self.onTouchChange?(sender)
                        self.moveKnobAndUpdateValue(position)
                    }
                }

                if sender.state == .ended || sender.state == .cancelled {
                    self.onTouchUp?(sender)
                    self.shiftLabel(reset: true)
                }
            }

        }

        guard let font = UIFont(name: KDFont.headerFontName, size: self.knobSize / 3) else { return }
        self.label.setFont(font)
            .setText("\(self.value)")
            .setTextColor(KDColor.white)

        self.label.addToSuperview(self.knob)
            .centerOnParent()
    }

    // //////////////////////////////
    // MARK: Convenience Init
    // //////////////////////////////

    private func handleTrackThickness(_ thickness: CGFloat?) {
        if thickness != nil {
            self.setTrackThickness(thickness!)

            var ks = self.trackThickness * 1.75
            ks = ks < 25 ? 25 : ks
            self.setKnobSize(ks)
        }
    }

    convenience init(frame: CGRect, trackThickness: CGFloat? = nil, initialValue: Double? = nil, range: (Double, Double)? = nil, animateInitialKnobPosition: Bool? = true) {
        self.init(frame: frame)
        self.animateKnobPosition = animateInitialKnobPosition != nil ? animateInitialKnobPosition! : false
        if range != nil {
            self.setRange(to: range!)
        }
        if initialValue != nil {
            self.setTo(value: initialValue!)
        }
        self.animateKnobPosition = true

        self.handleTrackThickness(trackThickness)
    }

    convenience init(frame: CGRect, trackColor: UIColor, knobColor: UIColor, trackThickness: CGFloat? = nil, initialValue: Double? = nil, range: (Double, Double)? = nil, animateInitialKnobPosition: Bool? = true) {
        self.init(frame: frame, trackThickness: trackThickness, initialValue: initialValue, range: range, animateInitialKnobPosition: animateInitialKnobPosition)
        self.setKnobColor(knobColor)
        self.setLabelColor(knobColor)
        self.setTrackColor(trackColor)

        self.handleTrackThickness(trackThickness)
    }

    convenience init(frame: CGRect, colorTheme: KDColorTheme, trackThickness: CGFloat? = nil, initialValue: Double? = nil, range: (Double, Double)? = nil, animateInitialKnobPosition: Bool? = true) {
        self.init(frame: frame, trackThickness: trackThickness, initialValue: initialValue, range: range, animateInitialKnobPosition: animateInitialKnobPosition)
        self.setColorTheme(colorTheme)

        self.handleTrackThickness(trackThickness)
    }

    // //////////////////////////////
    // MARK: Value
    // //////////////////////////////

    @discardableResult func setPrecisionTo(_ precision: Int) -> KDSlider {
        self.precision = precision
        self.updateValueAndLabel()
        return self
    }

    @discardableResult func setTo(position: Double) -> KDSlider {
        let max = Double(!self.isVertical ? vw(self) : vh(self))
        let pos = clip(value: position, bounds: (0.0, max))
        self.moveKnobAndUpdateValue(CGFloat(pos))
        return self
    }

    @discardableResult func setTo(value: Double) -> KDSlider {
        let temp = scale(input: value, inputRange: (self.minValue, self.maxValue), outputRange: (0, 1))
        let value = !self.isVertical ? temp * Double(vw(self)) : temp * Double(vh(self))
        self.setTo(position: value)
        return self
    }

    @discardableResult func setMinValue(to: Double) -> KDSlider {
        self.minValue = to
        self.moveKnobAndUpdateValue(CGFloat(self.position))
        return self
    }

    @discardableResult func setMaxValue(to: Double) -> KDSlider {
        self.maxValue = to
        self.moveKnobAndUpdateValue(CGFloat(self.position))
        return self
    }

    @discardableResult func setRange(to: (Double, Double)) -> KDSlider {
        let (low, high) = to
        self.minValue = low
        self.maxValue = high
        self.moveKnobAndUpdateValue(CGFloat(self.position))
        return self
    }

    // //////////////////////////////
    // MARK: Knob Style
    // //////////////////////////////

    @discardableResult func setKnobSize(_ size: CGFloat) -> KDSlider {
        self.knobSize = size
        self.knob.setSize(size, size)
        let center = self.getKnobCenter()
        self.knob.setCenter(center.x, center.y)
            .setBackgroundColor(self.knobColor)
            .setRoundness(self.knobSize / 2)
        self.updateLabelToFitKnob()
        return self
    }

    @discardableResult func setKnobColor(_ color: UIColor) -> KDSlider {
        self.knobColor = color
        self.knob.setBackgroundColor(color)
        return self
    }

    @discardableResult func setKnobImage(_ image: String) -> KDSlider {
        self.knob.setImage(image)
        return self
    }

    @discardableResult func setKnobImageScale(_ scale: CGFloat) -> KDSlider {
        self.knob.setImageScaleMode(.center)
        guard let image = self.knob.image else { return self }
        guard let img = image.resizeImage(CGSize(width: vw(self.knob) * scale, height: vh(self.knob) * scale)) else { return self }
        self.knob.image = img
        return self
    }

    // //////////////////////////////
    // MARK: Track Style
    // //////////////////////////////

    @discardableResult func setTrackThickness(_ size: CGFloat) -> KDSlider {
        self.trackThickness = size
        if !self.isVertical {
            self.track.setHeight(size)
            self.track.setRoundness(self.track.frame.size.height / 2)
            self.track.setCenterY(vc(self).y)
        } else {
            self.track.setWidth(size)
            self.track.setRoundness(self.track.frame.size.width / 2)
            self.track.setCenterX(vc(self).x)
        }
        return self
    }

    @discardableResult func setTrackColor(_ color: UIColor) -> KDSlider {
        self.trackColor = color
        self.track.setBackgroundColor(color)
        return self
    }

    @discardableResult func setTrackImage(_ image: String) -> KDSlider {
        self.track.layer.masksToBounds = true
        self.track.setImageScaleMode(.scaleToFill)
        self.track.setImage(image)
        return self
    }

    // //////////////////////////////
    // MARK: Label
    // //////////////////////////////

    @discardableResult func setLabelColor(_ color: UIColor) -> KDSlider {
        self.labelColor = color
        self.label.setBackgroundColor(color)
        return self
    }

    @discardableResult func setTextColor(_ color: UIColor) -> KDSlider {
        self.label.setTextColor(color)
        return self
    }

    @discardableResult func setLabelShiftDirection(_ direction: LabelShiftDirection) -> KDSlider {
        self.labelShiftDirection = direction
        return self
    }

    @discardableResult func setLabelShiftsDirectionOnTouch(_ shift: Bool) -> KDSlider {
        self.labelShiftsDirectionOnTouch = shift
        return self
    }

    @discardableResult func setLabelIsHidden(_ hidden: Bool) -> KDSlider {
        self.label.isHidden = hidden
        return self
    }

    // //////////////////////////////
    // MARK: Private Functions
    // //////////////////////////////

    private func shiftLabel(reset: Bool) {
        if self.labelShiftsDirectionOnTouch {
            let label = Animate(self.label)
            label.setDuration(0.2)
                .setOptions([.curveEaseInOut])
                .setSpring(0.45, 0.03)

            if !reset {

                var x: CGFloat = 0,
                    y: CGFloat = 0
                let mult: CGFloat = 1.1

                switch self.labelShiftDirection {
                case .up:
                    y = -(!self.isVertical ? self.knob.frame.size.height : self.knob.frame.size.width) * mult
                case .down:
                    y = (!self.isVertical ? self.knob.frame.size.height : self.knob.frame.size.width) * mult
                case .left:
                    x = -(!self.isVertical ? self.knob.frame.size.height : self.knob.frame.size.width) * mult
                case .right:
                    x = (!self.isVertical ? self.knob.frame.size.height : self.knob.frame.size.width) * mult
                }

                label.translate(by: [x, y])
                self.labelIsShifted = true
                self.onLabelShift?(self)
            } else {
                label.reset()
                self.labelIsShifted = false
                self.onLabelShift?(self)
            }
        }
    }

    private func updateLabelToFitKnob() {
        let alignment = self.label.textAlignment
        self.label.setSize(vw(self.knob), vh(self.knob) / 2)
        self.label.setTextAlignment(alignment)
        self.label.layer.cornerRadius = vh(self.label) / 2
        self.label.setCenter(vc(self.knob))
        self.label.setFontSize(self.knobSize / 3)
    }

    private func moveKnobAndUpdateValue(_ position: CGFloat) {
        let x = !self.isVertical ? position : self.knob.center.x,
            y = !self.isVertical ? self.knob.center.y : position

        if self.animateKnobPosition {
            Animate.custom(animation: {
                self.knob.setCenter(x, y)
            }, duration: self.animationDuration)
        } else {
            self.knob.setCenter(x, y)
        }

        let pos = !self.isVertical ? x : y
        if self.internalValue != Double(self.getInternalValueFromPosition(pos)) {
            self.updatePositionTo(pos)
        }
    }

    private func getKnobCenter() -> CGPoint {
        let a = !self.isVertical ? 0 : frame.size.width / 2,
            b = !self.isVertical ? frame.size.height / 2 : 0
        return CGPoint(x: a, y: b)
    }

    private func updatePositionTo(_ position: CGFloat) {
        self.position = Double(position)
        let oldValue = self.value
        self.updateValueAndLabel()
        if self.value != oldValue {
            self.onChange?(self)
        }
    }

    private func updateValueAndLabel() {
        self.internalValue = Double(getInternalValueFromPosition(CGFloat(self.position)))
        let scaledValue = scale(input: self.internalValue, inputRange: (0, 1), outputRange: (self.minValue, self.maxValue))
        self.value = roundValue(value: scaledValue, places: self.precision)

        if self.precision > 1 {
            self.label.setText("\(self.value)")
        } else {
            self.label.setText("\(Int(self.value))")
        }

    }

    private func getInternalValueFromPosition(_ position: CGFloat) -> CGFloat {
        return !self.isVertical ? position / vw(self) : position / vh(self)
    }

    @objc private func didHiddenLongPress(sender: UILongPressGestureRecognizer) {
        sender.type = .longPress
        self.gestureRecognizer = sender
        self.onHiddenTouch?(self)
    }

    // //////////////////////////////
    // MARK: Color
    // //////////////////////////////

    /**
     Sets `self.colorTheme` and updates colors as follows:

     ```
     slider.setBackgroundColor(theme.background)
           .setBorderColor(theme.border)
           .setShadowColor(theme.shadow)

     slider.knob.setBackgroundColor(theme.contrast)
                .setBorderColor(theme.border)
                .setShadowColor(theme.shadow)

     slider.label.setBackgroundColor(theme.contrast)
                 .setTextColor(theme.text)
     ```

    To set the theme without changing existing colors, set the property `self.colorTheme = newTheme` instead of calling this function.
     */
    @discardableResult override func setColorTheme(_ colorTheme: KDColorTheme) -> KDView {
        self.colorTheme = colorTheme

        self.trackColor = colorTheme.background
        self.track.setBackgroundColor(colorTheme.background)
            .setBorderColor(colorTheme.border)
            .setShadowColor(colorTheme.shadow)

        self.knobColor = colorTheme.contrast
        self.knob.setBackgroundColor(colorTheme.contrast)
            .setBorderColor(colorTheme.border)
            .setShadowColor(colorTheme.shadow)

        self.labelColor = colorTheme.contrast
        self.label.setBackgroundColor(colorTheme.contrast)
            .setTextColor(colorTheme.text)

        return self
    }

    // //////////////////////////////
    // MARK: Coder
    // //////////////////////////////

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
