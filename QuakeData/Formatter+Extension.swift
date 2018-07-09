//
//  Formatter+Extension.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 6/3/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import Foundation

extension Formatter {
  static let iso8601: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
  }()
}
