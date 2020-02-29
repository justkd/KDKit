import UIKit

// this will be a toggle styled more like the native iOS toggle
class KDSwitch: KDToggle {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    // //////////////////////////////
    // MARK: Coder
    // //////////////////////////////

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
