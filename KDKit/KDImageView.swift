import UIKit

/**
 setImage(_ image: String)
 setImageScaleMode(_ mode: UIViewContentMode)
 */
class KDImageView: UIImageView {

    var name: String?,
        idNum: Int?,
        colorTheme: KDColorTheme?,
        onTouch: ((KDImageView) -> ())?,
        gestureRecognizer: UIGestureRecognizer?

    var tap: UITapGestureRecognizer?,
        longPress: UILongPressGestureRecognizer?,
        swipe: UISwipeGestureRecognizer?,
        pan: UIPanGestureRecognizer?,
        pinch: UIPinchGestureRecognizer?

    // these are used in subclasses
    var useHiddenTouch: Bool = false
    var onHiddenTouch: ((KDImageView) -> ())?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.contentMode = .scaleAspectFit
        self.isUserInteractionEnabled = true
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


    /**
     Convenience init with nullable frame. Sets frame to `CGRect.zero` if `frame:` is `nil`.
     */
    convenience init(frame: CGRect, image: UIImage) {
        self.init(frame)
        self.image = image
    }

    /**
     Convenience init with nullable frame. Sets frame to `CGRect.zero` if `frame:` is `nil`.
     */
    convenience init(_ frame: CGRect, _ image: UIImage) {
        self.init(frame: frame, image: image)
    }



    /**
     Convenience init with nullable frame. Sets frame to `CGRect.zero` if `frame:` is `nil`.
     */
    convenience init(frame: CGRect, image: String) {
        self.init(frame)
        guard let img = UIImage(named: image) else {
            print("Could not find image named: \(image)")
            return
        }
        self.image = img
    }

    /**
     Convenience init with nullable frame. Sets frame to `CGRect.zero` if `frame:` is `nil`.
     */
    convenience init(_ frame: CGRect, _ image: String) {
        self.init(frame: frame, image: image)
    }





    // //////////////////////////////
    // MARK: Image
    // //////////////////////////////

    @discardableResult func setImage(_ image: String) -> KDImageView {
        self.image = UIImage(named: image)
        return self
    }

    @discardableResult func setImageScaleMode(_ mode: UIView.ContentMode) -> KDImageView {
        self.contentMode = mode
        return self
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
    @discardableResult func addToSuperview(_ view: UIView) -> KDImageView {
        view.addSubview(self)
        return self
    }

    // //////////////////////////////
    // MARK: Color
    // //////////////////////////////

    /**
     Set the background color for this view.
     */
    @discardableResult func setBackgroundColor(_ color: UIColor) -> KDImageView {
        self.backgroundColor = color
        return self
    }

    /**
     Sets `self.colorTheme` and updates the background, border, and shadow color to conform to the new theme.

     Use `self.colorTheme = newTheme` to set the theme property without updating the existing colors.
     */
    @discardableResult func setColorTheme(_ colorTheme: KDColorTheme) -> KDImageView {
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
    @discardableResult func setBorderWidth(_ width: CGFloat) -> KDImageView {
        self.layer.borderWidth = width
        return self
    }

    /**
     Set the color of the border for this view.
     */
    @discardableResult func setBorderColor(_ color: UIColor) -> KDImageView {
        self.layer.borderColor = color.cgColor
        return self
    }

    /**
     Set the roundness of the corners for this view.
     Update shadow to account for changes.
     */
    @discardableResult func setRoundness(_ roundness: CGFloat) -> KDImageView {
        self.layer.cornerRadius = roundness
        self.setShadowPath()
        return self
    }

    /**
     Convenience function for setting border properties for this view.
     */
    @discardableResult func setBorder(color: UIColor, width: CGFloat) -> KDImageView {
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
    @discardableResult func setBorder(width: CGFloat, roundness: CGFloat) -> KDImageView {
        setBorderWidth(width)
        setRoundness(roundness)
        return self
    }

    /**
     Convenience function for setting border properties for this view.
     */
    @discardableResult func setBorder(color: UIColor, width: CGFloat, roundness: CGFloat) -> KDImageView {
        setBorder(color: color, width: width)
        setRoundness(roundness)
        return self
    }

    /**
     Returns `CGFloat` equal to half of the views short side length.
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
    @discardableResult func setShadow(_ shadow: Shadow?) -> KDImageView {
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
    @discardableResult func setShadowRadius(_ radius: CGFloat) -> KDImageView {
        self.layer.shadowRadius = radius
        setShadowPath()
        return self
    }

    /**
     Set the shadow offset and update the shadow path.
     */
    @discardableResult func setShadowOffset(_ x: CGFloat, _ y: CGFloat) -> KDImageView {
        self.layer.shadowOffset = CGSize(width: x, height: y)
        setShadowPath()
        return self
    }

    /**
     Set the shadow opacity and update the shadow path.
     */
    @discardableResult func setShadowOpacity(_ opacity: Float) -> KDImageView {
        self.layer.shadowOpacity = opacity
        setShadowPath()
        return self
    }

    /**
     Set the shadow color and update the shadow path.
     */
    @discardableResult func setShadowColor(_ color: UIColor) -> KDImageView {
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
    @discardableResult func setCenterX(_ x: CGFloat) -> KDImageView {
        self.center = CGPoint(x: x, y: self.center.y)
        return self
    }

    /**
     Set the center y position for this view.
     The center point is specified in points in the coordinate system of its superview.
     */
    @discardableResult func setCenterY(_ y: CGFloat) -> KDImageView {
        self.center = CGPoint(x: self.center.x, y: y)
        return self
    }

    /**
     Set the center point for this view.
     The center point is specified in points in the coordinate system of its superview.
     */
    @discardableResult func setCenter(_ x: CGFloat, _ y: CGFloat) -> KDImageView {
        self.center = CGPoint(x: x, y: y)
        return self
    }

    /**
     Set the center point for this view.
     */
    @discardableResult func setCenter(_ center: CGPoint) -> KDImageView {
        self.center = center
        return self
    }

    @discardableResult func centerOnParent () -> KDImageView {
        guard let superview = self.superview else { return self }
        self.setCenter(superview.bounds.width / 2, superview.bounds.height / 2)
        return self
    }

    /**
     Set the x origin for this view.
     Specified in points in the coordinate system of its superview.
     */
    @discardableResult func setOriginX(_ x: CGFloat) -> KDImageView {
        self.frame = CGRect(x: x, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
        return self
    }

    /**
     Set the y origin for this view.
     Specified in points in the coordinate system of its superview.
     */
    @discardableResult func setOriginY(_ y: CGFloat) -> KDImageView {
        self.frame = CGRect(x: self.frame.origin.x, y: y, width: self.frame.size.width, height: self.frame.size.height)
        return self
    }

    /**
     Set the width of this view.
     */
    @discardableResult func setWidth(_ width: CGFloat) -> KDImageView {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: width, height: self.frame.size.height)
        return self
    }

    /**
     Set the height of this view.
     */
    @discardableResult func setHeight(_ height: CGFloat) -> KDImageView {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: height)
        return self
    }

    /**
     Set the size of this view.
     */
    @discardableResult func setSize(_ width: CGFloat, _ height: CGFloat) -> KDImageView {
        self.setWidth(width)
        self.setHeight(height)
        return self
    }

    /**
     Set the origin of this view.
     */
    @discardableResult func setOrigin(_ x: CGFloat, _ y: CGFloat) -> KDImageView {
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
    @discardableResult func setTopMargin(_ margin: CGFloat) -> KDImageView {
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
    @discardableResult func setBottomMargin(_ margin: CGFloat) -> KDImageView {
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
    @discardableResult func setLeftMargin(_ margin: CGFloat) -> KDImageView {
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
    @discardableResult func setRightMargin(_ margin: CGFloat) -> KDImageView {
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
    @discardableResult func setVerticalMargins(_ margin: CGFloat) -> KDImageView {
        setTopMargin(margin)
        setBottomMargin(margin)
        return self
    }

    /**
     Changes the frame of this view to add margins to the left and right.
     Moves the x origin and changes the width of the view by calling `setLeftMargin(margin:)` and `setRightMargin(margin:)`.
     */
    @discardableResult func setHorizontalMargins(_ margin: CGFloat) -> KDImageView {
        setLeftMargin(margin)
        setRightMargin(margin)
        return self
    }

    /**
     Changes the frame of this view to add margins on all sides.
     Moves the x and y origins and changes the height and width of the view by calling `setVerticalMargins(margin:)` and `setHorizontalMargins(margin:)`.
     */
    @discardableResult func setMargins(_ margin: CGFloat) -> KDImageView {
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
    @discardableResult func addTap() -> KDImageView {
        tap = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        self.addGestureRecognizer(tap!)
        return self
    }

    /**
     Remove the `UITapGestureRecognizer` from this view and set the `tap` property to `nil`.
     */
    @discardableResult func removeTap() -> KDImageView {
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
    @discardableResult func addLongPress() -> KDImageView {
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(sender:)))
        self.addGestureRecognizer(longPress!)
        return self
    }

    /**
     Add a `UILongPressGestureRecognizer` as this views `tap` property.

     `duration:` is the `minimumPressDuration` of the gesture, which represents how long the user must press before the gesture is recognized.
     */
    @discardableResult func addLongPress(duration: Double) -> KDImageView {
        addLongPress()
        longPress?.minimumPressDuration = duration
        return self
    }

    /**
     Remove the `UILongPressGestureRecognizer` from this view and set the `longPress` property to `nil`.
     */
    @discardableResult func removeLongPress() -> KDImageView {
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
    @discardableResult func addSwipe() -> KDImageView {
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
    @discardableResult func addSwipe(_ direction: UISwipeGestureRecognizer.Direction) -> KDImageView {
        addSwipe()
        swipe?.direction = direction
        return self
    }

    /**
     Remove the `UISwipeGestureRecognizer` from this view and set the `swipe` property to `nil`.
     */
    @discardableResult func removeSwipe() -> KDImageView {
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
    @discardableResult func addPan() -> KDImageView {
        pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(sender:)))
        self.addGestureRecognizer(pan!)
        return self
    }

    /**
     Remove the `UIPanGestureRecognizer` from this view and set the `pan` property to `nil`.
     */
    @discardableResult func removePan() -> KDImageView {
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
    @discardableResult func addPinch() -> KDImageView {
        pinch = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(sender:)))
        self.addGestureRecognizer(pinch!)
        return self
    }

    /**
     Remove the `UIPinchGestureRecognizer` from this view and set the `pinch` property to `nil`.
     */
    @discardableResult func removePinch() -> KDImageView {
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
