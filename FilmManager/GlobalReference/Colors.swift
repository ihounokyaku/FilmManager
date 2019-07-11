//
//  Colors.swift
//  FilmSwipe
//
//  Created by Dylan Southard on 2018/09/27.
//  Copyright © 2018 Dylan Southard. All rights reserved.
//

import Foundation
import Cocoa

extension NSColor {
    
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
    
    
    static func BlackBackgroundPrimary(alpha:CGFloat = 1)-> NSColor{
        return NSColor(hexString: "#252A26").withAlphaComponent(alpha)
    }
    static func OffWhitePrimary(alpha:CGFloat = 1)-> NSColor{
        return NSColor(hexString: "#EEF2FA").withAlphaComponent(alpha)
    }
    static func ColorSecondaryDark(alpha:CGFloat = 1)-> NSColor{
        return NSColor(hexString: "#638278").withAlphaComponent(alpha)
    }
    static func ColorSecondaryLight(alpha:CGFloat = 1)-> NSColor{
        return NSColor(hexString: "#9BD5BF").withAlphaComponent(alpha)
    }
    static func ColorEmphasisDark(alpha:CGFloat = 1)-> NSColor{
        return NSColor(hexString: "#C1553E").withAlphaComponent(alpha)
    }
    static func WhitePrimary(alpha:CGFloat = 1)-> NSColor{
        return NSColor(hexString: "#EFEFEF").withAlphaComponent(alpha)
    }
    static func TextDarkPrimary(alpha:CGFloat = 1)-> NSColor{
        return NSColor(hexString: "#1D1E20").withAlphaComponent(alpha)
    }
    static func TextLightPrimary(alpha:CGFloat = 1)-> NSColor{
        return NSColor.OffWhitePrimary(alpha:alpha)
    }
    static func ColorTextEmphasis(alpha:CGFloat = 1)-> NSColor{
        return NSColor(hexString: "#C1553E").withAlphaComponent(alpha)
    }
    static func ColorTextEmphasisLight(alpha:CGFloat = 1)-> NSColor{
        return NSColor(hexString: "#D07163").withAlphaComponent(alpha)
    }
   
    
    static var SelectorWhite:NSColor {
        return NSColor.OffWhitePrimary(alpha:0.4)
    }
    
    
    
    
    func fromHexWithAlpha(hex:String, alpha:CGFloat)-> NSColor{
        let color = NSColor(hexString: hex)
        return color.withAlphaComponent(alpha)
    }
}

