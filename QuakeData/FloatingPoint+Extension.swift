//
//  FloatingPoint+Extension.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 6/8/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import Foundation

extension FloatingPoint {
  var isInt: Bool {
    return floor(self) == self
  }
}
