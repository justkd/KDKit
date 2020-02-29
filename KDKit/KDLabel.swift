import UIKit

/**
```
// No automatic resizing
KDLabel(frame: CGRect, font: UIFont, text: String, _ alignment: NSTextAlignment = .left)

// Automatically assign a font size that fits the given text into a single line in the label bounds.
KDLabel(fitTextToFrame: CGRect, fontName: String, text: String, alignment: NSTextAlignment)

// Automatically word wrap and resize the height of the frame to fit the text to the width of the frame.
KDLabel(fitFrameToText: CGRect, fontName: String, fontSize: CGFloat, text: String, alignment: NSTextAlignment)


.fitBoundsToText()
.fitTextToBounds()

.setUnderline(_ style: NSUnderlineStyle?, _ color: UIColor?)
.setOutline(_ width: CGFloat?, _ color: UIColor?)
.setStrikeThrough(_ style: NSUnderlineStyle?, _ color: UIColor?)
.setShadow(_ offset: CGSize?, _ radius: CGFloat, _ color: UIColor?)
.setBaselineOffset(_ amount: CGFloat)
.setSkew(_ amount: CGFloat)
.setHighlight(_ color: UIColor)

.setAttributes(_ attributes: [AttributeKeys: AttributedStyleProtocol], forSubString: String)

.show(_ attribute: AttributeKeys)
.show(_ attributes: [AttributeKeys])
.hide(_ attribute: AttributeKeys)
.hide(_ attributes: [AttributeKeys])

.setText(_ text: String)
.setTextColor(_ color: UIColor)
.setTextAlignment(_ alignment: NSTextAlignment)
.setFont(_ font: UIFont)
.setFontName(_ fontName: String)
.setFontSize(_ fontSize: CGFloat)
```
 */

protocol AttributedStyleProtocol {
    var style: NSUnderlineStyle? { get set }
    var color: UIColor? { get set }
    var width: CGFloat? { get set }
    var offset: CGSize? { get set }
    var radius: CGFloat? { get set }
    var amount: CGFloat? { get set }
    var textStyle: NSAttributedString.TextEffectStyle? { get set }
    var url: NSURL? { get set }
}

class KDLabel: UILabel {

    var name: String?,
        idNum: Int?,
        colorTheme: KDColorTheme?,
        onTouch: ((KDLabel) -> ())?,
        gestureRecognizer: UIGestureRecognizer?

    var tap: UITapGestureRecognizer?,
        longPress: UILongPressGestureRecognizer?,
        swipe: UISwipeGestureRecognizer?,
        pan: UIPanGestureRecognizer?,
        pinch: UIPinchGestureRecognizer?

    // these are used in subclasses
    var useHiddenTouch: Bool = false
    var onHiddenTouch: ((KDLabel) -> ())?

    override var text: String? {
        didSet {
            buildAndSetAttributedString()
        }
    }

    enum AttributeKeys {
        case underline
        case outline
        case strikeThrough
        case shadow
        case baselineOffset
        case skew
        case kern
        case highlight
        case textColor
        case textEffect
        case link
    }

    struct Styles {

        struct Underline: AttributedStyleProtocol {
            var style: NSUnderlineStyle?,
                color: UIColor?,
                width: CGFloat?,
                offset: CGSize?,
                radius: CGFloat?,
                amount: CGFloat?,
                textStyle: NSAttributedString.TextEffectStyle?,
                url: NSURL?

            init (style: NSUnderlineStyle?, color: UIColor?) {
                self.style = style != nil ? style! : NSUnderlineStyle.single
                self.color = color != nil ? color! : KDColor.black

            }

            init() {
                self.init(style: nil, color: nil)
            }
        }

        struct Outline: AttributedStyleProtocol {
            var style: NSUnderlineStyle?,
                color: UIColor?,
                width: CGFloat?,
                offset: CGSize?,
                radius: CGFloat?,
                amount: CGFloat?,
                textStyle: NSAttributedString.TextEffectStyle?,
                url: NSURL?

            init(width: CGFloat?, color: UIColor?) {
                self.width = width != nil ? width! : 3.0
                self.color = color != nil ? color! : KDColor.grey
            }

            init() {
                self.init(width: nil, color: nil)
            }
        }

        struct Strikethrough: AttributedStyleProtocol {
            var style: NSUnderlineStyle?,
                color: UIColor?,
                width: CGFloat?,
                offset: CGSize?,
                radius: CGFloat?,
                amount: CGFloat?,
                textStyle: NSAttributedString.TextEffectStyle?,
                url: NSURL?

            init (style: NSUnderlineStyle?, color: UIColor?) {
                self.style = style != nil ? style! : NSUnderlineStyle.single
                self.color = color != nil ? color! : KDColor.black

            }

            init() {
                self.init(style: nil, color: nil)
            }
        }

        struct TextShadow: AttributedStyleProtocol {
            var style: NSUnderlineStyle?,
                color: UIColor?,
                width: CGFloat?,
                offset: CGSize?,
                radius: CGFloat?,
                amount: CGFloat?,
                textStyle: NSAttributedString.TextEffectStyle?,
                url: NSURL?

            init(offset: CGSize?, radius: CGFloat?, color: UIColor?) {
                self.offset = offset != nil ? offset! : CGSize(width: -1.0, height: -1.0)
                self.radius = radius != nil ? radius! : 1.0
                self.color = color != nil ? color! : KDColor.greys(3)
            }

            init(offsetX: CGFloat?, offsetY: CGFloat?, radius: CGFloat?, color: UIColor?) {
                let x = offsetX != nil ? offsetX! : -1.0
                let y = offsetY != nil ? offsetY! : -1.0
                self.init(offset: CGSize(width: x, height: y), radius: radius, color: color)
            }

            init() {
                self.init(offset: nil, radius: nil, color: nil)
            }
        }

        struct BaselineOffset: AttributedStyleProtocol {
            var style: NSUnderlineStyle?,
                color: UIColor?,
                width: CGFloat?,
                offset: CGSize?,
                radius: CGFloat?,
                amount: CGFloat?,
                textStyle: NSAttributedString.TextEffectStyle?,
                url: NSURL?

            init(amount: CGFloat?) {
                self.amount = amount != nil ? amount! : 5.0
            }

            init() {
                self.init(amount: nil)
            }
        }

        struct Skew: AttributedStyleProtocol {
            var style: NSUnderlineStyle?,
                color: UIColor?,
                width: CGFloat?,
                offset: CGSize?,
                radius: CGFloat?,
                amount: CGFloat?,
                textStyle: NSAttributedString.TextEffectStyle?,
                url: NSURL?

            init(amount: CGFloat?) {
                self.amount = amount != nil ? amount! : 3.0
            }

            init() {
                self.init(amount: nil)
            }
        }

        struct Kern: AttributedStyleProtocol {
            var style: NSUnderlineStyle?,
                color: UIColor?,
                width: CGFloat?,
                offset: CGSize?,
                radius: CGFloat?,
                amount: CGFloat?,
                textStyle: NSAttributedString.TextEffectStyle?,
                url: NSURL?

            init(amount: CGFloat?) {
                self.amount = amount != nil ? amount! : 3.0
            }

            init() {
                self.init(amount: nil)
            }
        }

        struct Highlight: AttributedStyleProtocol {
            var style: NSUnderlineStyle?,
                color: UIColor?,
                width: CGFloat?,
                offset: CGSize?,
                radius: CGFloat?,
                amount: CGFloat?,
                textStyle: NSAttributedString.TextEffectStyle?,
                url: NSURL?

            init(color: UIColor?) {
                self.color = color != nil ? color! : KDColor.yellow
            }

            init() {
                self.init(color: nil)
            }
        }

        struct TextColor: AttributedStyleProtocol {
            var style: NSUnderlineStyle?,
                color: UIColor?,
                width: CGFloat?,
                offset: CGSize?,
                radius: CGFloat?,
                amount: CGFloat?,
                textStyle: NSAttributedString.TextEffectStyle?,
                url: NSURL?

            init(color: UIColor?) {
                self.color = color != nil ? color! : KDColor.black
            }

            init() {
                self.init(color: nil)
            }
        }

        struct TextEffect: AttributedStyleProtocol {
            var style: NSUnderlineStyle?,
                color: UIColor?,
                width: CGFloat?,
                offset: CGSize?,
                radius: CGFloat?,
                amount: CGFloat?,
                textStyle: NSAttributedString.TextEffectStyle?,
                url: NSURL?

            init(style: NSAttributedString.TextEffectStyle?) {
                self.textStyle = style != nil ? style! : NSAttributedString.TextEffectStyle.letterpressStyle
            }

            init() {
                self.init(style: nil)
            }
        }

        struct Link: AttributedStyleProtocol {
            var style: NSUnderlineStyle?,
                color: UIColor?,
                width: CGFloat?,
                offset: CGSize?,
                radius: CGFloat?,
                amount: CGFloat?,
                textStyle: NSAttributedString.TextEffectStyle?,
                url: NSURL?

            init(url: NSURL?) {
                self.url = url != nil ? url! : NSURL(string: "")
            }

            init() {
                self.init(url: nil)
            }
        }

    }

    var attributes = (underline: Styles.Underline(),
                      outline: Styles.Outline(),
                      strikeThrough: Styles.Strikethrough(),
                      shadow: Styles.TextShadow(),
                      baselineOffset: Styles.BaselineOffset(),
                      skew: Styles.Skew(),
                      kern: Styles.Kern(),
                      highlight: Styles.Highlight(),
                      textColor: Styles.TextColor(),
                      textEffect: Styles.TextEffect(),
                      link: Styles.Link()
    )

    private var attributeFlags: [AttributeKeys: Bool] = [
            .underline: false,
            .outline: false,
            .strikeThrough: false,
            .shadow: false,
            .baselineOffset: false,
            .skew: false,
            .kern: false,
            .highlight: false,
            .textColor: false,
            .textEffect: false,
            .link: false
    ]

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.textColor = KDColor.black
        self.layer.masksToBounds = true
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
     Initializes without any automatic resizing.
     */
    convenience init(frame: CGRect, font: UIFont, text: String, _ alignment: NSTextAlignment = .left) {
        self.init(frame: frame)
        self.text = text
        self.textAlignment = alignment
    }

    /**
     Automatically sizes font to fit the given bounds by calling `fitTextToBounds()`.
     */
    convenience init(fitTextToFrame: CGRect, fontName: String, text: String, alignment: NSTextAlignment) {
        self.init(frame: fitTextToFrame)
        self.font = UIFont(name: fontName, size: 12)
        self.text = text
        self.textAlignment = alignment
        self.fitTextToBounds()
    }

    /**
     Automatically sizes font to fit the given bounds by calling `fitTextToBounds()`.
     `self.alignment` defaults to `.left`.
     */
    convenience init(fitTextToFrame: CGRect, fontName: String, text: String) {
        self.init(fitTextToFrame: fitTextToFrame, fontName: fontName, text: text, alignment: .left)
    }

    /**
     Automatically word wraps text and resizes the label height to fit the given font size and label width by calling `fitBoundsToText()`.
     Retains width, only resizes height.
     */
    convenience init(fitFrameToText: CGRect, fontName: String, fontSize: CGFloat, text: String, alignment: NSTextAlignment) {
        self.init(frame: fitFrameToText)
        self.font = UIFont(name: fontName, size: fontSize)
        self.text = text
        self.textAlignment = alignment
        self.fitBoundsToText()
    }

    /**
     Automatically word wraps text and resizes the label height to fit the given font size and label width by calling `fitBoundsToText()`.
     `self.alignment` defaults to `.left`.
     Retains width, only resizes height.
     */
    convenience init(fitFrameToText: CGRect, fontName: String, fontSize: CGFloat, text: String) {
        self.init(fitFrameToText: fitFrameToText, fontName: fontName, fontSize: fontSize, text: text, alignment: .left)
    }

    // //////////////////////////////
    // MARK: Resizing
    // //////////////////////////////

    /**
     Word wraps text and resizes the label height to fit the label width and font size.
     */
    @discardableResult func fitBoundsToText() -> KDLabel {
        let width = vw(self)
        self.numberOfLines = 0
        self.preferredMaxLayoutWidth = vw(self)
        self.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.sizeToFit()
        self.setWidth(width)
        return self
    }

    /**
     Sizes the label font to fit the label bounds. Requires the `font` property to already be set.
     */
    @discardableResult func fitTextToBounds() -> KDLabel {
        guard let text = self.text, let currentFont = self.font else { return self }
        let bestFittingFont = self.bestFittingFont(for: text, in: self.bounds, fontDescriptor: currentFont.fontDescriptor, additionalAttributes: basicStringAttributes)
        self.font = bestFittingFont
        return self
    }

    // //////////////////////////////
    // MARK: Attributed Style
    // //////////////////////////////

    /**
     Set the style and color for the `.underline` attribute. Does not automatically toggle the attribute on.
     Default values:
     ```
     style = .styleSingle
     color = KDColor.black
     ```
     */
    @discardableResult func setUnderline(_ style: NSUnderlineStyle?, _ color: UIColor?) -> KDLabel {
        self.attributes.underline.color = color != nil ? color! : self.attributes.underline.color
        self.attributes.underline.style = style != nil ? style! : self.attributes.underline.style
        return self
    }

    /**
     Set the width and color for the `.outline` attribute. Does not automatically toggle the attribute on.
     Default values:
     ```
     width = 3.0
     color = KDColor.grey
     ```
     */
    @discardableResult func setOutline(_ width: CGFloat?, _ color: UIColor?) -> KDLabel {
        self.attributes.outline.width = width != nil ? width! : self.attributes.outline.width
        self.attributes.outline.color = color != nil ? color! : self.attributes.outline.color
        return self
    }

    /**
     Set the style and color for the `.strikeThrough` attribute. Does not automatically toggle the attribute on.
     Default values:
     ```
     style = .styleSingle
     color = KDColor.black
     ```
     */
    @discardableResult func setStrikeThrough(_ style: NSUnderlineStyle?, _ color: UIColor?) -> KDLabel {
        self.attributes.strikeThrough.color = color != nil ? color! : self.attributes.strikeThrough.color
        self.attributes.strikeThrough.style = style != nil ? style! : self.attributes.strikeThrough.style
        return self
    }

    /**
     Set the offset, blur radius, and color for the `.shadow` attribute. Does not automatically toggle the attribute on.

     Default values:
     ```
     offset = CGSize(width: -1.0, height: -1.0)
     radius = CGFloat(1.0)
     color = KDColor.greys(3)
     ```
     */
    @discardableResult func setTextShadow(_ offset: CGSize?, _ radius: CGFloat?, _ color: UIColor?) -> KDLabel {
        self.attributes.shadow.offset = offset != nil ? offset! : self.attributes.shadow.offset
        self.attributes.shadow.radius = radius != nil ? radius! : self.attributes.shadow.radius
        self.attributes.shadow.color = color != nil ? color! : self.attributes.shadow.color
        return self
    }

    /**
     Set the offset, blur radius, and color for the `.shadow` attribute. Does not automatically toggle the attribute on.

     Default values:
     ```
     offset = CGSize(width: -1.0, height: -1.0)
     radius = CGFloat(1.0)
     color = KDColor.greys(3)
     ```
     */
    @discardableResult func setTextShadow(_ shadow: Styles.TextShadow) -> KDLabel {
        self.attributes.shadow.offset = shadow.offset != nil ? shadow.offset! : self.attributes.shadow.offset
        self.attributes.shadow.radius = shadow.radius != nil ? shadow.radius! : self.attributes.shadow.radius
        self.attributes.shadow.color = shadow.color != nil ? shadow.color! : self.attributes.shadow.color
        return self
    }

    /**
     Set the amount for the `.baselineOffset` attribute. Negative amounts lower the text. Does not automatically toggle the attribute on. Default value is `5.0`.
     */
    @discardableResult func setBaselineOffset(_ amount: CGFloat) -> KDLabel {
        self.attributes.baselineOffset.amount = amount
        return self
    }

    /**
     Set the amount for the `.skew` attribute. Negative amounts skew to the left. Does not automatically toggle the attribute on. Default value is `0.3`.
     */
    @discardableResult func setSkew(_ amount: CGFloat) -> KDLabel {
        self.attributes.skew.amount = amount
        return self
    }

    /**
     Set the amount for the `.kern` attribute. Negative amounts skew to the left. Does not automatically toggle the attribute on. Default value is `3.0`.
     */
    @discardableResult func setKern(_ amount: CGFloat) -> KDLabel {
        self.attributes.kern.amount = amount
        return self
    }


    /**
     Set the color for the `.highlight` attribute. Does not automatically toggle the attribute on. Default value is `KDColor.yellow`.
     */
    @discardableResult func setHighlight(_ color: UIColor) -> KDLabel {
        self.attributes.highlight.color = color
        return self
    }

    /**
     Set the style for the `.textEffect` attribute. Does not automatically toggle the attribute on. Default value is `.letterPress`.
     */
    @discardableResult func setTextEffect(_ effect: NSAttributedString.TextEffectStyle) -> KDLabel {
        self.attributes.textEffect.textStyle = effect
        return self
    }

    /**
     Set the url for the `.link` attribute. Does not automatically toggle the attribute on. Default value is an empty string.
     */
    @discardableResult func setLinkURL(_ url: NSURL) -> KDLabel {
        self.attributes.link.url = url
        return self
    }

    /**
     Show the attribute for the given key.
     */
    @discardableResult func show(_ attribute: AttributeKeys) -> KDLabel {
        self.attributeFlags[attribute] = true
        buildAndSetAttributedString()
        return self
    }

    /**
     Show all attributes listed in `attributes: [AtrributeKeys]`.
     */
    @discardableResult func show(_ attributes: [AttributeKeys]) -> KDLabel {
        for attribute in attributes {
            self.attributeFlags[attribute] = true
        }
        buildAndSetAttributedString()
        return self
    }

    /**
     Hide the attribute for the given key.
     */
    @discardableResult func hide(_ attribute: AttributeKeys) -> KDLabel {
        self.attributeFlags[attribute] = false
        buildAndSetAttributedString()
        return self
    }

    /**
     Hide all attributes listed in `attributes: [AtrributeKeys]`.
     */
    @discardableResult func hide(_ attributes: [AttributeKeys]) -> KDLabel {
        for attribute in attributes {
            self.attributeFlags[attribute] = false
        }
        buildAndSetAttributedString()
        return self
    }

    @discardableResult func setAttributes(_ attributes: [AttributeKeys: AttributedStyleProtocol], forSubString: String) -> KDLabel {
        guard let text = self.attributedText else { return self }
        let attributedString = NSMutableAttributedString(attributedString: text)
        let range = (attributedString.string as NSString).range(of: forSubString)

        for (key, style) in attributes {
            switch key {

            case .underline:
                attributedString.addAttributes([
                    NSAttributedString.Key.underlineStyle: style.style!.rawValue,
                    NSAttributedString.Key.underlineColor: style.color!
                ], range: range)

            case .outline:
                attributedString.addAttributes([
                    NSAttributedString.Key.strokeWidth: style.width!,
                    NSAttributedString.Key.strokeColor: style.color!
                ], range: range)

            case .strikeThrough:
                attributedString.addAttributes([
                    NSAttributedString.Key.strikethroughStyle: style.style!.rawValue,
                    NSAttributedString.Key.strikethroughColor: style.color!
                ], range: range)

            case .shadow:
                let shadow = NSShadow()
                shadow.shadowColor = style.color!
                shadow.shadowOffset = style.offset!
                shadow.shadowBlurRadius = style.radius!
                attributedString.addAttributes([
                    NSAttributedString.Key.shadow: shadow
                ], range: range)

            case .baselineOffset:
                attributedString.addAttributes([
                    NSAttributedString.Key.baselineOffset: style.amount!
                ], range: range)

            case .skew:
                attributedString.addAttributes([
                    NSAttributedString.Key.obliqueness: style.amount!
                ], range: range)

            case .kern:
                attributedString.addAttributes([
                    NSAttributedString.Key.kern: style.amount!
                ], range: range)

            case .highlight:
                attributedString.addAttributes([
                    NSAttributedString.Key.backgroundColor: style.color!
                ], range: range)

            case .textColor:
                attributedString.addAttributes([
                    NSAttributedString.Key.foregroundColor: style.color!
                ], range: range)

            case .textEffect:
                attributedString.addAttributes([
                    NSAttributedString.Key.textEffect: style.textStyle!
                ], range: range)

            case .link:
                attributedString.addAttributes([
                    NSAttributedString.Key.link: style.url!
                ], range: range)

            }
        }

        self.attributedText = attributedString
        return self
    }
// //////////////////////////////
// MARK: Label Property Setters
// //////////////////////////////

    /**
     Set the text.
     */
    @discardableResult func setText(_ text: String) -> KDLabel {
        self.text = text
        return self
    }

    /**
     Set the text color.
     */
    @discardableResult func setTextColor(_ color: UIColor) -> KDLabel {
        self.textColor = color
        return self
    }

    /**
     Set the text alignment.
     */
    @discardableResult func setTextAlignment(_ alignment: NSTextAlignment) -> KDLabel {
        self.textAlignment = alignment
        return self
    }

    /**
     Set the font.
     */
    @discardableResult func setFont(_ font: UIFont) -> KDLabel {
        self.font = font
        return self
    }

    /**
     Set the font name while retaining the existing font size.
     */
    @discardableResult func setFontName(_ fontName: String) -> KDLabel {
        self.font = UIFont(name: fontName, size: self.font.pointSize)
        return self
    }

    /**
     Set the font size while retaining the existing font name.
     */
    @discardableResult func setFontSize(_ fontSize: CGFloat) -> KDLabel {
        self.font = UIFont(name: self.font.fontName, size: fontSize)
        return self
    }



// //////////////////////////////
// MARK: Private Functions
// //////////////////////////////

    /**
     Check `self.attributeFlags` and build an appropriate attributed string using values in `self.attributes`. Then set `self.attributedString` to the new string.
     */
    private func buildAndSetAttributedString() {
        guard let text = self.text else { return }

        var attrs: [NSAttributedString.Key: Any] = [:]

        for (key, flag) in self.attributeFlags {
            if flag == true {
                switch key {
                case .underline:
                    attrs[NSAttributedString.Key.underlineStyle] = self.attributes.underline.style!.rawValue
                    attrs[NSAttributedString.Key.underlineColor] = self.attributes.underline.color!
                case .outline:
                    // use a negative value to set stroke and retain text fill color
                    attrs[NSAttributedString.Key.strokeWidth] = -self.attributes.outline.width!
                    attrs[NSAttributedString.Key.strokeColor] = self.attributes.outline.color!
                case .strikeThrough:
                    attrs[NSAttributedString.Key.strikethroughStyle] = self.attributes.strikeThrough.style!.rawValue
                    attrs[NSAttributedString.Key.strikethroughColor] = self.attributes.strikeThrough.color!
                case .shadow:
                    let shadow = NSShadow()
                    shadow.shadowColor = self.attributes.shadow.color!
                    shadow.shadowOffset = self.attributes.shadow.offset!
                    shadow.shadowBlurRadius = self.attributes.shadow.radius!
                    attrs[NSAttributedString.Key.shadow] = shadow
                case .baselineOffset:
                    attrs[NSAttributedString.Key.baselineOffset] = self.attributes.baselineOffset.amount!
                case .skew:
                    attrs[NSAttributedString.Key.obliqueness] = self.attributes.skew.amount!
                case .kern:
                    attrs[NSAttributedString.Key.kern] = self.attributes.kern.amount!
                case .highlight:
                    attrs[NSAttributedString.Key.backgroundColor] = self.attributes.highlight.color!
                case .textColor:
                    attrs[NSAttributedString.Key.foregroundColor] = self.attributes.textColor.color!
                case .textEffect:
                    attrs[NSAttributedString.Key.textEffect] = self.attributes.textEffect.textStyle!
                case .link:
                    attrs[NSAttributedString.Key.link] = self.attributes.link.url!
                }
            }
        }

        self.attributedText = NSAttributedString(string: text, attributes: attrs)

    }

    /**
     Will return the best font conforming to the descriptor which will fit in the provided bounds.
     */
    private func bestFittingFontSize(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> CGFloat {
        let constrainingDimension = min(bounds.width, bounds.height)
        let properBounds = CGRect(origin: .zero, size: bounds.size)
        var attributes = additionalAttributes ?? [:]

        let infiniteBounds = CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
        var bestFontSize: CGFloat = constrainingDimension

        for fontSize in stride(from: bestFontSize, through: 0, by: -1) {
            let newFont = UIFont(descriptor: fontDescriptor, size: fontSize)
            attributes[.font] = newFont

            let currentFrame = text.boundingRect(with: infiniteBounds, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: attributes, context: nil)

            if properBounds.contains(currentFrame) {
                bestFontSize = fontSize
                break
            }
        }
        return bestFontSize
    }

    /**
     Returns a new `UIFont` with a size that fits in the given bounds.
     */
    private func bestFittingFont(for text: String, in bounds: CGRect, fontDescriptor: UIFontDescriptor, additionalAttributes: [NSAttributedString.Key: Any]? = nil) -> UIFont {
        let bestSize = bestFittingFontSize(for: text, in: bounds, fontDescriptor: fontDescriptor, additionalAttributes: additionalAttributes)
        return UIFont(descriptor: fontDescriptor, size: bestSize)
    }

    /**
     Returns `alignment` and `lineBreakMode` attributes for `NSAttributedString`.
     */
    private var basicStringAttributes: [NSAttributedString.Key: Any] {
        var attrs = [NSAttributedString.Key: Any]()

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = self.textAlignment
        paragraphStyle.lineBreakMode = self.lineBreakMode
        attrs[.paragraphStyle] = paragraphStyle

        return attrs
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
    @discardableResult func addToSuperview(_ view: UIView) -> KDLabel {
        view.addSubview(self)
        return self
    }

// //////////////////////////////
// MARK: Color
// //////////////////////////////

    /**
     Set the background color for this view.
     */
    @discardableResult func setBackgroundColor(_ color: UIColor) -> KDLabel {
        self.backgroundColor = color
        return self
    }

    /**
     Sets `self.colorTheme` and updates the background, border, and shadow color to conform to the new theme.

     Use `self.colorTheme = newTheme` to set the theme property without updating the existing colors.
     */
    @discardableResult func setColorTheme(_ colorTheme: KDColorTheme) -> KDLabel {
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
    @discardableResult func setBorderWidth(_ width: CGFloat) -> KDLabel {
        self.layer.borderWidth = width
        return self
    }

    /**
     Set the color of the border for this view.
     */
    @discardableResult func setBorderColor(_ color: UIColor) -> KDLabel {
        self.layer.borderColor = color.cgColor
        return self
    }

    /**
     Set the roundness of the corners for this view.
     Update shadow to account for changes.
     */
    @discardableResult func setRoundness(_ roundness: CGFloat) -> KDLabel {
        self.layer.cornerRadius = roundness
        self.setShadowPath()
        return self
    }

    /**
     Convenience function for setting border properties for this view.
     */
    @discardableResult func setBorder(color: UIColor, width: CGFloat) -> KDLabel {
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
    @discardableResult func setBorder(width: CGFloat, roundness: CGFloat) -> KDLabel {
        setBorderWidth(width)
        setRoundness(roundness)
        return self
    }

    /**
     Convenience function for setting border properties for this view.
     */
    @discardableResult func setBorder(color: UIColor, width: CGFloat, roundness: CGFloat) -> KDLabel {
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
    @discardableResult func setShadow(_ shadow: Shadow?) -> KDLabel {
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
    @discardableResult func setShadowRadius(_ radius: CGFloat) -> KDLabel {
        self.layer.shadowRadius = radius
        setShadowPath()
        return self
    }

    /**
     Set the shadow offset and update the shadow path.
     */
    @discardableResult func setShadowOffset(_ x: CGFloat, _ y: CGFloat) -> KDLabel {
        self.layer.shadowOffset = CGSize(width: x, height: y)
        setShadowPath()
        return self
    }

    /**
     Set the shadow opacity and update the shadow path.
     */
    @discardableResult func setShadowOpacity(_ opacity: Float) -> KDLabel {
        self.layer.shadowOpacity = opacity
        setShadowPath()
        return self
    }

    /**
     Set the shadow color and update the shadow path.
     */
    @discardableResult func setShadowColor(_ color: UIColor) -> KDLabel {
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
    @discardableResult func setCenterX(_ x: CGFloat) -> KDLabel {
        self.center = CGPoint(x: x, y: self.center.y)
        return self
    }

    /**
     Set the center y position for this view.
     The center point is specified in points in the coordinate system of its superview.
     */
    @discardableResult func setCenterY(_ y: CGFloat) -> KDLabel {
        self.center = CGPoint(x: self.center.x, y: y)
        return self
    }

    /**
     Set the center point for this view.
     The center point is specified in points in the coordinate system of its superview.
     */
    @discardableResult func setCenter(_ x: CGFloat, _ y: CGFloat) -> KDLabel {
        self.center = CGPoint(x: x, y: y)
        return self
    }

    /**
     Set the center point for this view.
     */
    @discardableResult func setCenter(_ center: CGPoint) -> KDLabel {
        self.center = center
        return self
    }

    @discardableResult func centerOnParent () -> KDLabel {
        guard let superview = self.superview else { return self }
        self.setCenter(superview.bounds.width / 2, superview.bounds.height / 2)
        return self
    }

    /**
     Set the x origin for this view.
     Specified in points in the coordinate system of its superview.
     */
    @discardableResult func setOriginX(_ x: CGFloat) -> KDLabel {
        self.frame = CGRect(x: x, y: self.frame.origin.y, width: self.frame.size.width, height: self.frame.size.height)
        return self
    }

    /**
     Set the y origin for this view.
     Specified in points in the coordinate system of its superview.
     */
    @discardableResult func setOriginY(_ y: CGFloat) -> KDLabel {
        self.frame = CGRect(x: self.frame.origin.x, y: y, width: self.frame.size.width, height: self.frame.size.height)
        return self
    }

    /**
     Set the width of this view.
     */
    @discardableResult func setWidth(_ width: CGFloat) -> KDLabel {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: width, height: self.frame.size.height)
        return self
    }

    /**
     Set the height of this view.
     */
    @discardableResult func setHeight(_ height: CGFloat) -> KDLabel {
        self.frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: self.frame.size.width, height: height)
        return self
    }

    /**
     Set the size of this view.
     */
    @discardableResult func setSize(_ width: CGFloat, _ height: CGFloat) -> KDLabel {
        self.setWidth(width)
        self.setHeight(height)
        return self
    }

    /**
     Set the origin of this view.
     */
    @discardableResult func setOrigin(_ x: CGFloat, _ y: CGFloat) -> KDLabel {
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
    @discardableResult func setTopMargin(_ margin: CGFloat) -> KDLabel {
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
    @discardableResult func setBottomMargin(_ margin: CGFloat) -> KDLabel {
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
    @discardableResult func setLeftMargin(_ margin: CGFloat) -> KDLabel {
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
    @discardableResult func setRightMargin(_ margin: CGFloat) -> KDLabel {
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
    @discardableResult func setVerticalMargins(_ margin: CGFloat) -> KDLabel {
        setTopMargin(margin)
        setBottomMargin(margin)
        return self
    }

    /**
     Changes the frame of this view to add margins to the left and right.
     Moves the x origin and changes the width of the view by calling `setLeftMargin(margin:)` and `setRightMargin(margin:)`.
     */
    @discardableResult func setHorizontalMargins(_ margin: CGFloat) -> KDLabel {
        setLeftMargin(margin)
        setRightMargin(margin)
        return self
    }

    /**
     Changes the frame of this view to add margins on all sides.
     Moves the x and y origins and changes the height and width of the view by calling `setVerticalMargins(margin:)` and `setHorizontalMargins(margin:)`.
     */
    @discardableResult func setMargins(_ margin: CGFloat) -> KDLabel {
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
    @discardableResult func addTap() -> KDLabel {
        tap = UITapGestureRecognizer(target: self, action: #selector(didTap(sender:)))
        self.addGestureRecognizer(tap!)
        return self
    }

    /**
     Remove the `UITapGestureRecognizer` from this view and set the `tap` property to `nil`.
     */
    @discardableResult func removeTap() -> KDLabel {
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
    @discardableResult func addLongPress() -> KDLabel {
        longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(sender:)))
        self.addGestureRecognizer(longPress!)
        return self
    }

    /**
     Add a `UILongPressGestureRecognizer` as this views `tap` property.

     `duration:` is the `minimumPressDuration` of the gesture, which represents how long the user must press before the gesture is recognized.
     */
    @discardableResult func addLongPress(duration: Double) -> KDLabel {
        addLongPress()
        longPress?.minimumPressDuration = duration
        return self
    }

    /**
     Remove the `UILongPressGestureRecognizer` from this view and set the `longPress` property to `nil`.
     */
    @discardableResult func removeLongPress() -> KDLabel {
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
    @discardableResult func addSwipe() -> KDLabel {
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
    @discardableResult func addSwipe(_ direction: UISwipeGestureRecognizer.Direction) -> KDLabel {
        addSwipe()
        swipe?.direction = direction
        return self
    }

    /**
     Remove the `UISwipeGestureRecognizer` from this view and set the `swipe` property to `nil`.
     */
    @discardableResult func removeSwipe() -> KDLabel {
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
    @discardableResult func addPan() -> KDLabel {
        pan = UIPanGestureRecognizer(target: self, action: #selector(didPan(sender:)))
        self.addGestureRecognizer(pan!)
        return self
    }

    /**
     Remove the `UIPanGestureRecognizer` from this view and set the `pan` property to `nil`.
     */
    @discardableResult func removePan() -> KDLabel {
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
    @discardableResult func addPinch() -> KDLabel {
        pinch = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(sender:)))
        self.addGestureRecognizer(pinch!)
        return self
    }

    /**
     Remove the `UIPinchGestureRecognizer` from this view and set the `pinch` property to `nil`.
     */
    @discardableResult func removePinch() -> KDLabel {
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
