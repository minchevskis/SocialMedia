//
//  UIColor.swift
//  SocialMedia
//
//  Created by Stefan Minchevski on 11/9/20.
//

import Foundation
import UIKit

extension UIColor {
    /**
        Creates an UIColor from HEX String in "#363636" format
        - parameter hexString: HEX String in "#363636" format
        - returns: UIColor from HexString
        */
       convenience init(hex: String) {
           var hexFormatted: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
           if hexFormatted.hasPrefix("#") {
               hexFormatted = String(hexFormatted.dropFirst())
           }
           assert(hexFormatted.count == 6, "Invalid hex code used.")
           let scanner = Scanner(string: hexFormatted as String)
           var color: UInt64 = 0
           scanner.scanHexInt64(&color)
           let mask = 0x000000FF
           let r = Int(color >> 16) & mask
           let g = Int(color >> 8) & mask
           let b = Int(color) & mask
           let red   = CGFloat(r) / 255.0
           let green = CGFloat(g) / 255.0
           let blue  = CGFloat(b) / 255.0
           self.init(red: red, green: green, blue: blue, alpha: 1)
       }
       /**
        Creates an UIColor Object based on provided RGB value in integer
        - parameter red:   Red Value in integer (0-255)
        - parameter green: Green Value in integer (0-255)
        - parameter blue:  Blue Value in integer (0-255)
        - returns: UIColor with specified RGB values
        */
       convenience init(red: Int, green: Int, blue: Int) {
           assert(red >= 0 && red <= 255, "Invalid red component")
           assert(green >= 0 && green <= 255, "Invalid green component")
           assert(blue >= 0 && blue <= 255, "Invalid blue component")
           self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
       }
       var hexString: String {
           let colorRef = cgColor.components
           let r = colorRef?[0] ?? 0
           let g = colorRef?[1] ?? 0
           let b = ((colorRef?.count ?? 0) > 2 ? colorRef?[2] : g) ?? 0
           let a = cgColor.alpha
           var color = String(
               format: "#%02lX%02lX%02lX",
               lroundf(Float(r * 255)),
               lroundf(Float(g * 255)),
               lroundf(Float(b * 255))
           )
           if a < 1 {
               color += String(format: "%02lX", lroundf(Float(a)))
           }
           return color
       }
}
