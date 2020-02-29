import UIKit

/**
 ```
 .name: String?
 .idNum: Int?
 .colorTheme: KDColorTheme?
 .onTouch: ((KDView) -> ())?
 .gestureRecognizer: UIGestureRecognizer?

 .tap: UITapGestureRecognizer?,
 .longPress: UILongPressGestureRecognizer?,
 .swipe: UISwipeGestureRecognizer?,
 .pan: UIPanGestureRecognizer?,
 .pinch: UIPinchGestureRecognizer?

 ----

 .addToSuperview(_ view: UIView)

 .setBackgroundColor(_ color: UIColor)
 .setColorTheme(_ colorTheme: KDColorTheme)

 .setBorderWidth(_ width: CGFloat)
 .setBorderColor(_ color: UIColor)
 .setRoundness(_ roundness: CGFloat)
 .setBorder(color: UIColor, width: CGFloat)
 .setBorder(width: CGFloat, roundness: CGFloat)
 .setBorder(color: UIColor, width: CGFloat, roundness: CGFloat)

 .setShadow(shadow: Shadow)
 .setShadowRadius(_ radius: CGFloat)
 .setShadowOffset(_ x: CGFloat, _ y: CGFloat)
 .setShadowOpacity(_ opacity: Float)
 .setShadowColor(_ color: UIColor)

 .setCenter(_ x: CGFloat, _ y: CGFloat)
 .setOriginX(_ x: CGFloat)
 .setOriginY(_ y: CGFloat)
 .setWidth(_ width: CGFloat)
 .setHeight(_ height: CGFloat)
 .setSize(_ width: CGFloat, _ height: CGFloat)
 .setOrigin(_ x: CGFloat, _ y: CGFloat)

 .setTopMargin(_ margin: CGFloat)
 .setBottomMargin(_ margin: CGFloat)
 .setLeftMargin(_ margin: CGFloat)
 .setRightMargin(_ margin: CGFloat)
 .setVerticalMargins(_ margin: CGFloat)
 .setHorizontalMargins(_ margin: CGFloat)
 .setMargins(_ margin: CGFloat)

 .addTap()
 .removeTap()
 .didTap(sender: UITapGestureRecognizer)

 .addLongPress()
 .addLongPress(duration: Double)
 .removeLongPress()
 .didLongPress(sender: UILongPressGestureRecognizer)

 .addSwipe()
 .removeSwipe()
 .didSwipe(sender: UISwipeGestureRecognizer)

 .addPan()
 .removePan()
 .didPan(sender: UIPanGestureRecognizer)

 .addPinch()
 .removePinch()
 .didPinch(sender: UIPinchGestureRecognizer)
 ```
 */
class KDView: UIView {

    var name: String?,
        idNum: Int?,
        colorTheme: KDColorTheme?,
        onTouch: ((KDView) -> ())?,
        gestureRecognizer: UIGestureRecognizer?

    var tap: UITapGestureRecognizer?,
        longPress: UILongPressGestureRecognizer?,
        swipe: UISwipeGestureRecognizer?,
        pan: UIPanGestureRecognizer?,
        pinch: UIPinchGestureRecognizer?

    // these are used in subclasses
    var useHiddenTouch: Bool = false
    var onHiddenTouch: ((KDView) -> ())?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    // //////////////////////////////
    // MARK: Convenience Inits
    // //////////////////////////////

    /**
     Convenience init with nullable frame. Sets frame to `CGRect.zero` if `frame:` is `nil`.
     */
    convenience init(_ frame: CGRect?) {
        let rect: CGRect = frame != nil ? frame! : CGRect.zero
        self.init(frame: rect)
    }

    // ////////////////////////////////////////////////////////////////////////////////////////////
    // MARK: Unofficial KDView Protocol
    // ////////////////////////////////////////////////////////////////////////////////////////////

    // //////////////////////////////
    // MARK: View Hierarchy
    // //////////////////////////////

    /**
     Convenience function to mirror syntax for `UIView.removeFromSuperview()`.
     */
    @discardableResult func addToSuperview(_ view: UIView) -> KDView {
        view.addSubview(self)
        return self
    }

    // //////////////////////////////
    // MARK: Color
    // //////////////////////////////

    /**
     Set the background color for this view.
     */
    @discardableResult func setBackgroundColor(_ color: UIColor) -> KDView {
        self.backgroundColor = color
        return self
    }

    /**
     Sets `self.colorTheme` and updates the background, border, and shadow color to conform to the new theme.

     Use `self.colorTheme = newTheme` to set the theme property without updating the existing colors.
     */
    @discardableResult func setColorTheme(_ colorTheme: KDColorTheme) -> KDView {
        self.colorTheme = colorTheme
        self.setBackgroundColor(colorTheme.background)
            .setBorderColor(colorTheme.border)
            .setShadowColor(colorTheme.shadow)
        return self
    }

    // //////////////////////////////
    // MARK: Border
    // //////////////////////////////

    /**
     Set the width of the border for this view.
     */
    @discardableResult func setBorderWidth(_ width: CGFloat) -> KDView {
        self.layer.borderWidth = width
        return self
    }

    /**
     Set the color of the border for this view.
     */
    @discardableResult func setBorderColor(_ color: UIColor) -> KDView {
        self.layer.borderColor = color.cgColor
        return self
    }

    /**
     Set the roundness of the corners for this view.
     Update shadow to account for changes.
     */
    @discardableResult func setRoundness(_ roundness: CGFloat) -> KDView {
        self.layer.cornerRadius = roundness
        self.setShadowPath()
        return self
    }

    /**
     Convenience function for setting border properties for this view.
     */
    @discardableResult func setBorder(color: UIColor, width: CGFloat) -> KDView {
        // store and remove roundess so order when setting corner radius doesn't matter
        let roundness = self.layer.cornerRadius
        self.layer.cornerRadius = 0
        self.setBorderColor(color)
            .setBorderWidth(width)
        self.layer.cornerRadius = roundness
        return self
    }

    /**
     Convenience function for setting border properties for this view.
     */
    @discardableResult func setBorder(width: CGFloat, roundness: CGFloat) -> KDView {
        setBorderWidth(width)
        setRoundness(roundness)
        return self
    }

    /**
     Convenience function for setting border properties for this view.
     */
    @discardableResult func setBorder(color: UIColor, width: CGFloat, roundness: CGFloat) -> KDView {
        setBorder(color: color, width: width)
        setRoundness(roundness)
        return self
    }

    /**
     Returns `CGFloat` equal to half of the views short side length'.
     */
    func getRadius() -> CGFloat {
        let shortSide = vw(self) <= vh(self) ? vw(self) : vh(self)
        return shortSide / 2
    }

    // //////////////////////////////
    // MARK: Shadow
    // //////////////////////////////

    /**
     Ensure shadows respect rounded corners.
     */
    private func setShadowPath() {
        let shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius)
        self.layer.masksToBounds = false
        self.layer.shadowPath = shadowPath.cgPath
    }

    /**
     Set the shadow for this object and update the shadow path. Pass `nil` to remove the shadow.
     */
    @discardableResult func setShadow(_ shadow: Shadow?) -> KDView {
        if shadow != nil {
            self.layer.shadowRadius = shadow!.radius
            self.layer.shadowOffset = shadow!.offset
            self.layer.shadowColor = shadow!.color.cgColor
            self.layer.shadowOpacity = shadow!.opacity

            setShadowPath()
        } else {
            self.layer.shadowRadius = 0
            self.layer.shadowOffset = CGSize(width: 0, height: 0)
            self.layer.shadowColor = KDColor.clear.cgColor
            self.layer.shadowOpacity = 0
            setShadowPath()
        }

        return self
    }

    /**
     Set the shadow radius (size) and update the shadow path.
     */
    @discardableResult func setShadowRadius(_ radius: CGFloat) -> KDView {
        self.layer.shadowRadius = radius
        setShadowPath()
        return self
    }

    /**
     Set the shadow offset and update the shadow path.
     */
    @discardableResult func setShadowOffset(_ x: CGFloat, _ y: CGFloat) -> KDView {
        self.layer.shadowOffset = CGSize(width: x, height: y)
        setShadowPath()
        return self
    }

    /**
     Set the shadow opacity and update the shadow path.
     */
    @discardableResult func setShadowOpacity(_ opacity: Float) -> KDView {
        self.layer.shadowOpacity = opacity
        setShadowPath()
        return self
    }

    /**
     Set the shadow color and update the shadow path.
     */
    @discardableResult func setShadowColor(_ color: UIColor) -> KDView {
        self.layer.shadowColor = color.cgColor
        setShadowPath()
        return self
    }

    // //////////////////////////////
    // MARK: Frame
    // //////////////////////////////

    /**
     Set the center x position for this view.
     The center point is specified in points in the coordinate system of its superview.
     */
    @discardableResult func setCenterX(_ x: CGFloat) -> KDView {
        self.center = CGPoint(x: x, y: self.center.y)
        return self
    }

    /**
     Set the center y position for this view.
     The center point is specified in points in the coordinate system of its superview.
     */
    @discardableResult func setCenterY(_ y: CGFloat) -> KDView {
        self.center = CGPoint(x: self.center.x, y: y)
        return self
    }

    /**
     Set the center point for this view.
     The center point is specified in points in the coordinate system of its superview.
     */
    @discardableResult func setCenter(_ x: CGFloat, _ y: CGFloat) -> KDView {
        self.center = CGPoint(x: x, y: y)
        return self
    }

    /**
     Set the center point for this view.
     */
    @discardableResult func setCenter(_ center: CGPoint) -> KDView {
        self.center = center
        return self
    }

    @discardableResult func centerOnParent () -> KDView {
        guard let superview = self.superview else { return self }
        self.setCenter(superview.bounds.width / 2, superview.bounds.height / 2)
        return self
    }

    /**
     Set the x origin for this view.
     Specified in points in the coordinate system of its superview.
     */
    @discardableResult func setOriginX(_ x: CGFloat) -> KDView {
        self.frame = CGRect(x: x, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
        return self
    }

    /**
     Set the y origin for this view.
     Specified in points in the coordinate system of its superview.
     */
    @discardableResult func setOriginY(_ y: CGFloat) -> KDView {
        self.frame = CGRect(x: self.frame.origin.x, y: y, width: self.frame.size.width, height: self.frame.size.height)
        return self
    }

    /**
     Set the width of this view.
     */
    @discardableResult func setWidth(_ width: CGFloat) -> KDView {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: width, height: self.frame.size.height)
        return self
    }

    /**
     Set the height of this view.
     */
    @discardableResult func setHeight(_ height: CGFloat) -> KDView {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: height)
        return self
    }

    /**
     Set the size of this view.
     */
    @discardableResult func setSize(_ width: CGFloat, _ height: CGFloat) -> KDView {
        self.setWidth(width)
        self.setHeight(height)
        return self
    }

    /**
     Set the origin of this view.
     */
    @discardableResult func setOrigin(_ x: CGFloat, _ y: CGFloat) -> KDView {
        self.setOriginX(x)
        self.setOriginY(y)
        return self
    }

    // //////////////////////////////
    // MARK: Margins
    // //////////////////////////////

    /**
     Changes the frame of this view to add a margin to the top.
     Moves the y origin and changes the height of the view.
     */
    @discardableResult func setTopMargin(_ margin: CGFloat) -> KDView {
        if (margin * 2 >= self.frame.height) {
            print("\nVertical margins must be less than half the height of the view.")
            return self
        }

        self.frame = CGRect(x: self.frame.origin.x,
                            y: self.frame.origin.y + margin,
                            width: self.frame.size.width,
                            height: self.frame.size.height - margin)

        return self
    }

    /**
     Changes the frame of this view to add a margin to the bottom.
     Changes the height of the view.
     */
    @discardableResult func setBottomMargin(_ margin: CGFloat) -> KDView {
        if (margin * 2 >= self.frame.height) {
            print("\nVertical margins must be less than half the height of the view.")
            return self
        }

        self.frame = CGRect(x: self.frame.origin.x,
                            y: self.frame.origin.y,
                            width: self.frame.size.width,
                            height: self.frame.size.height - margin)

        return self
    }

    /**
     Changes the frame of this view to add a margin to the left.
     Moves the x origin and changes the width of the view.
     */
    @discardableResult func setLeftMargin(_ margin: CGFloat) -> KDView {
        if (margin * 2 >= self.frame.width) {
            print("\nHorizontal margins must be less than half the width of the view.")
            return self
        }

        self.frame = CGRect(x: self.frame.origin.x + margin,
                            y: self.frame.origin.y,
                            width: self.frame.size.width - margin,
                            height: self.frame.size.height)

        return self
    }

    /**
     Changes the frame of this view to add a margin to the right.
     Changes the width of the view.
     */
    @discardableResult func setRightMargin(_ margin: CGFloat) -> KDView {
        if (margin * 2 >= self.frame.width) {
            print("\nHorizontal margins must be less than half the width of the view.")
            return self
        }

        self.frame = CGRect(x: self.frame.origin.x,
                            y: self.frame.origin.y,
                            width: self.frame.size.width - margin,
                            height: self.frame.size.height)

        return self
    }

    /**
     Changes the frame of this view to add margins to the top and bottom.
     Moves the y origin and changes the height of the view by calling `setTopMargin(margin:)` and `setBottomMargin(margin:)`.
     */
    @discardableResult func setVerticalMargins(_ margin: CGFloat) -> KDView {
        setTopMargin(margin)
        setBottomMargin(margin)
        return self
    }

    /**
     Changes the frame of this view to add margins to the left and right.
     Moves the x origin and changes the width of the view by calling `setLeftMargin(margin:)` and `setRightMargin(margin:)`.
     */
    @discardableResult func setHorizontalMargins(_ margin: CGFloat) -> KDView {
        setLeftMargin(margin)
        setRightMargin(margin)
        return self
    }

    /**
     Changes the frame of this view to add margins on all sides.
     Moves the x and y origins and changes the height and width of the view by calling `setVerticalMargins(margin:)` and `setHorizontalMargins(margin:)`.
     */
    @discardableResult func setMargins(_ margin: CGFloat) -> KDView {
        setVerticalMargins(margin)
        setHorizontalMargins(margin)
        return self
    }

    // //////////////////////////////
    // MARK: Tap
    // //////////////////////////////

    private func doTouch() {
        self.onTouch?(self)
        if self.useHiddenTouch {
            self.onHiddenTouch?(self)
        }
    }

    /**
     Add a `UITapGestureRecognizer` as this views `tap` property.
     */
    @discardableResult func addTap() -> KDView {
        tap = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        self.addGestureRecognizer(tap!)
        return self
    }

    /**
     Remove the `UITapGestureRecognizer` from this view and set the `tap` property to `nil`.
     */
    @discardableResult func removeTap() -> KDView {
        if tap != nil {
            self.removeGestureRecognizer(tap!)
            tap = nil
        }
        return self
    }

    /**
     Called by this views `tap` property.
     */
    @objc private func didTap(sender: UITapGestureRecognizer) {
        sender.type = .tap
        self.gestureRecognizer = sender
        doTouch()
    }

    // //////////////////////////////
    // MARK: Long Press
    // //////////////////////////////

    /**
     Add a `UILongPressGestureRecognizer` as this views `tap` property.
     */
    @discardableResult func addLongPress() -> KDView {
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(sender:)))
        self.addGestureRecognizer(longPress!)
        return self
    }

    /**
     Add a `UILongPressGestureRecognizer` as this views `tap` property.

     `duration:` is the `minimumPressDuration` of the gesture, which represents how long the user must press before the gesture is recognized.
     */
    @discardableResult func addLongPress(duration: Double) -> KDView {
        addLongPress()
        longPress?.minimumPressDuration = duration
        return self
    }

    /**
     Remove the `UILongPressGestureRecognizer` from this view and set the `longPress` property to `nil`.
     */
    @discardableResult func removeLongPress() -> KDView {
        if longPress != nil {
            self.removeGestureRecognizer(longPress!)
            longPress = nil
        }
        return self
    }

    /**
     Called by this views `longPress` property.
     */
    @objc private func didLongPress(sender: UILongPressGestureRecognizer) {
        sender.type = .longPress
        self.gestureRecognizer = sender
        doTouch()
    }

    // //////////////////////////////
    // MARK: Swipe
    // //////////////////////////////

    /**
     Add a `UISwipeGestureRecognizer` as this views `swipe` property.
     */
    @discardableResult func addSwipe() -> KDView {
        swipe = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(sender:)))
        self.addGestureRecognizer(swipe!)
        return self
    }

    /**
     Add a `UISwipeGestureRecognizer` as this views `swipe` property.

     `direction:` is a `UISwipeGestureRecognizerDirection` case:
        - `.up`
        - `.down`
        - `.left`
        - `.right`
     */
    @discardableResult func addSwipe(_ direction: UISwipeGestureRecognizer.Direction) -> KDView {
        addSwipe()
        swipe?.direction = direction
        return self
    }

    /**
     Remove the `UISwipeGestureRecognizer` from this view and set the `swipe` property to `nil`.
     */
    @discardableResult func removeSwipe() -> KDView {
        if swipe != nil {
            self.removeGestureRecognizer(swipe!)
            swipe = nil
        }
        return self
    }

    /**
     Called by this views `swipe` property.
     */
    @objc private func didSwipe(sender: UISwipeGestureRecognizer) {
        sender.type = .swipe
        self.gestureRecognizer = sender
        doTouch()
    }

    // //////////////////////////////
    // MARK: Pan
    // //////////////////////////////

    /**
     Add a `UIPanGestureRecognizer` as this views `swipe` property.
     */
    @discardableResult func addPan() -> KDView {
        pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(sender:)))
        self.addGestureRecognizer(pan!)
        return self
    }

    /**
     Remove the `UIPanGestureRecognizer` from this view and set the `pan` property to `nil`.
     */
    @discardableResult func removePan() -> KDView {
        if pan != nil {
            self.removeGestureRecognizer(pan!)
            pan = nil
        }
        return self
    }

    /**
     Called by this views `swipe` property.
     */
    @objc private func didPan(sender: UIPanGestureRecognizer) {
        sender.type = .pan
        self.gestureRecognizer = sender
        doTouch()
    }

    // //////////////////////////////
    // MARK: Pinch
    // //////////////////////////////

    /**
     Add a `UIPinchGestureRecognizer` as this views `swipe` property.
     */
    @discardableResult func addPinch() -> KDView {
        pinch = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(sender:)))
        self.addGestureRecognizer(pinch!)
        return self
    }

    /**
     Remove the `UIPinchGestureRecognizer` from this view and set the `pinch` property to `nil`.
     */
    @discardableResult func removePinch() -> KDView {
        if pinch != nil {
            self.removeGestureRecognizer(pinch!)
            pinch = nil
        }
        return self
    }

    /**
     Called by this views `pinch` property.
     */
    @objc private func didPinch(sender: UIPinchGestureRecognizer) {
        sender.type = .pinch
        self.gestureRecognizer = sender
        doTouch()
    }

    // //////////////////////////////
    // MARK: Coder
    // //////////////////////////////

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
