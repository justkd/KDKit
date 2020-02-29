import UIKit

/**
 This class is a descriptor for grouping colors. It's used throughout KDKit to simplify changing similar colors across views.
 */
class KDColorTheme {
    var background: UIColor,
        text: UIColor,
        border: UIColor,
        shadow: UIColor,
        contrast: UIColor,
        accent: UIColor

    init (background: UIColor?, text: UIColor?, border: UIColor?, shadow: UIColor?, contrast: UIColor?, accent: UIColor?) {

        let parameters = [background, text, border, shadow, contrast, accent]
        var colors = [UIColor](repeating: UIColor.clear, count: 6)

        for (index, param) in parameters.enumerated() {
            if param != nil {
                colors[index] = param!
            }
        }

        self.background = colors[0]
        self.text = colors[1]
        self.border = colors[2]
        self.shadow = colors[3]
        self.contrast = colors[4]
        self.accent = colors[5]
    }

    // //////////////////////////////
    // MARK: Convenience Inits
    // //////////////////////////////

    convenience init(background: UIColor?, text: UIColor?, border: UIColor?) {
        self.init(background: background, text: text, border: border, shadow: nil, contrast: nil, accent: nil)
    }

    convenience init(background: UIColor?, text: UIColor?, shadow: UIColor?) {
        self.init(background: background, text: text, border: nil, shadow: shadow, contrast: nil, accent: nil)
    }

    convenience init(background: UIColor?, text: UIColor?) {
        self.init(background: background, text: text, border: nil, shadow: nil, contrast: nil, accent: nil)
    }

    convenience init(background: UIColor?, border: UIColor?) {
        self.init(background: background, text: nil, border: border, shadow: nil, contrast: nil, accent: nil)
    }

    convenience init(background: UIColor?, border: UIColor?, shadow: UIColor?) {
        self.init(background: background, text: nil, border: border, shadow: shadow, contrast: nil, accent: nil)
    }

    convenience init(background: UIColor?, text: UIColor?, border: UIColor?, shadow: UIColor?) {
        self.init(background: background, text: text, border: border, shadow: shadow, contrast: nil, accent: nil)
    }

    convenience init(background: UIColor?, text: UIColor?, border: UIColor?, shadow: UIColor?, contrast: UIColor?) {
        self.init(background: background, text: text, border: border, shadow: shadow, contrast: contrast, accent: nil)
    }

    convenience init(background: UIColor?, border: UIColor?, shadow: UIColor?, contrast: UIColor?) {
        self.init(background: background, text: nil, border: border, shadow: shadow, contrast: contrast, accent: nil)
    }

    // //////////////////////////////
    // MARK: Class Functions
    // //////////////////////////////

    class func invertTheme(_ theme: KDColorTheme) -> KDColorTheme {
        return KDColorTheme(background: theme.background.invert(),
                            text: theme.text.invert(),
                            border: theme.border.invert(),
                            shadow: theme.shadow.invert(),
                            contrast: theme.contrast.invert(),
                            accent: theme.accent.invert())
    }

}
