import UIKit

class KDToggle: KDButton {

    var state: ActiveState = .off
    var onToggle: ((KDToggle) -> ())?

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.highlightOnTouch = false

        self.onHiddenTouch = { this in

            if this.gestureRecognizer?.type == .longPress {
                guard let sender = this.gestureRecognizer as! UILongPressGestureRecognizer? else { return }

                if sender.state == .began {
                    self.lastTouchLoc = sender.location(in: self)
                    self.onTouchDown?(sender)
                    self.toggleState()
                }

                if sender.state == .changed {
                    if sender.location(in: self) != self.lastTouchLoc {
                        self.lastTouchLoc = sender.location(in: self)
                        self.onTouchChange?(sender)
                    }
                }

                if sender.state == .ended || sender.state == .cancelled {
                    self.onTouchUp?(sender)

                }
            }

        }

        self.setBorder(color: KDColor.black, width: 1)
        self.setOnText("X")

    }

    /**
     Convenience init that creates a square toggle and sets the center.
     */
    convenience init(size: CGFloat, center: CGPoint) {
        self.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        self.center = center
    }

    /**
     Convenience init that creates a square toggle and sets the center.
     */
    convenience init(size: CGFloat, center: (CGFloat, CGFloat)) {
        self.init(frame: CGRect(x: 0, y: 0, width: size, height: size))
        let (x, y) = center
        self.center = CGPoint(x: x, y: y)
    }

    /**
     Convenience init that creates a square toggle with the given origin.
     */
    convenience init(size: CGFloat, origin: CGPoint) {
        self.init(frame: CGRect(x: origin.x, y: origin.y, width: size, height: size))
    }

    /**
     Convenience init that creates a square toggle with the given origin.
     */
    convenience init(size: CGFloat, origin: (CGFloat, CGFloat)) {
        let (x, y) = origin
        self.init(frame: CGRect(x: x, y: y, width: size, height: size))
    }

    private func toggleState() {
        self.state = self.state == .on ? .off : .on
        Animate.custom(animation: {
            self.setVisualStyle(forState: self.state)
        }, duration: 0.15)
        self.onToggle?(self)
    }

    // //////////////////////////////
    // MARK: Coder
    // //////////////////////////////

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
