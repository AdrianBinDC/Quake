//
//  MapViewController.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 7/9/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit
import MapKit

class RegionUtility: NSObject {
  
  /*
   ** continents **
   asia
   25.6,-12.2,-169.0,82.0
   
   africa
   -25.4,-47.1,63.8,37.5
   
   north america
   170.6,5.5,-8.3,84.0
   
   south america
   -110.0,-56.1,-28.7,17.7
   
   antarctica
   -180.0,-85.1,180.0,-60.1
   
   europe
   -31.5,34.5,74.4,82.2
   
   australia
   110.95,-54.83,159.29,-9.19
   
   ** oceans **
   pacific ocean
   128.6,-77.8,-66.5,59.5
   
   atlantic ocean
   West/South/East/North
   -83.2,-83.0,20.0,68.6
   
   indian ocean
   13.1,-71.4,146.9,10.4
   
   antarctic ocean
   -160.250053,-68.442114,-160.218039,-68.433912
   
   arctic ocean
   -68.98,62.83,-55.7,67.71
   */
  
//  class func asia() -> MKCoordinateRegion {
//
//
////    let region = MKCoordinateRegion(center: <#T##CLLocationCoordinate2D#>, span: <#T##MKCoordinateSpan#>)
//  }
}

class MapViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  
  var earthquakes: [EarthquakeEntity] = []
  
  private var annotations: [MKAnnotation] = []
  private var centerCoordinate: CLLocation?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("earthquakes.count =", earthquakes.count)
    mapView.delegate = self
    addAnnnotationsToMap()
    
    if self.mapView.annotations.count > 0 {
      let region = MKCoordinateRegion.init(coordinates: self.annotations.map{$0.coordinate})!
      self.mapView.setRegion(region, animated: true)
    }
  }
  
  fileprivate func addAnnnotationsToMap() {
    earthquakes.forEach{ quake in
      let annotation = MapPin(quake: quake)
      if let pin = annotation {
        annotations.append(pin)
      }
    }
    
    mapView.addAnnotations(annotations)
  }

}

extension MapViewController: MKMapViewDelegate {
}
