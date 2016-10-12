//
//  UIElements.swift
//  trafie
//
//  Created by mathiou on 27/11/15.
//  Copyright © 2015 Mathioudakis Theodore. All rights reserved.
//

import UIKit
import Whisper

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
let IF_PLACEHOLDER_FONT = UIFont.systemFont(ofSize: 16.0) // match with CLR_MEDIUM_GRAY
let IF_STANDARD_FONT = UIFont.systemFont(ofSize: 17.0) // match with CLR_DARK_GRAY

// MARK:- Images
/**
 Get's an image-icon and apply a specific color over it
 - Parameter imageView: the imageView that contains the icon
 - Parameter iconName: the name of the image
 - Parameter color: the color UIColor
 */
func setIconWithColor(_ imageView: UIImageView, iconName: String, color: UIColor) {
  imageView.image = UIImage(named: iconName)
  imageView.image = imageView.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
  imageView.tintColor = color
}

// MARK:- Whisper Component Notifications
/**
 Display a whisper. It's a short message at the bottom of the navigation bar, this can be anything, from a "Great Job!" to an error message.
 - Parameter state: the state which follow StatusBarNotificationState enum
 - Parameter message: the text we want to be appeared
 - Parameter navigationController: the current controller.
 */
func showWhisper(_ state: StatusBarNotificationState, message: String, navigationController: UINavigationController) {
  var _message : Message
  switch(state) {
  case .Error: //red variation
    _message = Message(title: message, backgroundColor: CLR_NOTIFICATION_RED)
  case .Warning: //orange variation
    _message = Message(title: message, backgroundColor: CLR_NOTIFICATION_ORANGE)
  case .Success: //green variation
    _message = Message(title: message, backgroundColor: CLR_NOTIFICATION_GREEN)
  case .Info: //blue variation
    _message = Message(title: message, backgroundColor: CLR_NOTIFICATION_BLUE)
  }
  
  show(whisper: _message, to: navigationController, action: .show)
}

/**
 Hides a whisper
 - Parameter navigationController: the current controller.
 */
func hideWhisper(navigationController: UINavigationController) {
  hide(whisperFrom: navigationController)
}

/**
 Shows a notification on top of navigation bar
 - Parameter message: the text we want to be appeared
 - Parameter delay: Float (internally converted to TimeInterval
 */
func showWhistle(_ message: String, delay: Float?=0) {
  let murmur = Murmur(title: message)
  if delay != 0 {
    show(whistle: murmur, action: .show(TimeInterval(delay!)))
  } else {
    show(whistle: murmur)
  }

}

/**
 Hides a whistle
 */
func hideWhistle(delay: Float) {
  hide(whistleAfter: TimeInterval(delay))
}




