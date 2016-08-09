//
//  UIImageExtension.swift
//  trafie
//
//  Created by mathiou on 09/08/16.
//  Copyright © 2016 Mathioudakis Theodore. All rights reserved.
//

import Foundation

extension UIImage {

  func resizeToPercentage(percentage: CGFloat) -> UIImage? {
    let newSize: CGSize = CGSize(width: size.width * percentage, height: size.height * percentage)
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRectMake(0, 0, newSize.width, newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, percentage)
    drawInRect(rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }

  /**
   Resize a UIImage based on a given width.
   - Parameter image: UIImage
   - Parameter width: CGFloat
   - Returns: The UIImage object
   */
   func resizeToWidth(width: CGFloat) -> UIImage {
    let ratio  = width / size.width
    let newSize: CGSize = CGSize(width: size.width * ratio, height: size.height * ratio)
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRectMake(0, 0, newSize.width, newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    drawInRect(rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
  
  /**
   Resize a UIImage to a target size.
   - Parameter image: UIImage
   - Parameter targetSize: CGSize
   - Returns: The UIImage object
   */
  func resizeToTargetSize(targetSize: CGSize) -> UIImage {

    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
      newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
    } else {
      newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRectMake(0, 0, newSize.width, newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    drawInRect(rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage
  }
  
  /**
   Returns the size of image in bytes from a JPEGRepresentation
   / TODO: enhance to handle jpeg and png formats (parameterize UIImageJPEGRepresentation and UIImagePNGRepresentation).
   */
  func getByteSize() -> Double {
    let imgData: NSData = NSData(data: UIImageJPEGRepresentation(self, 1)!)
    return Double(imgData.length)
  }
}