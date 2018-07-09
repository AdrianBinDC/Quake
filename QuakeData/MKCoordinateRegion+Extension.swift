//
//  MKCoordinateRegion+Extension.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 6/6/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import MapKit

extension MKCoordinateRegion {
  
  // From: https://gist.github.com/dionc/46f7e7ee9db7dbd7bddec56bd5418ca6
  init?(coordinates: [CLLocationCoordinate2D]) {
    
    // first create a region centered around the prime meridian
    let primeRegion = MKCoordinateRegion.region(for: coordinates, transform: { $0 }, inverseTransform: { $0 })
    
    // next create a region centered around the 180th meridian
    let transformedRegion = MKCoordinateRegion.region(for: coordinates, transform: MKCoordinateRegion.transform, inverseTransform: MKCoordinateRegion.inverseTransform)
    
    // return the region that has the smallest longitude delta
    if let a = primeRegion,
      let b = transformedRegion,
      let min = [a, b].min(by: { $0.span.longitudeDelta < $1.span.longitudeDelta }) {
      self = min
    }
      
    else if let a = primeRegion {
      self = a
    }
      
    else if let b = transformedRegion {
      self = b
    }
      
    else {
      return nil
    }
  }
  
  // Latitude -180...180 -> 0...360
  private static func transform(c: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
    if c.longitude < 0 { return CLLocationCoordinate2DMake(c.latitude, 360 + c.longitude) }
    return c
  }
  
  // Latitude 0...360 -> -180...180
  private static func inverseTransform(c: CLLocationCoordinate2D) -> CLLocationCoordinate2D {
    if c.longitude > 180 { return CLLocationCoordinate2DMake(c.latitude, -360 + c.longitude) }
    return c
  }
  
  private typealias Transform = (CLLocationCoordinate2D) -> (CLLocationCoordinate2D)
  
  private static func region(for coordinates: [CLLocationCoordinate2D], transform: Transform, inverseTransform: Transform) -> MKCoordinateRegion? {
    
    // handle empty array
    guard !coordinates.isEmpty else { return nil }
    
    // handle single coordinate
    guard coordinates.count > 1 else {
      return MKCoordinateRegion(center: coordinates[0], span: MKCoordinateSpanMake(1, 1))
    }
    
    let transformed = coordinates.map(transform)
    
    // find the span
    let minLat = transformed.min { $0.latitude < $1.latitude }!.latitude
    let maxLat = transformed.max { $0.latitude < $1.latitude }!.latitude
    let minLon = transformed.min { $0.longitude < $1.longitude }!.longitude
    let maxLon = transformed.max { $0.longitude < $1.longitude }!.longitude
    let span = MKCoordinateSpanMake(maxLat - minLat, maxLon - minLon)
    
    // find the center of the span
    let center = inverseTransform(CLLocationCoordinate2DMake((maxLat - span.latitudeDelta / 2), maxLon - span.longitudeDelta / 2))
    
    return MKCoordinateRegionMake(center, span)
  }
}
