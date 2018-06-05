//
//  Double+Extension.swift
//  CanvasQuake
//
//  Created by Adrian Bolinger on 6/2/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import Foundation

extension Double {
//extension FloatingPoint {

  /// Rounds the double to decimal places value
  func rounded(toPlaces places:Int) -> Double {
    let divisor = pow(10.0, Double(places))
    return (self * divisor).rounded() / divisor
  }
  
  func asString(roundedTo places: Int) -> String {
//    return String(format: "%.\(places)f", self)
    let stringValue = String(format: "%.\(places)", arguments: [self as CVarArg])
    return stringValue
  }
}
