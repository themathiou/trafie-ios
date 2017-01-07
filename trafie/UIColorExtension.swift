//
//  UIColorExtension.swift
//  Created by R0CKSTAR on 6/13/14.
//  Copyright (c) 2014 P.D.Q. All rights reserved.
//  Updated to Swift > 2 by Mathioudakis Theodore
//

import UIKit

extension UIColor {
  convenience init(rgba: String) {
    var red:   CGFloat = 0.0
    var green: CGFloat = 0.0
    var blue:  CGFloat = 0.0
    var alpha: CGFloat = 1.0
    
    if rgba.hasPrefix("#") {
      let index   = rgba.characters.index(rgba.startIndex, offsetBy: 1)
      let hex: String = rgba.substring(from: index)
      let scanner = Scanner(string: hex)
      var hexValue: CUnsignedLongLong = 0
      if scanner.scanHexInt64(&hexValue) {
        switch (hex.characters.count) {
        case 3:
          red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
          green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
          blue  = CGFloat(hexValue & 0x00F)              / 15.0
        case 4:
          red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
          green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
          blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
          alpha = CGFloat(hexValue & 0x000F)             / 15.0
        case 6:
          red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
          green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
          blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
        case 8:
          red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
          green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
          blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
          alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
        default:
          Utils.log("Invalid RGB string, number of characters after '#' should be either 3, 4, 6 or 8")
        }
      } else {
        Utils.log("Scan hex error")
      }
    } else {
      Utils.log("Invalid RGB string, missing '#' as prefix")
    }
    self.init(red:red, green:green, blue:blue, alpha:alpha)
  }
  
  // Convert a hex string to a UIColor object.
  class func colorFromHex(hexString:String) -> UIColor {
    
    func clean(hexString: String) -> String {
      
      var cleanedHexString = String()
      
      // Remove the leading "#"
      if(hexString[hexString.startIndex] == "#") {
        cleanedHexString = hexString.substring(from: hexString.characters.index(hexString.startIndex, offsetBy: 1))
      }
      
      // TODO: Other cleanup. Allow for a "short" hex string, i.e., "#fff"
      
      return cleanedHexString
    }
    
    let cleanedHexString = clean(hexString: hexString)
    
    // If we can get a cached version of the colour, get out early.
//    if let cachedColor = UIColor.getColorFromCache(hexString: cleanedHexString) {
//      return cachedColor
//    }
    
    // Else create the color, store it in the cache and return.
    let scanner = Scanner(string: cleanedHexString)
    
    var value:UInt32 = 0
    
    // We have the hex value, grab the red, green, blue and alpha values.
    // Have to pass value by reference, scanner modifies this directly as the result of scanning the hex string. The return value is the success or fail.
    if(scanner.scanHexInt32(&value)){
      
      // intValue = 01010101 11110111 11101010    // binary
      // intValue = 55       F7       EA          // hexadecimal
      
      //                     r
      //   00000000 00000000 01010101 intValue >> 16
      // & 00000000 00000000 11111111 mask
      //   ==========================
      // = 00000000 00000000 01010101 red
      
      //            r        g
      //   00000000 01010101 11110111 intValue >> 8
      // & 00000000 00000000 11111111 mask
      //   ==========================
      // = 00000000 00000000 11110111 green
      
      //   r        g        b
      //   01010101 11110111 11101010 intValue
      // & 00000000 00000000 11111111 mask
      //   ==========================
      // = 00000000 00000000 11101010 blue
      
      let intValue = UInt32(value)
      let mask:UInt32 = 0xFF
      
      let red = intValue >> 16 & mask
      let green = intValue >> 8 & mask
      let blue = intValue & mask
      
      // red, green, blue and alpha are currently between 0 and 255
      // We want to normalise these values between 0 and 1 to use with UIColor.
      let colors:[UInt32] = [red, green, blue]
      let normalised = normalise(colors: colors)
      
      let newColor = UIColor(red: normalised[0], green: normalised[1], blue: normalised[2], alpha: 1)
      //UIColor.storeColorInCache(hexString: cleanedHexString, color: newColor)
      
      return newColor
      
    }
      // We couldn't get a value from a valid hex string.
    else {
      print("Error: Couldn't convert the hex string to a number, returning UIColor.whiteColor() instead.")
      return UIColor.white
    }
  }
  
  // Takes an array of colours in the range of 0-255 and returns a value between 0 and 1.
  private class func normalise(colors: [UInt32]) -> [CGFloat]{
    var normalisedVersions = [CGFloat]()
    
    for color in colors{
      normalisedVersions.append(CGFloat(color % 256) / 255)
    }
    
    return normalisedVersions
  }
}
