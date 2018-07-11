//
//  PredicateFactory.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 6/5/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import Foundation
import CoreData
import MapKit

/*
 This takes all the parameters that are not nil and spits out a predicate to search Core Data
 Makes more sense to put all that stuff in a dedicated class than do it on a ViewController
 */

class MapPredicate: NSObject {
  
  public var predicate: NSPredicate! {
    didSet {
      NotificationCenter.default.post(name: .mapPredicateUpdated, object: nil)
    }
  }
  
  // these are publicly viewable, but privately settable. Set via methods
  @objc private (set) dynamic var startDate: Date?
  @objc private (set) dynamic var endDate: Date?
  // optional doubles can't be represented in objc, so update predicate via didSet
  private var minMag: Double? {
    didSet {
      updatePredicate()
    }
  }
  
  private (set) var maxMag: Double? {
    didSet {
      updatePredicate()
    }
  }
  
  private (set) var minLat: Double? {
    didSet {
      updatePredicate()
    }
  }
  
  private (set) var maxLat: Double? {
    didSet {
      updatePredicate()
    }
  }
  
  private (set) var minLong: Double? {
    didSet {
      if let minLong = minLong {
        guard minLong >= -90.0 else { self.minLong = -90.0; return }
      }
      updatePredicate()
    }
  }
  
  private (set) var maxLong: Double? {
    didSet {
      if let maxLong = maxLong {
        guard maxLong <= 90.0 else { self.maxLong = 90.0; return }
      }
      updatePredicate()
    }
  }
  
  // MARK: Initializers
  // NSObject, so you can just initialize it empty and set via sliders, too.
  
  override init() {
    super.init()
  }
  
  // feed some vars, but needs a var or it'll fail b/c we don't want to spend all day watching a map draw
  init?(startDate: Date?, endDate: Date?, minMag: Double?, maxMag: Double?, bbox: BoundingBox?) {
    super.init()
    
    // failable initializer if it's fed all nil values
    let varCount = [startDate as Any, endDate as Any, minMag as Any, maxMag as Any, bbox as Any].compactMap{$0}.count
    guard varCount != 0 else { return nil }
    
    self.startDate = startDate
    self.endDate = endDate
    self.minMag = minMag
    self.maxMag = maxMag
    self.minLat = bbox?.min.latitude ?? nil
    self.maxLat = bbox?.max.latitude ?? nil
    self.minLong = bbox?.min.longitude ?? nil
    self.maxLong = bbox?.max.longitude ?? nil
    
    commonInit()
  }
  
  // feed an earthquake, returns a predicate for the radius around the earthquake's coordinates
  
  init(earthquake: EarthquakeEntity, zoomFactor: Double) {
    super.init()
    if let coordinate = earthquake.location2d {
      // FIXME: In later versions, add a default preferennce for units of distance
      let searchRegion = MKCoordinateRegionMakeWithDistance(coordinate,
                                                            zoomFactor.convert(from: .miles, to: .meters),
                                                            zoomFactor.convert(from: .miles, to: .meters))
      
      self.minLat = coordinate.latitude - (searchRegion.span.latitudeDelta / 2)
      self.maxLat = coordinate.latitude + (searchRegion.span.latitudeDelta / 2)
      self.minLong = coordinate.longitude - (searchRegion.span.longitudeDelta / 2)
      self.maxLong = coordinate.longitude + (searchRegion.span.longitudeDelta / 2)
    }
    commonInit()
  }
  
  private func commonInit() {
    updatePredicate()
  }
  
  // MARK: Observers
  // Optional doubles aren't observable, so need to use didSet for those 🙄
  internal override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    switch keyPath {
    case #keyPath(startDate), #keyPath(endDate):
      self.updatePredicate()
    default:
      return
    }
  }
  
  // MARK: Update class vars
  
  public func setDate(for startDate: Date, endDate: Date?) {
    if let endDate = endDate {
      self.startDate = startDate.startOfDay
      self.endDate = endDate.endOfDay!
    } else {
      self.startDate = startDate.startOfDay
      self.endDate = startDate.endOfDay!
    }
  }
  
  public func setMagnitude(minMag: Double, maxMag: Double) {
    self.minMag = minMag
    self.maxMag = maxMag
  }
  
  public func setLatitude(minLat: Double, maxLat: Double) {
    self.minLat = minLat
    self.maxLat = maxLat
  }
  
  public func setLongitude(minLong: Double, maxLong: Double) {
    self.minLong = minLong
    self.maxLong = maxLong
  }
  
  // MARK: Update predicate
  // this is returned as a calculated var from the class's public-facing predicate property.
  private func updatePredicate() {
    
    /*
     self.minLong = minLong
     self.maxLong = maxLong
     */
    
    DispatchQueue.global(qos: .userInteractive).async {
      var predicateArray: [NSPredicate] = []
      
      // predicates for dates
      if let startDate = self.startDate, let endDate = self.endDate {
        let startEndDatePredicate = NSPredicate(format: "startDate >= %@ AND endDate >= %@", argumentArray: [startDate.startOfDay, endDate.endOfDay!])
        predicateArray.append(startEndDatePredicate)
      } else if let startDate = self.startDate {
        let startDatePredicate = NSPredicate(format: "startDate >= %@ AND endDate >= %@", argumentArray: [startDate.startOfDay, startDate.endOfDay!])
        predicateArray.append(startDatePredicate)
      }
      
      // predicate for magnitudes
      // these will always come in from a range slider with two values, so only need one statement
      if let minMag = self.minMag, let maxMag = self.maxMag {
        let magnitudePredicate = NSPredicate(format: "magnitude >= %f AND magnitude <= %f", argumentArray: [minMag, maxMag])
        predicateArray.append(magnitudePredicate)
      }
      
      // predicate for latitude
      if let minLat = self.minLat, let maxLat = self.maxLat {
        let latitudePredicate = NSPredicate(format: "coordinate.latitude >= %f AND coordinate.latitude <= %f", argumentArray: [minLat, maxLat])
        predicateArray.append(latitudePredicate)
      }
      
      // predicate for longitude
      if let minLong = self.minLong, let maxLong = self.maxLong {
        let longitudePredicate = NSPredicate(format: "coordinate.longitude >= %f AND coordinate.longitude <= %f", argumentArray: [minLong, maxLong])
        predicateArray.append(longitudePredicate)
      }
      
      self.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
    }
  }  
}































































