//
//  Constants.swift
//  CanvasQuake
//
//  Created by Adrian Bolinger on 5/31/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit

let cellReuseID = "Cell"

typealias Gradient = (color1: UIColor, color2: UIColor)

struct StoryboardID {
  static let calendarVC = "CalendarViewController"
  static let mapVC = "MapViewController"
  static let tabularVC = "TabularViewController"
}

struct SegueID {
  static let calendar = "CalendarSegue"
  static let mapSegue = "MapSegue"
}

struct USGSUrlString {
  static let hour = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson"
  static let day = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_day.geojson"
  static let week = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_week.geojson"
  static let month = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson"
}

extension Notification.Name {
  // this gets fired from MapPredicate class when the predicate is updated
  // TODO: When done, this notification will be handled to update the FRC's predicate and redraw the map
  static let mapPredicateUpdated = Notification.Name("mapPredicateUpdated")
}

//@objc var sectionSeverityString: String {
//  switch self.magnitude {
//  case -5..<5:
//    return "Small"
//  case 5..<7:
//    return "Moderate"
//  case 7..<8:
//    return "Major"
//  case 8..<10:
//    return "Great"
//  case _ where self.magnitude > 10:
//    return "Super"
//  default:
//    return ""
//  }
//}
