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
  
  // MARK: IBOutlets
  @IBOutlet weak var calendarButton: UIBarButtonItem!
  @IBOutlet weak var mapView: MKMapView!
  
  // Used to fetch results from MOC
  var mapPredicate: MapPredicate!
  
  // one or the other, but not both?
  var earthquake: EarthquakeEntity? // perhaps designate this as the center?
  var earthquakeArray: [EarthquakeEntity]?
  
  // MARK: Map Vars
  private var centerCoordinate: CLLocationCoordinate2D! {
    didSet {
      mapView.centerCoordinate = centerCoordinate
    }
  }
  
  private var coordinateSpan: MKCoordinateSpan?
  
  // initialized as an empty array
  private var fetchResults: [EarthquakeEntity] = []
  @objc private dynamic var fetchedResultsCount: Int = 0
  
  // MARK: Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Quake Maps"
    
    NotificationCenter.default.addObserver(self, selector: #selector(handlePredicateNotification(_:)), name: .mapPredicateUpdated, object: nil)
    
    // FIXME: This is a test only
    if let earthquakeArray = earthquakeArray {
      print("earthquakeArray.count =", earthquakeArray.count)
    }

    centerCoordinate = CLLocationCoordinate2D(latitude: 39.885403, longitude: -86.053936)
    mapView.centerCoordinate = centerCoordinate
    
    // Do any additional setup after loading the view.
  }
  
  // MARK: Configuration, Observers & Notifications
  
  func configureMapPredicate() {
    // Initialize based on whether it's one earthquake
    if let earthquake = earthquake {
      mapPredicate = MapPredicate(earthquake: earthquake, zoomFactor: 1500)
    }
    // ...or an array of earthquakes
    else if let earthquakeArray = earthquakeArray {
      // TODO: compute center of array
    }
  }
  
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    // TODO: implement as needed
    switch keyPath {
    case #keyPath(fetchedResultsCount):
      // TODO: update the center based on when the count channges
      break
    default:
      break
    }
  }
  
  @objc func handlePredicateNotification(_ notification: Notification) {
    print("handlePredicateNotification fired")
  }
  
  
  // MARK: Map Center from Coordinates
  // TODO: write code to find center coordiate
  
  // MARK: IBActions
  @IBAction func calendarButtonAction(_ sender: UIBarButtonItem) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: StoryboardID.calendarVC) as! CalendarViewController
    controller.delegate = self
    self.present(controller, animated: false, completion: nil)
  }
}

// MARK: CalendarViewControllerDelegate
extension MapViewController: CalendarViewControllerDelegate {
  func setDates(startDate: Date?, endDate: Date?) {
    print("setDates called on MapVC")
    guard let mapPredicate = mapPredicate else {
      print("exited setDates because mapPredicate not initialized")
      return
    }
    // two dates sent
    if let startDate = startDate, let endDate = endDate {
      mapPredicate.updateDate(for: startDate, endDate: endDate)
    }
    // one date sent
    else if let startDate = startDate {
      mapPredicate.updateDate(for: startDate, endDate: nil)
    }
  }
  
  
}

