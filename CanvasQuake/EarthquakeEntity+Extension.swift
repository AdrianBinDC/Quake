//
//  EarthquakeEntity+Extension.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 11/30/17.
//  Copyright © 2017 Adrian Bolinger. All rights reserved.
//

import Foundation
import CoreData
import MapKit

extension EarthquakeEntity {
  
  @objc var sectionDateString: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .long
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        
    if let time = self.time {
      return dateFormatter.string(from: time)
    }
    return "Unavailable Date"
  } // end dateForSection
  
  @objc var sectionSeverityString: String {
    switch self.magnitude {
    case -5..<5:
      return "Small"
    case 5..<7:
      return "Moderate"
    case 7..<8:
      return "Major"
    case 8..<10:
      return "Great"
    case _ where self.magnitude > 10:
      return "Super"
    default:
      return ""
    }
  }
  
  // MARK: - Map Vars
  var location2d: CLLocationCoordinate2D? {
    if let coordinate = coordinate {
      return CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    return nil
  }
  
  var locationCoordinate: CLLocation? {
    if let coordinate = self.coordinate {
      return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    return nil
  }
    
  var markerTintColor: UIColor {
    switch self.sectionSeverityString {
      // FIXME: refactor to different colors
    case "Small":
      return .green
    case "Moderate":
      return .yellow
    case "Major":
      return .orange
    case "Great", "Super":
      return .red
    default:
      return .white
    }
  }
  
}

