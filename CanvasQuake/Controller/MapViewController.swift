//
//  MapViewController.swift
//  CanvasQuake
//
//  Created by Adrian Bolinger on 5/31/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  
  var centerCoordinate: CLLocationCoordinate2D!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Quake Maps"
    
    NotificationCenter.default.addObserver(self, selector: #selector(handlePredicateNotification(_:)), name: .mapPredicateUpdated, object: nil)
    
    
    // Do any additional setup after loading the view.
  }
  
  // MARK: Notification Handlers
  
  @objc func handlePredicateNotification(_ notification: Notification) {
    print("handlePredicateNotification fired")
  }
  
  // MARK: Map Center from Coordinates
  // TODO: write code to find center coordiate
}

