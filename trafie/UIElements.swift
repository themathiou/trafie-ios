//
//  UIElements.swift
//  trafie
//
//  Created by mathiou on 27/11/15.
//  Copyright © 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit

// MARK:- Text Constants
let ABOUT_PLACEHOLDER_TEXT = "About you (up to 400 characters)"

// MARK:- Colors
// MARK: Pallete
let CLR_TRAFIE_RED: UIColor = UIColor(rgba: "#c03509")
let CLR_LIGHT_GRAY: UIColor = UIColor(rgba: "#E8E8E8")
let CLR_MEDIUM_GRAY: UIColor = UIColor(rgba: "#979797")
let CLR_DARK_GRAY: UIColor = UIColor(rgba: "#333333")


// MARK: Notifications Colors
let CLR_NOTIFICATION_GREEN: UIColor = UIColor(rgba: "#C0D860")
let CLR_NOTIFICATION_RED: UIColor = UIColor(rgba: "#DF6867")
let CLR_NOTIFICATION_ORANGE: UIColor = UIColor(rgba: "#FFCE83")
let CLR_NOTIFICATION_BLUE: UIColor = UIColor(rgba: "#307BCF")
let CLR_NOTIFICATION_YELLOW: UIColor = UIColor(rgba: "#F8CA00")


// MARK:- Typography
// MARK: Input Fields
let IF_PLACEHOLDER_FONT = UIFont.systemFontOfSize(16.0) // match with CLR_MEDIUM_GRAY
let IF_STANDARD_FONT = UIFont.systemFontOfSize(17.0) // match with CLR_DARK_GRAY

// MARK:- Buttons
let keyboardButtonCentered: UIButton = UIButton (frame: CGRectMake(100, 100, 100, 40))

// MARK:- Images
/**
 Get's an image-icon and apply a specific color over it
 - Parameter imageView: the imageView that contains the icon
 - Parameter iconName: the name of the image
 - Parameter color: the color UIColor
 */
func setIconWithColor(imageView: UIImageView, iconName: String, color: UIColor) {
  imageView.image = UIImage(named: iconName)
  imageView.image = imageView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
  imageView.tintColor = color
}

// MARK:- StatusBar Notification customization
func setNotificationState(state: StatusBarNotificationState, notification: CWStatusBarNotification, style: CWNotificationStyle) {
  notification.notificationAnimationInStyle = .Top
  notification.notificationAnimationOutStyle = .Top
  notification.notificationStyle = style
  notification.notificationLabelFont = UIFont.systemFontOfSize(16.0, weight: UIFontWeightLight)
  
  switch(state) {
  case .Error: //red variation
    notification.notificationLabelBackgroundColor = CLR_NOTIFICATION_RED
    notification.notificationLabelTextColor = UIColor.whiteColor()
  case .Warning: //orange variation
    notification.notificationLabelBackgroundColor = CLR_NOTIFICATION_ORANGE
    notification.notificationLabelTextColor = UIColor.whiteColor()
  case .Success: //green variation
    notification.notificationLabelBackgroundColor = CLR_NOTIFICATION_GREEN
    notification.notificationLabelTextColor = UIColor.whiteColor()
  case .Info: //blue variation
    notification.notificationLabelBackgroundColor = CLR_NOTIFICATION_BLUE
    notification.notificationLabelTextColor = UIColor.lightTextColor()
  }
}
