//
//  MapViewController.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 7/9/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  
  var earthquakes: [EarthquakeEntity] = []
  
  private var annotations: [MKAnnotation] = []
  private var centerCoordinate: CLLocation?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addAnnnotationsToMap()
    let region: MKCoordinateRegion = MKCoordinateRegion.init(coordinates: annotations.map{$0.coordinate})!
    mapView.setRegion(region, animated: true)

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
