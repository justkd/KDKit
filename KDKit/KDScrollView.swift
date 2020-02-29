import UIKit

class KDScrollView: UIScrollView, UIScrollViewDelegate {

    var name: String?,
        idNum: Int?,
        colorTheme: KDColorTheme?,
        onTouch: ((KDScrollView) -> ())?,
        gestureRecognizer: UIGestureRecognizer?

    var tap: UITapGestureRecognizer?,
        longPress: UILongPressGestureRecognizer?,
        swipe: UISwipeGestureRecognizer?,
        pan: UIPanGestureRecognizer?,
        pinch: UIPinchGestureRecognizer?

    // these are used in subclasses
    var useHiddenTouch: Bool = false
    var onHiddenTouch: ((KDScrollView) -> ())?

    enum Alignment {
        case vertical
        case horizontal
        case twoDimensional
    }

    private(set) var alignment: Alignment = .vertical
    private(set) var container: UIView

    // //////////////////////////////
    // MARK: Init
    // //////////////////////////////

    override init(frame: CGRect) {
        self.container = UIView(frame: frame)
        super.init(frame: frame)
        self.insertSubview(container, at: 0)
        self.contentInsetAdjustmentBehavior = .never
        self.delegate = self

        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }

    convenience init(frame: CGRect, alignment: Alignment) {
        self.init(frame: frame)
        self.alignment = alignment
    }

    /**
     Convenience init with nullable frame. Sets frame to `CGRect.zero` if `frame:` is `nil`.
     */
    convenience init(_ frame: CGRect?, _ alignment: Alignment = .vertical) {
        let rect: CGRect = frame != nil ? frame! : CGRect.zero
        self.init(frame: rect, alignment: alignment)
    }

    // //////////////////////////////
    // MARK: Scroll View
    // //////////////////////////////

    func updateContentSize() {
        var width: CGFloat = 0
        var height: CGFloat = 0

        switch self.alignment {
        case .vertical:
            self.container.subviews.forEach({
                if vw($0) > width { width = vw($0) }
                height = height + vh($0)
            })
        case .horizontal:
            self.container.subviews.forEach({
                if vh($0) > height { height = vh($0) }
                width = width + vw($0)
            })
        case .twoDimensional:
            let h = self.container.subviews.sorted(by: { vx($0) < vx($1) })
            let v = self.container.subviews.sorted(by: { vy($0) < vy($1) })
            width = h.count > 0 ? vx(h.last!) + vw(h.last!) : 0
            height = v.count > 0 ? vy(v.last!) + vh(v.last!) : 0
        }

        self.container.frame = CGRect(x: vx(self.container), y: vy(self.container), width: width, height: height)
        self.contentSize = CGSize(width: width, height: height)
    }

    func resetContainer() {
        for view in self.container.subviews {
            view.removeFromSuperview()
        }
    }

    func setPagingEnabled(_ paging: Bool) {
        self.isPagingEnabled = paging
    }

    func setAlignment(_ alignment: Alignment) {
        self.alignment = alignment
        self.updateContentSize()
    }

    /**
     Automatically determines the origin of the passed view such that it is added to the end of the existing collection of subviews. Calculation dependent on `self.alignment`. If `self.alignment = .twoDimensional`, this function does not change the frame of the passed view, but does add it to `self.subviews` and calls `self.updateContentSize`.
     */
    func append(_ view: UIView) {
        switch self.alignment {
        case .vertical:
            let v = self.container.subviews.sorted(by: { vy($0) < vy($1) })
            let y = v.count > 0 ? vy(v.last!) + vh(v.last!) : 0
            view.frame = CGRect(x: vx(view), y: y, width: vw(view), height: vh(view))
        case .horizontal:
            let h = self.container.subviews.sorted(by: { vx($0) < vx($1) })
            let x = h.count > 0 ? vx(h.last!) + vw(h.last!) : 0
            view.frame = CGRect(x: x, y: vy(view), width: vw(view), height: vh(view))
        default:
            break
        }

        self.container.addSubview(view)
        self.updateContentSize()
    }

    func setZoomable(minScale: CGFloat, maxScale: CGFloat) {
        self.minimumZoomScale = minScale
        self.maximumZoomScale = maxScale
    }

    func resetZoom() {
        self.zoomScale = 1.0

        if self.container.frame.origin != CGPoint(x: 0, y: 0) {
            Animate.custom(animation: {
                self.container.frame.origin = CGPoint(x: 0, y: 0)
            }, 0.3)
        }

    }

    func resetPosition(animated: Bool) {
        self.scrollRectToVisible(CGRect(x: 0, y: 0, width: 1, height: 1), animated: animated)
    }

    // //////////////////////////////
    // MARK: UIScrollView Delegate
    // //////////////////////////////

    func viewForZooming(in: UIScrollView) -> UIView? {
        return self.container
    }

    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {

        let widthScaled = vw(self.container) * scale,
            heightScaled = vh(self.container) * scale

        let wide = widthScaled >= vw(self),
            tall = heightScaled >= vh(self)

        let origin = CGPoint(x: !wide ? (vw(self) - widthScaled) / 2 : 0,
                             y: !tall ? (vh(self) - heightScaled) / 2 : 0)

        Animate.custom(animation: {
            self.container.frame.origin = origin
        }, 0.3)

    }

    override func addSubview(_ view: UIView) {
        self.container.addSubview(view)
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
    @discardableResult func addToSuperview(_ view: UIView) -> KDScrollView {
        view.addSubview(self)
        return self
    }

    // //////////////////////////////
    // MARK: Color
    // //////////////////////////////

    /**
     Set the background color for this view.
     */
    @discardableResult func setBackgroundColor(_ color: UIColor) -> KDScrollView {
        self.backgroundColor = color
        return self
    }

    /**
     Sets `self.colorTheme` and updates the background, border, and shadow color to conform to the new theme.

     Use `self.colorTheme = newTheme` to set the theme property without updating the existing colors.
     */
    @discardableResult func setColorTheme(_ colorTheme: KDColorTheme) -> KDScrollView {
        self.colorTheme = colorTheme
        self.setBackgroundColor(colorTheme.background)
            .setBorderColor(colorTheme.border)
        return self
    }

    // //////////////////////////////
    // MARK: Border
    // //////////////////////////////

    /**
     Set the width of the border for this view.
     */
    @discardableResult func setBorderWidth(_ width: CGFloat) -> KDScrollView {
        self.layer.borderWidth = width
        return self
    }

    /**
     Set the color of the border for this view.
     */
    @discardableResult func setBorderColor(_ color: UIColor) -> KDScrollView {
        self.layer.borderColor = color.cgColor
        return self
    }

    /**
     Set the roundness of the corners for this view.
     Update shadow to account for changes.
     */
    @discardableResult func setRoundness(_ roundness: CGFloat) -> KDScrollView {
        self.layer.cornerRadius = roundness
        return self
    }

    /**
     Convenience function for setting border properties for this view.
     */
    @discardableResult func setBorder(color: UIColor, width: CGFloat) -> KDScrollView {
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
    @discardableResult func setBorder(width: CGFloat, roundness: CGFloat) -> KDScrollView {
        setBorderWidth(width)
        setRoundness(roundness)
        return self
    }

    /**
     Convenience function for setting border properties for this view.
     */
    @discardableResult func setBorder(color: UIColor, width: CGFloat, roundness: CGFloat) -> KDScrollView {
        setBorder(color: color, width: width)
        setRoundness(roundness)
        return self
    }

    /**
     Returns `CGFloat` equal to half of the views shortside length.
     */
    func getRadius() -> CGFloat {
        let shortSide = vw(self) <= vh(self) ? vw(self) : vh(self)
        return shortSide / 2
    }

    // //////////////////////////////
    // MARK: Shadow
    // //////////////////////////////

    /**
     To add a shadow to KDScrollView, wrap it inside a containing superview that has the shadow.
     */
    func setShadow() {
        print("To add a shadow to KDScrollView, wrap it inside a containing superview that has the shadow.")
    }

    // //////////////////////////////
    // MARK: Frame
    // //////////////////////////////

    /**
     Set the center x position for this view.
     The center point is specified in points in the coordinate system of its superview.
     */
    @discardableResult func setCenterX(_ x: CGFloat) -> KDScrollView {
        self.center = CGPoint(x: x, y: self.center.y)
        return self
    }

    /**
     Set the center y position for this view.
     The center point is specified in points in the coordinate system of its superview.
     */
    @discardableResult func setCenterY(_ y: CGFloat) -> KDScrollView {
        self.center = CGPoint(x: self.center.x, y: y)
        return self
    }

    /**
     Set the center point for this view.
     The center point is specified in points in the coordinate system of its superview.
     */
    @discardableResult func setCenter(_ x: CGFloat, _ y: CGFloat) -> KDScrollView {
        self.center = CGPoint(x: x, y: y)
        return self
    }

    /**
     Set the center point for this view.
     */
    @discardableResult func setCenter(_ center: CGPoint) -> KDScrollView {
        self.center = center
        return self
    }

    @discardableResult func centerOnParent () -> KDScrollView {
        guard let superview = self.superview else { return self }
        self.setCenter(superview.bounds.width / 2, superview.bounds.height / 2)
        return self
    }

    /**
     Set the x origin for this view.
     Specified in points in the coordinate system of its superview.
     */
    @discardableResult func setOriginX(_ x: CGFloat) -> KDScrollView {
        self.frame = CGRect(x: x, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
        return self
    }

    /**
     Set the y origin for this view.
     Specified in points in the coordinate system of its superview.
     */
    @discardableResult func setOriginY(_ y: CGFloat) -> KDScrollView {
        self.frame = CGRect(x: self.frame.origin.x, y: y, width: self.frame.size.width, height: self.frame.size.height)
        return self
    }

    /**
     Set the width of this view.
     */
    @discardableResult func setWidth(_ width: CGFloat) -> KDScrollView {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: width, height: self.frame.size.height)
        return self
    }

    /**
     Set the height of this view.
     */
    @discardableResult func setHeight(_ height: CGFloat) -> KDScrollView {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: height)
        return self
    }

    /**
     Set the size of this view.
     */
    @discardableResult func setSize(_ width: CGFloat, _ height: CGFloat) -> KDScrollView {
        self.setWidth(width)
        self.setHeight(height)
        return self
    }

    /**
     Set the origin of this view.
     */
    @discardableResult func setOrigin(_ x: CGFloat, _ y: CGFloat) -> KDScrollView {
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
    @discardableResult func setTopMargin(_ margin: CGFloat) -> KDScrollView {
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
    @discardableResult func setBottomMargin(_ margin: CGFloat) -> KDScrollView {
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
    @discardableResult func setLeftMargin(_ margin: CGFloat) -> KDScrollView {
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
    @discardableResult func setRightMargin(_ margin: CGFloat) -> KDScrollView {
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
    @discardableResult func setVerticalMargins(_ margin: CGFloat) -> KDScrollView {
        setTopMargin(margin)
        setBottomMargin(margin)
        return self
    }

    /**
     Changes the frame of this view to add margins to the left and right.
     Moves the x origin and changes the width of the view by calling `setLeftMargin(margin:)` and `setRightMargin(margin:)`.
     */
    @discardableResult func setHorizontalMargins(_ margin: CGFloat) -> KDScrollView {
        setLeftMargin(margin)
        setRightMargin(margin)
        return self
    }

    /**
     Changes the frame of this view to add margins on all sides.
     Moves the x and y origins and changes the height and width of the view by calling `setVerticalMargins(margin:)` and `setHorizontalMargins(margin:)`.
     */
    @discardableResult func setMargins(_ margin: CGFloat) -> KDScrollView {
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
    @discardableResult func addTap() -> KDScrollView {
        tap = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        self.addGestureRecognizer(tap!)
        return self
    }

    /**
     Remove the `UITapGestureRecognizer` from this view and set the `tap` property to `nil`.
     */
    @discardableResult func removeTap() -> KDScrollView {
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
    @discardableResult func addLongPress() -> KDScrollView {
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(sender:)))
        self.addGestureRecognizer(longPress!)
        return self
    }

    /**
     Add a `UILongPressGestureRecognizer` as this views `tap` property.

     `duration:` is the `minimumPressDuration` of the gesture, which represents how long the user must press before the gesture is recognized.
     */
    @discardableResult func addLongPress(duration: Double) -> KDScrollView {
        addLongPress()
        longPress?.minimumPressDuration = duration
        return self
    }

    /**
     Remove the `UILongPressGestureRecognizer` from this view and set the `longPress` property to `nil`.
     */
    @discardableResult func removeLongPress() -> KDScrollView {
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
    @discardableResult func addSwipe() -> KDScrollView {
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
    @discardableResult func addSwipe(_ direction: UISwipeGestureRecognizer.Direction) -> KDScrollView {
        addSwipe()
        swipe?.direction = direction
        return self
    }

    /**
     Remove the `UISwipeGestureRecognizer` from this view and set the `swipe` property to `nil`.
     */
    @discardableResult func removeSwipe() -> KDScrollView {
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
    @discardableResult func addPan() -> KDScrollView {
        pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(sender:)))
        self.addGestureRecognizer(pan!)
        return self
    }

    /**
     Remove the `UIPanGestureRecognizer` from this view and set the `pan` property to `nil`.
     */
    @discardableResult func removePan() -> KDScrollView {
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
    @discardableResult func addPinch() -> KDScrollView {
        pinch = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(sender:)))
        self.addGestureRecognizer(pinch!)
        return self
    }

    /**
     Remove the `UIPinchGestureRecognizer` from this view and set the `pinch` property to `nil`.
     */
    @discardableResult func removePinch() -> KDScrollView {
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
