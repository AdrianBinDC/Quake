//
//  PredicateFactory.swift
//  CanvasQuake
//
//  Created by Adrian Bolinger on 6/5/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class MapPredicate: NSObject {
  
  public var predicate: NSPredicate! {
    didSet {
      NotificationCenter.default.post(name: .mapPredicateUpdated, object: nil)
    }
  }
  
  @objc private dynamic var startDate: Date?
  @objc private dynamic var endDate: Date?
  // optional doubles can't be represented in objc, so update predicate via didSet
  private var minMag: Double? {
    didSet {
      updatePredicate()
    }
  }
  
  private var maxMag: Double? {
    didSet {
      updatePredicate()
    }
  }
  
  private var minLat: Double? {
    didSet {
      updatePredicate()
    }
  }
  
  private var maxLat: Double? {
    didSet {
      updatePredicate()
    }
  }
  private var minLong: Double? {
    didSet {
      if let minLong = minLong {
        // FIXME: Calculation seems a little off...close enough for now
        guard minLong >= -90.0 else { self.minLong = -90.0; return }
      }
      updatePredicate()
    }
  }
  private var maxLong: Double? {
    didSet {
      if let maxLong = maxLong {
        // FIXME: Calculation seems a little off...close enough for now
        guard maxLong <= 90.0 else { self.maxLong = 90.0; return }
      }
      updatePredicate()
    }
  }
  
  // MARK: Initializers
  
  // feed some vars, but needs a var or it'll fail b/c we don't want to spend all day watching a map draw
  init?(startDate: Date?, endDate: Date?, minMag: Double?, maxMag: Double?, minLat: Double?, maxLat: Double?, minLong: Double?, maxLong: Double?) {
    super.init()
    
    // failable initializer if it's fed all nil values
    let varCount = [startDate as Any, endDate as Any, minMag as Any, maxMag as Any, minLat as Any, maxLat as Any, minLong as Any, maxLong as Any].compactMap{$0}.count
    guard varCount != 0 else { return nil }

    self.startDate = startDate
    self.endDate = endDate
    self.minMag = minMag
    self.maxMag = maxMag
    self.minLat = minLat
    self.maxLat = maxLat
    self.minLong = minLong
    self.maxLong = maxLong
    
    commonInit()
  }
  
  // feed an earthquake, returns a predicate for the radius around the earthquake's coordinates
  init(earthquake: EarthquakeEntity, zoomFactor: Double) {
    super.init()
    if let coordinate = earthquake.location2d {
      self.minLat = coordinate.latitude - zoomFactor.convertToLatDegrees()
      self.maxLat = coordinate.latitude + zoomFactor.convertToLatDegrees()
      self.minLong = coordinate.longitude - zoomFactor.convertToLongDegrees(atLatitude: coordinate.latitude)
      self.maxLong = coordinate.longitude + zoomFactor.convertToLongDegrees(atLatitude: coordinate.latitude)
    }
    commonInit()
  }
  
  func commonInit() {
    updatePredicate()
  }
  
  // MARK: Observers
  // Optional doubles aren't observable, so need to use didSet for those 🙄
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    switch keyPath {
    case #keyPath(startDate), #keyPath(endDate):
      self.updatePredicate()
    default:
      return
    }
  }
  
  // MARK: Update class vars
  
  public func updateDate(for startDate: Date, endDate: Date?) {
    if let endDate = endDate {
      self.startDate = startDate.startOfDay
      self.endDate = endDate.endOfDay!
    } else {
      self.startDate = startDate.startOfDay
      self.endDate = startDate.endOfDay!
    }
  }
  
  public func updateMagnitude(minMag: Double, maxMag: Double) {
    self.minMag = minMag
    self.maxMag = maxMag
  }
  
  // MARK: Update predicate
  // this is returned as a calculated var from the class's public-facing predicate property.
  private func updatePredicate() {
    
    /*
     self.minLong = minLong
     self.maxLong = maxLong
     */
    
    var predicateArray: [NSPredicate] = []
    
    // predicates for dates
    if let startDate = startDate, let endDate = endDate {
      let startEndDatePredicate = NSPredicate(format: "startDate >= %@ AND endDate >= %@", argumentArray: [startDate.startOfDay, endDate.endOfDay!])
      predicateArray.append(startEndDatePredicate)
    } else if let startDate = startDate {
      let startDatePredicate = NSPredicate(format: "startDate >= %@ AND endDate >= %@", argumentArray: [startDate.startOfDay, startDate.endOfDay!])
      predicateArray.append(startDatePredicate)
    }
    
    // predicate for magnitudes
    // these will always come in from a range slider with two values, so only need one statement
    if let minMag = minMag, let maxMag = maxMag {
      let magnitudePredicate = NSPredicate(format: "magnitude >= %f AND magnitude <= %f", argumentArray: [minMag, maxMag])
      predicateArray.append(magnitudePredicate)
    }
    
    // predicate for latitude
    if let minLat = minLat, let maxLat = maxLat {
      let latitudePredicate = NSPredicate(format: "coordinate.minLat >= %f AND coordinate.maxLat <= %f", argumentArray: [minLat, maxLat])
      predicateArray.append(latitudePredicate)
    }
    
    // predicate for longitude
    if let minLong = minLong, let maxLong = maxLong {
      let longitudePredicate = NSPredicate(format: "coordinate.minLong >= %f AND coordinate.maxLong <= %f", argumentArray: [minLong, maxLong])
      predicateArray.append(longitudePredicate)
    }
    
    self.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
  }
  
}































































