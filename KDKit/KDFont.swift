import UIKit

/**
 Struct holding singletons for font parameters.

 Members and default values:
 ```
 static var paragraphFontName: String = "HelveticaNeue-Light"
 static var titleFontName: String = "Futura-CondensedExtraBold"
 static var subtitleFontName: String = "Futura-Medium"
 static var fontSize: [CGFloat] = [12, 24, 36, 48, 60, 72, 84, 96, 108, 120]

 static func printAllFontNames()
 ```
 */
struct KDFont {
    static var paragraphFontName: String = "HelveticaNeue-Light"
    static var headerFontName: String = "HelveticaNeue-Medium"
    static var titleFontName: String = "Futura-CondensedExtraBold"
    static var subtitleFontName: String = "Futura-Medium"

    private static var fontSize: [CGFloat] = [12, 24, 36, 48, 60, 72, 84, 96, 108, 120]

    static func paragraphFont() -> UIFont {
        guard let font = UIFont(name: KDFont.paragraphFontName, size: KDFont.fontSize(0)) else {
            return UIFont.systemFont(ofSize: 12)
        }
        return font
    }

    static func headerFont() -> UIFont {
        guard let font = UIFont(name: KDFont.headerFontName, size: KDFont.fontSize(1)) else {
            return UIFont.systemFont(ofSize: 24)
        }
        return font
    }

    static func subtitleFont() -> UIFont {
        guard let font = UIFont(name: KDFont.subtitleFontName, size: KDFont.fontSize(2)) else {
            return UIFont.systemFont(ofSize: 36)
        }
        return font
    }

    static func titleFont() -> UIFont {
        guard let font = UIFont(name: KDFont.titleFontName, size: KDFont.fontSize(3)) else {
            return UIFont.systemFont(ofSize: 48)
        }
        return font
    }

    static func fontSize(_ index: Int) -> CGFloat {
        return fontSize[index]
    }

    static func setSizeForIndex(_ index: Int, _ size: CGFloat) {
        fontSize[index] = size
    }

    static func printAllFontNames() {
        for family in UIFont.familyNames {
            print("\nFamily: " + family)
            for font in UIFont.fontNames(forFamilyName: family) {
                print("    " + font)
            }
        }
    }
}
