//
//  DoubleExtension.swift
//  trafie
//
//  Created by mathiou on 12/02/2017.
//  Copyright © 2017 Mathioudakis Theodore. All rights reserved.
//

import Foundation

extension Double {
  /// Rounds the double to decimal places value
  func roundTo(places:Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
}
