//
//  String+Extension.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 7/13/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import Foundation

extension String {

  func flag() -> String {
    let base : UInt32 = 127397
    var s = ""
    for v in self.unicodeScalars {
      s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
    }
    return String(s)
  }
}
