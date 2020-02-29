import UIKit

class KDString: KDView {

    struct StringGeometry {
        var length: CGFloat,
            strokeWidth: CGFloat

        init(length: CGFloat, strokeWidth: CGFloat) {
            self.length = length
            self.strokeWidth = strokeWidth
        }
    }

    var geometry: StringGeometry = StringGeometry(length: 1, strokeWidth: 1),
        lineOrigin = CGPoint(x: 0, y: 0),
        lineEnding = CGPoint(x: 1, y: 1),
        lineColor: UIColor = KDColor.black

    var vertical: Bool = false

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init (height: CGFloat, width: CGFloat) {
        let vert = height > width
        let a = !vert ? width : height,
            b = !vert ? height : width

        let rect = CGRect(x: 0, y: 0, width: a, height: b)

        self.init(frame: rect)

        self.vertical = vert
        self.geometry.length = a
        self.geometry.strokeWidth = b

        let mid = self.bounds.size.height / 2
        let c = !vert ? 0 : mid,
            d = !vert ? mid : 0,
            e = !vert ? vw(self) : mid,
            f = !vert ? mid : vh(self)

        self.lineOrigin = CGPoint(x: c, y: d)
        self.lineEnding = CGPoint(x: e, y: f)

    }

    func setLength(length: CGFloat) {


    }

    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setLineWidth(self.geometry.strokeWidth)
        context.setStrokeColor(self.lineColor.cgColor)
        context.move(to: self.lineOrigin)
        context.addLine(to: self.lineEnding)
        context.strokePath()
    }

    // //////////////////////////////
    // MARK: Coder
    // //////////////////////////////

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
