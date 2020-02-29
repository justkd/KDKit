import UIKit
import AudioKit

class KDKeyboard: KDScrollView {

    /**
     Convenience struct describing keyboard colors.
     */
    struct KeyColors {
        var background: UIColor,
            border: UIColor

        init(background: UIColor, border: UIColor) {
            self.background = background
            self.border = border
        }
    }

    /**
     Holds values specific to keyboard keys.
     */
    class Key: UIButton {
        enum KeyType {
            case white
            case black
        }

        var type: KeyType = .white
        var stateDown: Bool = false
        var value: MIDINoteNumber = 0
        var touchLoc: CGPoint

        fileprivate var lastTouchLoc: CGPoint?

        override init(frame: CGRect) {
            self.touchLoc = CGPoint(x: 0.5, y: 0.5)
            super.init(frame: frame)
        }

        convenience init(frame: CGRect, type: KeyType) {
            self.init(frame: frame)
            self.type = type
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }

    /**
     Determines how `touchesMoved()` behaves.
     */
    enum TouchMode {
        case normal
        case glissando
        case aftertouch
    }

    // //////////////////////////////
    // MARK: Properties
    // //////////////////////////////

    var onKeyDown: ((Key) -> ())?,
        onKeyUp: ((Key) -> ())?,
        onAftertouch: ((Key) -> ())?,
        touchMode: TouchMode = .normal,
        test: ((KDKeyboard) -> ())?

    private(set) var numberOfVisibleWhiteKeys: Int = 8,
        numberOfOctaves: Int = 10,
        lowestOctave: Int = 0,
        numberOfTouchesToScroll: Int = 1,
        labelsHidden: Bool = false,
        labelFont: UIFont = KDFont.paragraphFont(),
        labelTextColor: UIColor = KDColor.black

    private(set) var whiteKeyWidth: CGFloat,
        blackKeyWidth: CGFloat,
        blackKeyHeight: CGFloat,
        blackKeyWidthRatio: CGFloat = 0.66,
        blackKeyHeightRatio: CGFloat = 0.55

    private var currentKeys: [MIDINoteNumber: UITouch] = [:]

    private(set) var whiteKeyColors = (background: KDColor.white, border: KDColor.black),
        blackKeyColors = (background: KDColor.black, border: KDColor.black)

    let whiteKeyValues: [Int] = [0, 2, 4, 5, 7, 9, 11]
    let blackKeyValues: [Int] = [1, 3, 6, 8, 10]

    // //////////////////////////////
    // MARK: Init
    // //////////////////////////////

    override init(frame: CGRect) {

        self.whiteKeyWidth = frame.width / CGFloat(numberOfVisibleWhiteKeys)
        self.blackKeyWidth = whiteKeyWidth * blackKeyWidthRatio
        self.blackKeyHeight = frame.height * blackKeyHeightRatio

        super.init(frame: frame)

        self.setBorder(color: KDColor.black, width: 1)
        self.setBackgroundColor(KDColor.greys(7))
        self.setAlignment(.horizontal)

        self.setNumberOfTouchesToScroll(1)

        self.addWhiteKeys()
        self.addBlackKeys()

        self.container.isMultipleTouchEnabled = true
        self.showsHorizontalScrollIndicator = true

        self.scrollToOctave(4, animated: false)
    }

    convenience init(frame: CGRect, lowestOctave: Int = 0, numberOfOctaves: Int = 10, visibleOctave: Int = 4) {
        self.init(frame: frame)
        self.set(lowestOctave: lowestOctave, numberOfOctaves: numberOfOctaves)
        self.scrollToOctave(visibleOctave, animated: false)
    }


    // //////////////////////////////
    // MARK: Public
    // //////////////////////////////

    /**
     Set properties that require the view to be redrawn. Parameters will be ignored if `nil` or excluded. Automatically redraws the view and sets the visible content to the lowest octave.
     */
    @discardableResult func set(lowestOctave: Int? = nil,
             numberOfOctaves: Int? = nil,
             numberOfVisibleWhiteKeys: Int? = nil,
             blackKeyWidthRatio: CGFloat? = nil,
             blackKeyHeightRatio: CGFloat? = nil) -> KDKeyboard {

        if lowestOctave != nil {
            self.lowestOctave = lowestOctave!
        }

        if numberOfOctaves != nil {
            self.numberOfOctaves = numberOfOctaves!
        }

        if numberOfVisibleWhiteKeys != nil {
            self.numberOfVisibleWhiteKeys = numberOfVisibleWhiteKeys!
        }

        if blackKeyWidthRatio != nil {
            self.blackKeyWidthRatio = blackKeyWidthRatio!
        }

        if blackKeyHeightRatio != nil {
            self.blackKeyHeightRatio = blackKeyHeightRatio!
        }

        redraw()

        return self
    }

    /**
     Set number of touches required to scroll the keyboard. Default is `1`.
     */
    @discardableResult func setNumberOfTouchesToScroll(_ number: Int) -> KDKeyboard {
        self.numberOfTouchesToScroll = number
        self.panGestureRecognizer.minimumNumberOfTouches = number
        self.panGestureRecognizer.maximumNumberOfTouches = number
        return self
    }

    /**
     Set the color of the octave label text.
     */
    @discardableResult func setTextColor(_ color: UIColor) -> KDKeyboard {
        self.labelTextColor = color
        for view in self.container.subviews {
            if view.isMember(of: Key.self) {
                let key = view as! Key
                if key.type == .white {
                    key.setTitleColor(color, for: .normal)
                }
            }
        }

        return self
    }

    /**
     Set the font of the octave label text.
     */
    @discardableResult func setLabelFont(_ font: UIFont) -> KDKeyboard {
        self.labelFont = font
        for view in self.container.subviews {
            if view.isMember(of: Key.self) {
                let key = view as! Key
                if key.type == .white {
                    key.titleLabel?.font = font
                }
            }
        }

        return self
    }

    /**
     Hide or show the numbered octave labels.
     */
    @discardableResult func hideLabels(_ hidden: Bool) -> KDKeyboard {
        self.labelsHidden = hidden
        for view in self.container.subviews {
            if view.isMember(of: Key.self) {
                let key = view as! Key
                if key.type == .white {
                    if key.value % 12 == 0 {
                        let text = hidden ? "" : "\(key.value)"
                        key.setTitle(text, for: .normal)
                    }
                }
            }
        }

        return self
    }

    /**
     Set the background and border color for the passed key type.
     */
    @discardableResult func setKeyColors(forKeyType: Key.KeyType, background: UIColor?, border: UIColor?) -> KDKeyboard {

        var bg: UIColor?,
            bor: UIColor?

        switch forKeyType {
        case .white:
            bg = background != nil ? background! : self.whiteKeyColors.background
            bor = border != nil ? border : self.whiteKeyColors.border
            self.whiteKeyColors = (background: bg!, border: bor!)
        case .black:
            bg = background != nil ? background! : self.blackKeyColors.background
            bor = border != nil ? border : self.blackKeyColors.border
            self.blackKeyColors = (background: bg!, border: bor!)
        }

        for view in self.container.subviews {
            if view.isMember(of: Key.self) {
                let key = view as! Key
                if key.type == forKeyType {
                    switch key.type {
                    case .white:
                        key.layer.borderColor = self.whiteKeyColors.border.cgColor
                        key.backgroundColor = self.whiteKeyColors.background
                    case .black:
                        key.layer.borderColor = self.blackKeyColors.border.cgColor
                        key.backgroundColor = self.blackKeyColors.background
                    }
                }
            }
        }

        return self

    }


    /**
     Scroll until the passed key is entirely visible, regardless of its position.
     */
    @discardableResult func scrollKeyToVisible(_ key: MIDINoteNumber, animated: Bool) -> KDKeyboard {
        guard let view = keyForValue(key) else { return self}
        self.scrollRectToVisible(view.frame, animated: animated)
        return self
    }

    /**
     Scroll until the passed key is the first visible key on the left.
     */
    @discardableResult func scrollKeyToFirst(_ key: MIDINoteNumber, animated: Bool) -> KDKeyboard {
        guard let view = keyForValue(key) else { return self}
        self.setContentOffset(view.frame.origin, animated: animated)
        return self
    }

    @discardableResult func scrollToOctave(_ octave: Int, animated: Bool) -> KDKeyboard {
        self.scrollKeyToFirst(MIDINoteNumber(octave * 12), animated: animated)
        return self
    }

    /**
     Sets `self.colorTheme` and updates the background, border, and shadow color to conform to the new theme.

     Use `self.colorTheme = newTheme` to set the theme property without updating the existing colors.

     Sets colors according to the following:
     ```
     self.setBackgroundColor(colorTheme.background)
     self.setBorderColor(colorTheme.border)
     self.setTextColor(colorTheme.text)
     self.setKeyColors(forKeyType: .white, background: colorTheme.contrast, border: colorTheme.border)
     self.setKeyColors(forKeyType: .black, background: colorTheme.accent, border: colorTheme.border)
     ```
     */
    @discardableResult override func setColorTheme(_ colorTheme: KDColorTheme) -> KDKeyboard {
        self.colorTheme = colorTheme
        self.setBackgroundColor(colorTheme.background)
            .setBorderColor(colorTheme.border)

        self.setBackgroundColor(colorTheme.background)
        self.setBorderColor(colorTheme.border)
        self.setTextColor(colorTheme.text)
        self.setKeyColors(forKeyType: .white, background: colorTheme.contrast, border: colorTheme.border)
        self.setKeyColors(forKeyType: .black, background: colorTheme.accent, border: colorTheme.border)

        return self
    }

    // //////////////////////////////
    // MARK: Touches Began/Moved/Ended/Cancelled
    // //////////////////////////////

    /**
     Handle passing touch down event. `keyDown(key:)` calls the `self.onKeyDown` callback.
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: UITouch in touches {
            self.keyDown(touch: touch)
        }
    }

    /**
     Handle passing touch moved events. Behavior is dependent on `self.touchMode`.

     `.glissando` will press and release keys as a touch is moved across keys.
     `.aftertouch` will call the `self.onKeyAftertouch` callback.
     `.none` will ignore this event.

     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: UITouch in touches {
            let touchLoc = touch.location(in: self)

            // Handle glissando
            if self.touchMode == .glissando {
                let x = touchLoc.x
                let sensitivity: CGFloat = 3

                // Try to avoid sweet spots where keys quickly switch back and forth
                if x.truncatingRemainder(dividingBy: sensitivity) == 0 {
                    let key: Key? = keyForTouch(touch)
                    if key != nil {
                        // Check the current keys to see if the current touch is stored
                        for pair in self.currentKeys {
                            if pair.value == touch {
                                // Check if the previously stored MIDINote is different from the currently touched key MidiNote
                                if key!.value != pair.key {
                                    // Handle releasing the old key, and pressing the new key
                                    let newKey = keyForValue(key!.value)
                                    let oldKey = keyForValue(pair.key)

                                    if newKey != nil && oldKey != nil {
                                        self.keyUp(key: oldKey!)
                                        self.keyDown(key: newKey!)
                                        self.currentKeys[newKey!.value] = touch
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if self.touchMode == .aftertouch {
                let key: Key? = keyForTouch(touch)
                if key != nil {
                    let pos = touch.location(in: key)
                    let normalized = CGPoint(x: pos.x / vw(key!), y: pos.y / vh(key!))
                    let rounded = roundValue(point: normalized, places: 2)

                    if rounded != key!.lastTouchLoc {
                        key!.lastTouchLoc = rounded
                        key!.touchLoc = rounded
                        self.onAftertouch?(key!)
                    }
                }
            }

        }
    }

    /**
     Handle passing touch up event. `keyUp(touch:)` calls the `self.onKeyUp` callback.
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: UITouch in touches {
            self.keyUp(touch: touch)
        }
    }

    /**
     Handle touch cancel event. Just passes parameters to `touchedEnded(touches:event:)`.
     */
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touchesEnded(touches, with: event)
    }

    // //////////////////////////////
    // MARK: Private
    // //////////////////////////////

    private func redraw() {
        self.resetContainer()
        self.setAlignment(.horizontal)

        self.whiteKeyWidth = vw(self) / CGFloat(numberOfVisibleWhiteKeys)
        self.blackKeyWidth = whiteKeyWidth * blackKeyWidthRatio
        self.blackKeyHeight = vh(self) * blackKeyHeightRatio

        self.addWhiteKeys()
        self.addBlackKeys()

        self.hideLabels(self.labelsHidden)
    }

    /**
     Return a `Key` subview if the touch is within its bounds and it is the first responder.
     */
    private func keyForTouch(_ touch: UITouch) -> Key? {
        let touchLoc = touch.location(in: self)
        var button: Key?
        for view in self.container.subviews {
            if view.isMember(of: Key.self) {
                if (view.frame.contains(touchLoc)) {
                    button = view as? Key
                }
            }
        }
        return button
    }

    /**
     Return a `Key` subview if one exists for the passed `MIDINoteNumber`.
     */
    private func keyForValue(_ value: MIDINoteNumber) -> Key? {
        var button: Key?
        for view in self.container.subviews {
            if view.isMember(of: Key.self) {
                let key = view as! Key
                if key.value == value {
                    button = key
                }
            }
        }
        return button
    }

    /**
     Add white key subviews. Should only be called during initialization, and only before `addBlackKeys()`.
     */
    private func addWhiteKeys() {
        // For each octave, add white keys.
        // This is in a separate loop to take advantage of KDScrollView.append()
        for octave in 0..<numberOfOctaves {
            for key in 0..<7 {
                let whiteKey = Key(frame: CGRect(x: 0, y: 0, width: whiteKeyWidth, height: vh(self)), type: .white)
                whiteKey.layer.borderWidth = 1
                whiteKey.layer.borderColor = whiteKeyColors.border.cgColor
                whiteKey.backgroundColor = whiteKeyColors.background

                whiteKey.value = MIDINoteNumber((octave * 12) + whiteKeyValues[key]) + MIDINoteNumber(lowestOctave * 12)

                // Number each octave with a label
                whiteKey.titleLabel?.font = labelFont
                whiteKey.contentHorizontalAlignment = .left
                whiteKey.contentVerticalAlignment = .bottom
                whiteKey.titleEdgeInsets = UIEdgeInsets(top: 0, left: 5, bottom: 5, right: 0)
                whiteKey.setTitleColor(labelTextColor, for: .normal)
                if whiteKey.value % 12 == 0 {
                    whiteKey.setTitle("\(whiteKey.value)", for: .normal)
                }

                // Interaction is being handled by touches began/ended/moved/cancelled rather than UIControl events
                whiteKey.isUserInteractionEnabled = false

                self.append(whiteKey)
            }
        }
    }

    /**
     Add black key subviews. Should only be called during initialization, and only after `addWhiteKeys()`.
     */
    private func addBlackKeys() {
        // For each octave, add black keys.
        for octave in 0..<numberOfOctaves {
            for key in 0..<5 {
                let blackKey = Key(frame: CGRect(x: 0, y: 0, width: blackKeyWidth, height: blackKeyHeight), type: .black)
                blackKey.layer.borderWidth = 1
                blackKey.layer.borderColor = blackKeyColors.border.cgColor
                blackKey.backgroundColor = blackKeyColors.background

                blackKey.value = MIDINoteNumber((octave * 12) + blackKeyValues[key]) + MIDINoteNumber(lowestOctave * 12)

                // Interaction is being handled by touches began/ended/moved/cancelled rather than UIControl events
                blackKey.isUserInteractionEnabled = false

                let cd = whiteKeyWidth * (CGFloat(key) + 1)
                let fga = whiteKeyWidth * (CGFloat(key) + 1) + whiteKeyWidth
                var center: CGFloat = key < 2 ? cd : fga
                center = center + (whiteKeyWidth * (7 * CGFloat(octave)))
                blackKey.center = CGPoint(x: center, y: blackKey.center.y)

                self.addSubview(blackKey)
            }
        }
    }

    /**
     Handle key down events per touch.
     */
    private func keyDown(touch: UITouch) {
        guard let key: Key = keyForTouch(touch) else { return }
        self.keyDown(key: key)
        self.currentKeys[key.value] = touch
    }

    /**
     Handle key down events per key.
     */
    @objc private func keyDown(key: Key) {
        self.onKeyDown?(key)

        animateDown(key: key)

        // Make sure keys don't get stuck "down" when tapped quickly
        animateCleanUp(key: key)
    }

    /**
     Handle key up events per touch.
     */
    private func keyUp(touch: UITouch) {
        for pair in self.currentKeys {
            if pair.value == touch {
                guard let key = keyForValue(pair.key) else { return }
                self.keyUp(key: key)
                self.currentKeys.removeValue(forKey: key.value)
            }
        }
    }

    /**
     Handle key up events per key.
     */
    @objc private func keyUp(key: Key) {
        // this isn't ideal but audiokit doesnt like on/off commands that are too fast
        // better solution?
        waitFor(duration: 0.05, then: {
            self.onKeyUp?(key)
        })

        animateUp(key: key)
    }

    /**
     Handle animating a key down.
     */
    private func animateDown(key: Key) {
        let size: CGFloat = 0.9
        key.stateDown = true
        async({
            key.layer.removeAllAnimations()
            UIView.animate(withDuration: 0.15,
                           delay: 0,
                           usingSpringWithDamping: 0.2,
                           initialSpringVelocity: 7,
                           options: [.allowUserInteraction, .curveEaseOut],
                           animations: {
                               key.layer.transform = CATransform3DScale(key.layer.transform, size, size, 1)
                           })
        })
    }

    /**
     Handle animating a key up.
     */
    private func animateUp(key: Key) {
        if key.stateDown == true {
            key.stateDown = false
            async({
                key.layer.removeAllAnimations()
                UIView.animate(withDuration: 0.2,
                               delay: 0,
                               usingSpringWithDamping: 0.3,
                               initialSpringVelocity: 7,
                               options: [.allowUserInteraction, .curveEaseOut],
                               animations: {
                                   key.layer.transform = CATransform3DScale(CATransform3DIdentity, 1, 1, 1)
                               })
            })
        }
    }

    /**
     Ensure keys don't get stuck down when tappe quickly.
     */
    private func animateCleanUp(key: Key) {
        waitFor(duration: 0.1, then: {
            if key.stateDown == false {
                if CATransform3DEqualToTransform(key.layer.transform, CATransform3DScale(CATransform3DIdentity, 1, 1, 1)) != true {
                    key.stateDown = true
                    self.animateUp(key: key)
                }
            }
        })
    }

    // //////////////////////////////
    // MARK: Coder
    // //////////////////////////////

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
