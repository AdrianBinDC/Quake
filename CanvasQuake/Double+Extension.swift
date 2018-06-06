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
    let stringValue = String(format: "%.\(places)", arguments: [self as CVarArg])
    return stringValue
  }
  
  /// convert kilometers to degrees latitude
  func convertToLatDegrees() -> Double {
    // where self is a kilometer
    return self * 1/111
  }
  
  /// convert kilometers to degrees longitude
  func convertToLongDegrees(atLatitude: Double) -> Double {
    // where self is a kilometer
    // Not 100% sure on the calculation
    // gets bigger the further away on the equator
    return self * 1 / (111.320 * cos(atLatitude))
  }
  
}
