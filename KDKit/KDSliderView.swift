import UIKit

class KDSliderView: KDView {

    enum Alignment {
        case vertical
        case horizontal
    }

    var alignment: Alignment = .vertical
    var sections: Int = 1
    var sliderThickness: CGFloat = 10
    var labelHeight: CGFloat = 50

    var sliders: [KDSlider] = []
    var initialValues: [Double] = []
    var ranges: [(Double, Double)] = []
    var titles: [String?]? = nil

    private var labels: [KDLabel] = []

    // //////////////////////////////
    // MARK: Init
    // //////////////////////////////

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.layer.masksToBounds = false
    }

    /**
     Pass an array of `titles`, `initialValues`, and `ranges` to set each slider independently.
     */
    convenience init(frame: CGRect, alignment: Alignment, sections: Int, sliderThickness: CGFloat, titles: [String?]?, initialValues: [Double], ranges: [(Double, Double)], labelHeight: CGFloat = 50) {

        self.init(frame: frame)

        self.alignment = alignment
        self.sections = sections
        self.sliderThickness = sliderThickness
        self.titles = titles
        self.initialValues = initialValues
        self.ranges = ranges
        self.labelHeight = labelHeight
    }

    /**
     Pass a single value to `initialValue` and `range` to have every slider set the same.
     */
    convenience init(frame: CGRect, alignment: Alignment, sections: Int, sliderThickness: CGFloat, titles: [String?]?, initialValue: Double, range: (Double, Double), labelHeight: CGFloat = 50) {
        self.init(frame: frame)

        self.alignment = alignment
        self.sections = sections
        self.sliderThickness = sliderThickness
        self.titles = titles
        self.labelHeight = labelHeight
        for _ in 0..<sections {
            self.initialValues.append(initialValue)
            self.ranges.append(range)
        }
    }

    func append(_ view: UIView) {
        switch self.alignment {
        case .horizontal:
            let v = self.subviews.sorted(by: { vy($0) < vy($1) })
            let y = v.count > 0 ? vy(v.last!) + vh(v.last!) : 0
            view.frame = CGRect(x: vx(view), y: y, width: vw(view), height: vh(view))
        case .vertical:
            let h = self.subviews.sorted(by: { vx($0) < vx($1) })
            let x = h.count > 0 ? vx(h.last!) + vw(h.last!) : 0
            view.frame = CGRect(x: x, y: vy(view), width: vw(view), height: vh(view))
        }

        self.addSubview(view)
    }

    func draw() {
        for i in 0..<self.sections {
            let rect = self.alignment == .vertical ?
            CGRect(x: 0, y: 0, width: vw(self) / CGFloat(self.sections), height: vh(self)):
                CGRect(x: 0, y: 0, width: vw(self), height: vh(self) / CGFloat(self.sections))
            let view = KDView(rect)

            if self.titles != nil {
                switch self.alignment {
                case .vertical:

                    let centerX = vw(view) / 2
                    let text = self.titles![i] != nil ? self.titles![i] : ""
                    var knobSize = self.sliderThickness * 1.75
                    knobSize = knobSize < 25 ? 25 : knobSize
                    let sliderHeight: CGFloat = vh(view) - self.labelHeight - knobSize
                    // /////
                    let slider = KDSlider(frame: CGRect(x: 0, y: 0, width: knobSize, height: sliderHeight),
                                          trackThickness: self.sliderThickness,
                                          initialValue: self.initialValues[i],
                                          range: self.ranges[i])
                    slider.addToSuperview(view)
                        .setCenterX(centerX)
                        .setOriginY(knobSize / 2)
                    self.sliders.append(slider)

                    // /////
                    let label = KDLabel(frame: CGRect(x: 0, y: 0, width: vw(view), height: self.labelHeight),
                                        font: KDFont.paragraphFont(),
                                        text: text!, .center)
                    label.addToSuperview(view)
                        .setCenterX(centerX)
                        .setOriginY(vh(self) - vh(label))
                    self.labels.append(label)


                case .horizontal:

                    let text = self.titles![i] != nil ? self.titles![i] : ""
                    var knobSize = self.sliderThickness * 1.75
                    knobSize = knobSize < 25 ? 25 : knobSize
                    let centerOffset: CGFloat = 2
                    // /////
                    let slider = KDSlider(frame: CGRect(x: 0, y: 0, width: vw(view) - knobSize, height: knobSize),
                                          trackThickness: self.sliderThickness,
                                          initialValue: self.initialValues[i],
                                          range: self.ranges[i])

                    slider.addToSuperview(view)
                        .setOrigin(knobSize / 2, (vc(view).y - knobSize) - centerOffset)
                    self.sliders.append(slider)

                    // /////
                    let label = KDLabel(fitTextToFrame: CGRect(x: 0, y: 0, width: vw(self), height: self.labelHeight),
                                        fontName: KDFont.paragraphFontName,
                                        text: text!)
                    label.addToSuperview(view)
                        .setOriginY(vc(view).y + centerOffset)
                    self.labels.append(label)

                }

            } else {
//                let sliderRect = self.alignment == .vertical ? self.bounds:
//                    CGRect(x: 0, y: 0, width: vw(view), height: self.sliderThickness)

                let slider = KDSlider(frame: view.bounds,
                                      trackThickness: self.sliderThickness,
                                      initialValue: self.initialValues[i],
                                      range: self.ranges[i])

                slider.addToSuperview(view)
                slider.centerOnParent()
            }

            self.append(view)

        }

    }

//    func draw(alignment: KDScrollView.Alignment, sections: Int, sliderThickness: CGFloat, titles: [String], initialValues: [Double], ranges: [(Double, Double)]) {
//
//    }

    // //////////////////////////////
    // MARK: Coder
    // //////////////////////////////

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
