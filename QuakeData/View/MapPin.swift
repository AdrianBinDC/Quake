//
//  MapPin.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 7/9/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit
import MapKit

class MapPin: NSObject, MKAnnotation {
  var title: String?
  var subtitle: String?
  var coordinate: CLLocationCoordinate2D
  
  // failable initializer in case USGS data isn't "clean"
  init?(quake: EarthquakeEntity) {
    if let timeString = quake.time?.asDateAndTime(),
      let place = quake.place,
      let lat = quake.coordinate?.latitude,
      let long = quake.coordinate?.longitude {
      let titleString = "\(String(format: "%.1f", quake.magnitude)) \(place)"
      let subTitle = timeString
      let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
      self.title = titleString
      self.subtitle = subTitle
      self.coordinate = coordinate
    } else {
      return nil
    }
  }
}
