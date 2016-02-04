//
//  UIElements.swift
//  trafie
//
//  Created by mathiou on 27/11/15.
//  Copyright © 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
// MARK:- Text Constants
let ABOUT_PLACEHOLDER_TEXT = "About you (up to 200 characters)"

// MARK:- Colors
// MARK: Pallete
let CLR_TRAFIE_RED: UIColor = UIColor(rgba: "#c03509")
let CLR_LIGHT_GRAY: UIColor = UIColor(rgba: "#E8E8E8")
let CLR_MEDIUM_GRAY: UIColor = UIColor(rgba: "#979797")
let CLR_DARK_GRAY: UIColor = UIColor(rgba: "#333333")


// MARK: Notifications Colors
let CLR_NOTIFICATION_GREEN: UIColor = UIColor(rgba: "#8CB56B" )
let CLR_NOTIFICATION_RED: UIColor = UIColor(rgba: "#DB0F13")
let CLR_NOTIFICATION_ORANGE: UIColor = UIColor(rgba: "#FA6900")
let CLR_NOTIFICATION_YELLOW: UIColor = UIColor(rgba: "#F8CA00")


// MARK:- Typography
// MARK: Input Fields
let IF_PLACEHOLDER_FONT = UIFont.systemFontOfSize(16.0) // match with CLR_MEDIUM_GRAY
let IF_STANDARD_FONT = UIFont.systemFontOfSize(17.0) // match with CLR_DARK_GRAY

// MARK:- Buttons
let keyboardButtonCentered: UIButton = UIButton (frame: CGRectMake(100, 100, 100, 40))

// MARK:- Images
func setIconWithColor(imageView: UIImageView, iconName: String, color: UIColor) {
    imageView.image = UIImage(named: iconName)
    imageView.image = imageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    imageView.tintColor = color
}