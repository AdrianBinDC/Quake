//
//  Date+Extension.swift
//  CanvasQuake
//
//  Created by Adrian Bolinger on 5/31/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import Foundation

extension Date {
  func iso8601String() -> String {
    let formatter = ISO8601DateFormatter()
    return formatter.string(from: self)
  }
  
  func asDate() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    return dateFormatter.string(from: self)
  }
  
  func asDateAndTime() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .short
    dateFormatter.timeStyle = .short
    return dateFormatter.string(from: self)
  }
  
  func isSameDate(_ comparisonDate: Date) -> Bool {
    let order = Calendar.current.compare(self, to: comparisonDate, toGranularity: .day)
    return order == .orderedSame
  }
  
  func isBeforeDate(_ comparisonDate: Date) -> Bool {
    let order = Calendar.current.compare(self, to: comparisonDate, toGranularity: .day)
    
    return order == .orderedAscending
  }
  
  func isAfterDate(_ comparisonDate: Date) -> Bool {
    let order = Calendar.current.compare(self, to: comparisonDate, toGranularity: .day)
    return order == .orderedDescending
  }
  
  var startOfDay: Date {
    return Calendar.current.startOfDay(for: self)
  }
  
  var endOfDay: Date? {
    var components = DateComponents()
    components.day = 1
    components.second = -1
    return Calendar.current.date(byAdding: components, to: startOfDay)
  }
  
  func dateByAdding(days: Int) -> Date? {
    return Calendar.current.date(byAdding: .day, value: days, to: self)
  }
}
