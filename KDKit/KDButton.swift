import UIKit

/**

 var onTouchDown: ((UILongPressGestureRecognizer) -> ())?,
     onTouchChange: ((UILongPressGestureRecognizer) -> ())?,
     onTouchUp: ((UILongPressGestureRecognizer) -> ())?

 var highlightOnTouch: Bool

 .setVisualStyle(forState: ButtonState)

 .setOnColor(_ color: UIColor)
 .setOffColor(_ color: UIColor)
 .setColor(_ color: UIColor)

 .setOnText(_ text: String)
 .setOffText(_ text: String)
 .setText(_ text: String)

 .setOnImage(_ image: String)
 .setOffImage(_ image: String)
 .setImage(_ image: String)
 */
class KDButton: KDView {

    var onTouchDown: ((UILongPressGestureRecognizer) -> ())?,
        onTouchChange: ((UILongPressGestureRecognizer) -> ())?,
        onTouchUp: ((UILongPressGestureRecognizer) -> ())?

    var lastTouchLoc: CGPoint?

    var label: KDLabel?,
        imageView: KDImageView?

    var onText: String?,
        offText: String?

    var onImage: String?,
        offImage: String?

    var onColor: UIColor?,
        offColor: UIColor?

    var highlightOnTouch: Bool = true

    enum ActiveState {
        case on
        case off
    }

    override init(frame: CGRect) {

        super.init(frame: frame)

        self.useHiddenTouch = true
        let lp = UILongPressGestureRecognizer(target: self, action: #selector(didHiddenLongPress(sender:)))
        lp.minimumPressDuration = 0
        self.addGestureRecognizer(lp)

        self.onHiddenTouch = { this in

            if this.gestureRecognizer?.type == .longPress {
                guard let sender = this.gestureRecognizer as! UILongPressGestureRecognizer? else { return }

                if sender.state == .began {
                    self.lastTouchLoc = sender.location(in: self)
                    self.onTouchDown?(sender)
                    self.checkHighlightOnTouch(forState: .on)
                }

                if sender.state == .changed {
                    if sender.location(in: self) != self.lastTouchLoc {
                        self.lastTouchLoc = sender.location(in: self)
                        self.onTouchChange?(sender)
                    }
                }

                if sender.state == .ended || sender.state == .cancelled {
                    self.onTouchUp?(sender)
                    self.checkHighlightOnTouch(forState: .off)
                }
            }

        }

    }

    @objc private func didHiddenLongPress(sender: UILongPressGestureRecognizer) {
        sender.type = .longPress
        self.gestureRecognizer = sender
        self.onHiddenTouch?(self)
    }

    convenience init(frame: CGRect, color: UIColor, text: String) {
        self.init(frame: frame)
        self.setColor(color)
        self.setText(text)
    }

    convenience init(frame: CGRect, color: UIColor, image: String) {
        self.init(frame: frame)
        self.setColor(color)
        self.setImage(image)
    }

    // //////////////////////////////
    // MARK: State
    // //////////////////////////////

    @discardableResult func setVisualStyle(forState: ActiveState) -> KDButton {
        if forState == .on {
            if self.label != nil {
                self.label?.text = self.onText
                self.label?.fitTextToBounds()
            }
            if self.imageView != nil {
                self.imageView?.image = self.onImage != nil ? UIImage(named: self.onImage!) : nil
            }
            if self.onColor != nil {
                self.setBackgroundColor(self.onColor!)
            }
        } else {
            if self.label != nil {
                self.label?.text = self.offText
                self.label?.fitTextToBounds()
            }
            if self.imageView != nil {
                self.imageView?.image = self.offImage != nil ? UIImage(named: self.offImage!) : nil
            }
            if self.offColor != nil {
                self.setBackgroundColor(self.offColor!)
            }
        }
        return self
    }

    // //////////////////////////////
    // MARK: Color
    // //////////////////////////////

    @discardableResult func setOnColor(_ color: UIColor) -> KDButton {
        self.onColor = color
        return self
    }

    @discardableResult func setOffColor(_ color: UIColor) -> KDButton {
        self.offColor = color
        self.setBackgroundColor(color)
        return self
    }

    @discardableResult func setColor(_ color: UIColor) -> KDButton {
        setOnColor(color)
        setOffColor(color)
        return self
    }

    // //////////////////////////////
    // MARK: Text
    // //////////////////////////////

    @discardableResult func setOnText(_ text: String) -> KDButton {
        self.onText = text
        checkLabel()
        return self
    }

    @discardableResult func setOffText(_ text: String) -> KDButton {
        self.offText = text
        checkLabel()
        return self
    }

    @discardableResult func setText(_ text: String) -> KDButton {
        setOnText(text)
        setOffText(text)
        return self
    }

    // //////////////////////////////
    // MARK: Image
    // //////////////////////////////

    @discardableResult func setOnImage(_ image: String) -> KDButton {
        self.onImage = image
        checkImageView()
        return self
    }

    @discardableResult func setOffImage(_ image: String) -> KDButton {
        self.offImage = image
        checkImageView()
        return self
    }

    @discardableResult func setImage(_ image: String) -> KDButton {
        setOnImage(image)
        setOffImage(image)
        return self
    }

    // //////////////////////////////
    // MARK: Private Functions
    // //////////////////////////////

    private func checkHighlightOnTouch(forState: ActiveState) {
        if self.highlightOnTouch {
            setVisualStyle(forState: forState)
        }
    }

    private func checkLabel() {
        if self.label == nil {
            setupLabel()
        } else {
            self.label?.setText(getOffText())
        }
    }

    private func getOffText() -> String {
        return self.offText != nil ? self.offText! : " "
    }

    private func setupLabel() {
        self.label = KDLabel(fitTextToFrame: self.bounds, fontName: KDFont.paragraphFontName, text: getOffText(), alignment: .center)
        self.label?.fitTextToBounds()
            .addToSuperview(self)
    }

    private func checkImageView() {
        if self.imageView == nil {
            self.imageView = KDImageView(frame: self.bounds)
            setupImageView()
            self.imageView?.addToSuperview(self)
        } else {
            setupImageView()
        }
    }

    private func setupImageView() {
        if self.offImage != nil {
            self.imageView?.image = UIImage(named: self.offImage!)
        }
    }

    // //////////////////////////////
    // MARK: Coder
    // //////////////////////////////

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
