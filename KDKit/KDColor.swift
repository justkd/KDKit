import UIKit

/**
 Stored color values.

 ```
 black
 white
 clear

 pink
 purple
 violet
 indigo

 blue
 azure
 cyan

 teal
 green
 olive
 lime

 yellow
 amber
 orange
 auburn
 red

 brown
 grey
 steel
 ```

 Each color has nine shades ordered lightest to darkest, and accessed by passing a valid integer (1-9) to the function.
 (eg. `KDColor.blues(3)`)

 Each color has a shortcut that returns the middle shade.
 (eg. `KDColor.red` returns `KDColor.reds(5)`)

 Black and white are shortcuts that return the lightest and darkest grey scale shades.

 Clear returns `UIColor.clear`.

 */
struct KDColor {

    static var white: UIColor { return greys(1) }
    static var black: UIColor { return greys(9) }
    static var clear: UIColor { return UIColor.clear }

    static var red: UIColor { return reds(5) }
    static var reds: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(255, 205, 210, 1)
        case 2:
            return rgba(239, 154, 154, 1)
        case 3:
            return rgba(229, 115, 115, 1)
        case 4:
            return rgba(239, 83, 80, 1)
        case 5:
            return rgba(244, 67, 54, 1)
        case 6:
            return rgba(229, 57, 53, 1)
        case 7:
            return rgba(211, 47, 47, 1)
        case 8:
            return rgba(198, 40, 40, 1)
        case 9:
            return rgba(183, 28, 28, 1)
        default:
            return KDColor.red
        }
    }

    static var pink: UIColor { return pinks(5) }
    static var pinks: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(248, 187, 208, 1)
        case 2:
            return rgba(244, 143, 177, 1)
        case 3:
            return rgba(240, 98, 146, 1)
        case 4:
            return rgba(236, 64, 122, 1)
        case 5:
            return rgba(233, 30, 99, 1)
        case 6:
            return rgba(216, 27, 96, 1)
        case 7:
            return rgba(194, 24, 91, 1)
        case 8:
            return rgba(173, 20, 87, 1)
        case 9:
            return rgba(136, 14, 79, 1)
        default:
            return KDColor.pink
        }
    }

    static var purple: UIColor { return purples(5) }
    static var purples: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(225, 190, 231, 1)
        case 2:
            return rgba(206, 147, 216, 1)
        case 3:
            return rgba(186, 104, 200, 1)
        case 4:
            return rgba(171, 71, 188, 1)
        case 5:
            return rgba(156, 39, 176, 1)
        case 6:
            return rgba(142, 36, 170, 1)
        case 7:
            return rgba(123, 31, 162, 1)
        case 8:
            return rgba(106, 27, 154, 1)
        case 9:
            return rgba(74, 20, 140, 1)
        default:
            return KDColor.purple
        }
    }

    static var violet: UIColor { return violets(5) }
    static var violets: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(209, 196, 233, 1)
        case 2:
            return rgba(179, 157, 219, 1)
        case 3:
            return rgba(149, 117, 205, 1)
        case 4:
            return rgba(126, 87, 194, 1)
        case 5:
            return rgba(103, 58, 183, 1)
        case 6:
            return rgba(94, 53, 177, 1)
        case 7:
            return rgba(81, 45, 168, 1)
        case 8:
            return rgba(69, 39, 160, 1)
        case 9:
            return rgba(49, 27, 146, 1)
        default:
            return KDColor.violet
        }
    }

    static var indigo: UIColor { return indigos(5) }
    static var indigos: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(197, 202, 233, 1)
        case 2:
            return rgba(159, 168, 218, 1)
        case 3:
            return rgba(121, 134, 203, 1)
        case 4:
            return rgba(92, 107, 192, 1)
        case 5:
            return rgba(63, 81, 181, 1)
        case 6:
            return rgba(57, 73, 171, 1)
        case 7:
            return rgba(48, 63, 159, 1)
        case 8:
            return rgba(40, 53, 147, 1)
        case 9:
            return rgba(26, 35, 126, 1)
        default:
            return KDColor.indigo
        }
    }

    static var blue: UIColor { return blues(5) }
    static var blues: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(187, 222, 251, 1)
        case 2:
            return rgba(144, 202, 249, 1)
        case 3:
            return rgba(100, 181, 246, 1)
        case 4:
            return rgba(66, 165, 245, 1)
        case 5:
            return rgba(33, 150, 243, 1)
        case 6:
            return rgba(30, 136, 229, 1)
        case 7:
            return rgba(25, 118, 210, 1)
        case 8:
            return rgba(21, 101, 192, 1)
        case 9:
            return rgba(13, 71, 161, 1)
        default:
            return KDColor.blue
        }
    }

    static var azure: UIColor { return azures(5) }
    static var azures: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(179, 229, 252, 1)
        case 2:
            return rgba(129, 212, 250, 1)
        case 3:
            return rgba(79, 195, 247, 1)
        case 4:
            return rgba(41, 182, 246, 1)
        case 5:
            return rgba(3, 169, 244, 1)
        case 6:
            return rgba(3, 155, 229, 1)
        case 7:
            return rgba(2, 136, 209, 1)
        case 8:
            return rgba(2, 119, 189, 1)
        case 9:
            return rgba(1, 87, 155, 1)
        default:
            return KDColor.azure
        }
    }

    static var cyan: UIColor { return cyans(5) }
    static var cyans: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(178, 235, 242, 1)
        case 2:
            return rgba(128, 222, 234, 1)
        case 3:
            return rgba(77, 208, 225, 1)
        case 4:
            return rgba(38, 198, 218, 1)
        case 5:
            return rgba(0, 188, 212, 1)
        case 6:
            return rgba(0, 172, 193, 1)
        case 7:
            return rgba(0, 151, 167, 1)
        case 8:
            return rgba(0, 131, 143, 1)
        case 9:
            return rgba(0, 96, 100, 1)
        default:
            return KDColor.cyan
        }
    }

    static var teal: UIColor { return teals(5) }
    static var teals: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(178, 223, 219, 1)
        case 2:
            return rgba(128, 203, 196, 1)
        case 3:
            return rgba(77, 182, 172, 1)
        case 4:
            return rgba(38, 166, 154, 1)
        case 5:
            return rgba(0, 150, 136, 1)
        case 6:
            return rgba(0, 137, 123, 1)
        case 7:
            return rgba(0, 121, 107, 1)
        case 8:
            return rgba(0, 105, 92, 1)
        case 9:
            return rgba(0, 77, 64, 1)
        default:
            return KDColor.teal
        }
    }

    static var green: UIColor { return greens(5) }
    static var greens: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(200, 230, 201, 1)
        case 2:
            return rgba(165, 214, 167, 1)
        case 3:
            return rgba(129, 199, 132, 1)
        case 4:
            return rgba(102, 187, 106, 1)
        case 5:
            return rgba(76, 175, 80, 1)
        case 6:
            return rgba(67, 160, 71, 1)
        case 7:
            return rgba(56, 142, 60, 1)
        case 8:
            return rgba(46, 125, 50, 1)
        case 9:
            return rgba(27, 94, 32, 1)
        default:
            return KDColor.green
        }
    }

    static var olive: UIColor { return olives(5) }
    static var olives: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(220, 237, 200, 1)
        case 2:
            return rgba(197, 225, 165, 1)
        case 3:
            return rgba(174, 213, 129, 1)
        case 4:
            return rgba(156, 204, 101, 1)
        case 5:
            return rgba(139, 195, 74, 1)
        case 6:
            return rgba(124, 179, 66, 1)
        case 7:
            return rgba(104, 159, 56, 1)
        case 8:
            return rgba(85, 139, 47, 1)
        case 9:
            return rgba(51, 105, 30, 1)
        default:
            return KDColor.olive
        }
    }

    static var lime: UIColor { return limes(5) }
    static var limes: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(240, 244, 195, 1)
        case 2:
            return rgba(230, 238, 156, 1)
        case 3:
            return rgba(220, 231, 117, 1)
        case 4:
            return rgba(212, 225, 87, 1)
        case 5:
            return rgba(205, 220, 57, 1)
        case 6:
            return rgba(192, 202, 51, 1)
        case 7:
            return rgba(175, 180, 43, 1)
        case 8:
            return rgba(158, 157, 36, 1)
        case 9:
            return rgba(130, 119, 23, 1)
        default:
            return KDColor.lime
        }
    }

    static var yellow: UIColor { return yellows(5) }
    static var yellows: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(255, 249, 196, 1)
        case 2:
            return rgba(255, 245, 157, 1)
        case 3:
            return rgba(255, 241, 118, 1)
        case 4:
            return rgba(255, 238, 88, 1)
        case 5:
            return rgba(255, 235, 59, 1)
        case 6:
            return rgba(253, 216, 53, 1)
        case 7:
            return rgba(251, 192, 45, 1)
        case 8:
            return rgba(249, 168, 37, 1)
        case 9:
            return rgba(245, 127, 23, 1)
        default:
            return KDColor.yellow
        }
    }


    static var amber: UIColor { return ambers(5) }
    static var ambers: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(255, 236, 179, 1)
        case 2:
            return rgba(255, 224, 130, 1)
        case 3:
            return rgba(255, 213, 79, 1)
        case 4:
            return rgba(255, 202, 40, 1)
        case 5:
            return rgba(255, 193, 7, 1)
        case 6:
            return rgba(255, 179, 0, 1)
        case 7:
            return rgba(255, 160, 0, 1)
        case 8:
            return rgba(255, 143, 0, 1)
        case 9:
            return rgba(255, 111, 0, 1)
        default:
            return KDColor.amber
        }
    }

    static var orange: UIColor { return oranges(5) }
    static var oranges: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(255, 224, 178, 1)
        case 2:
            return rgba(255, 204, 128, 1)
        case 3:
            return rgba(255, 183, 77, 1)
        case 4:
            return rgba(255, 167, 38, 1)
        case 5:
            return rgba(255, 152, 0, 1)
        case 6:
            return rgba(251, 140, 0, 1)
        case 7:
            return rgba(245, 124, 0, 1)
        case 8:
            return rgba(239, 108, 0, 1)
        case 9:
            return rgba(230, 81, 0, 1)
        default:
            return KDColor.orange
        }
    }

    static var auburn: UIColor { return auburns(5) }
    static var auburns: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(255, 204, 188, 1)
        case 2:
            return rgba(255, 171, 145, 1)
        case 3:
            return rgba(255, 138, 101, 1)
        case 4:
            return rgba(255, 112, 67, 1)
        case 5:
            return rgba(255, 87, 34, 1)
        case 6:
            return rgba(244, 81, 30, 1)
        case 7:
            return rgba(230, 74, 25, 1)
        case 8:
            return rgba(216, 67, 21, 1)
        case 9:
            return rgba(191, 54, 12, 1)
        default:
            return KDColor.auburn
        }
    }

    static var brown: UIColor { return browns(5) }
    static var browns: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(215, 204, 200, 1)
        case 2:
            return rgba(188, 170, 164, 1)
        case 3:
            return rgba(161, 136, 127, 1)
        case 4:
            return rgba(141, 110, 99, 1)
        case 5:
            return rgba(121, 85, 72, 1)
        case 6:
            return rgba(109, 76, 65, 1)
        case 7:
            return rgba(93, 64, 55, 1)
        case 8:
            return rgba(78, 52, 46, 1)
        case 9:
            return rgba(62, 39, 35, 1)
        default:
            return KDColor.brown
        }
    }

    static var grey: UIColor { return greys(5) }
    static var greys: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(245, 245, 245, 1)
        case 2:
            return rgba(238, 238, 238, 1)
        case 3:
            return rgba(224, 224, 224, 1)
        case 4:
            return rgba(189, 189, 189, 1)
        case 5:
            return rgba(158, 158, 158, 1)
        case 6:
            return rgba(117, 117, 117, 1)
        case 7:
            return rgba(97, 97, 97, 1)
        case 8:
            return rgba(66, 66, 66, 1)
        case 9:
            return rgba(33, 33, 33, 1)
        default:
            return KDColor.grey
        }
    }

    static var steel: UIColor { return steels(5) }
    static var steels: (Int?) -> (UIColor) = { num in
        switch num {
        case 1:
            return rgba(207, 216, 220, 1)
        case 2:
            return rgba(176, 190, 197, 1)
        case 3:
            return rgba(144, 164, 174, 1)
        case 4:
            return rgba(120, 144, 156, 1)
        case 5:
            return rgba(96, 125, 139, 1)
        case 6:
            return rgba(84, 110, 122, 1)
        case 7:
            return rgba(69, 90, 100, 1)
        case 8:
            return rgba(55, 71, 79, 1)
        case 9:
            return rgba(38, 50, 56, 1)
        default:
            return KDColor.steel
        }
    }

}
