//
//  MapViewController.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 7/9/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit
import MapKit
import Foundation

class MapViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var regionButton: UIBarButtonItem!
  
  var earthquakes: [EarthquakeEntity] = []
  
  private var annotations: [MKAnnotation] = []
  private var centerCoordinate: CLLocation?
  
  private var bboxCoordinates: [CLLocationCoordinate2D] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    print("earthquakes.count =", earthquakes.count)
    mapView.delegate = self
    addAnnnotationsToMap()
    
    if self.mapView.annotations.count > 0 {
      let region = MKCoordinateRegion.init(coordinates: self.annotations.map{$0.coordinate})
      self.mapView.setRegion(region!, animated: false)
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
  /*
   enum DisplayRegion {
   case asia
   case africa
   case northAmerica
   case southAmerica
   case antarctica
   case europe
   case australia
   }
   
   */
  
  @IBAction func continentButtonAction(_ sender: UIBarButtonItem) {
    let regionUtility = RegionUtility()
    
    let actionSheet = UIAlertController(title: "Select Region", message: "Please select a region", preferredStyle: .alert)
    // continents
    let asia = UIAlertAction(title: "Asia", style: .default) { (action) in
      self.mapView.setRegion(regionUtility.region(for: .asia), animated: true)
    }
    let africa = UIAlertAction(title: "Africa", style: .default) { (action) in
      self.mapView.setRegion(regionUtility.region(for: .africa), animated: true)
    }
    let northAmerica = UIAlertAction(title: "North America", style: .default) { (action) in
      self.mapView.setRegion(regionUtility.region(for: .northAmerica), animated: true)
    }
    let southAmerica = UIAlertAction(title: "South America", style: .default) { (action) in
      self.mapView.setRegion(regionUtility.region(for: .northAmerica), animated: true)
    }
    let antarctica = UIAlertAction(title: "Antarctica", style: .default) { (action) in
      self.mapView.setRegion(regionUtility.region(for: .antarctica), animated: true)
    }
    let europe = UIAlertAction(title: "Europe", style: .default) { (action) in
      self.mapView.setRegion(regionUtility.region(for: .europe), animated: true)
    }
    let australia = UIAlertAction(title: "Australia", style: .default) { (action) in
      self.mapView.setRegion(regionUtility.region(for: .australia), animated: true)
    }
    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)

    [asia, africa, antarctica, australia, europe, northAmerica, southAmerica, cancel].forEach { continent in
      actionSheet.addAction(continent)
    }
    
    self.present(actionSheet, animated: true, completion: nil)
  }
  
  @IBAction func oceanButtonAction(_ sender: UIBarButtonItem) {
    let regionUtility = RegionUtility()
    
    let actionSheet = UIAlertController(title: "Oceans", message: "Select an ocean", preferredStyle: .alert)
    let pacific = UIAlertAction(title: "Pacific", style: .default) { (action) in
      self.mapView.setRegion(regionUtility.region(for: .pacificOcean), animated: true)
    }
    let atlantic = UIAlertAction(title: "Atlantic", style: .default) { (action) in
      self.mapView.setRegion(regionUtility.region(for: .atlanticOcean), animated: true)
    }
    let indian = UIAlertAction(title: "Indian Ocean", style: .default) { (action) in
      self.mapView.setRegion(regionUtility.region(for: .indianOcean), animated: true)
    }
    let antarctic = UIAlertAction(title: "Antarctic Ocean", style: .default) { (action) in
      self.mapView.setRegion(regionUtility.region(for: .antarcticOcean), animated: true)
    }
    let arctic = UIAlertAction(title: "Arctic", style: .default) { (action) in
      self.mapView.setRegion(regionUtility.region(for: .arcticOcean), animated: true)
    }
    let cancel = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
    
    [atlantic, indian, pacific, arctic, antarctic, cancel].forEach { ocean in
      actionSheet.addAction(ocean)
    }
    
    self.present(actionSheet, animated: true, completion: nil)

  }
  
  
}

extension MapViewController: MKMapViewDelegate {
  
}























































