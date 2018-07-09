//
//  MapViewController.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 5/31/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
  
  // MARK: IBOutlets
  @IBOutlet weak var calendarButton: UIBarButtonItem!
  @IBOutlet weak var filterView: FilterView!
  @IBOutlet weak var mapView: MKMapView!
  
  // Used to fetch results from MOC
  var mapPredicate: MapPredicate? // absolutely need, but initialize in viewDidLoad
  
  var managedObjectContext: NSManagedObjectContext!
  
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
  
  // MARK: Data Source
  // initialized as an empty array
  private var fetchResults: [EarthquakeEntity] = [] {
    didSet {
      print("There are now \(fetchResults.count) records")
    }
  }
  @objc private dynamic var fetchedResultsCount: Int = 0
  
  // MARK: Lifecycle Methods
  override func viewDidLoad() {
    super.viewDidLoad()
    self.navigationItem.title = "Quake Maps"
    
    managedObjectContext = appDelegate.persistentContainer.viewContext
    
    observersInitialConfig()
    filterInitialConfig()
    mapPredicateInitialConfig()
    
    // configure the map
    centerCoordinate = CLLocationCoordinate2D(latitude: 39.885403, longitude: -86.053936)
    mapView.centerCoordinate = centerCoordinate
    
    // Do any additional setup after loading the view.
  }
  
  // MARK: Configuration, Observers & Notifications
  
  func filterInitialConfig() {
    filterView.delegate = self
    filterView.setZoom(min: 0, max: 1000, value: 1000)
  }
  
  func observersInitialConfig() {
    // handles notifications from predicate being updated via MapPredicate class
    NotificationCenter.default.addObserver(self, selector: #selector(handlePredicateNotification(_:)), name: .mapPredicateUpdated, object: nil)
  }
  
  func mapPredicateInitialConfig() {
    // Initialize based on whether it's one earthquake
    if let earthquake = earthquake {
      mapPredicate = MapPredicate(earthquake: earthquake, zoomFactor: 1500)
      updateDataSource()

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
//    updateDataSource()
    
  }
  
  // MARK: Core Data Methods
  
  func updateDataSource() {
    guard let mapPredicate = mapPredicate else { return }
    let fetchRequest = NSFetchRequest<EarthquakeEntity>(entityName: "EarthquakeEntity")
    fetchRequest.predicate = mapPredicate.predicate
    
    do {
      self.fetchResults = try managedObjectContext.fetch(fetchRequest)
    } catch {
      print("updateDataSource: ", error.localizedDescription)
    }
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

// MARK: FilterViewDelegate
extension MapViewController: FilterViewDelegate {
  func filterButtonTapped() {
    print("filter button tapped")
    updateDataSource()
  }
  
  // TODO: Dates will get picked up via yet-to-be-implemented notification
  
  func updateMagnitude(minMag: Double, maxMag: Double) {
    guard let mapPredicate = mapPredicate else {
      return
    }
    mapPredicate.setMagnitude(minMag: minMag, maxMag: maxMag)
  }
  
  func updateLatitude(minLat: Double, maxLat: Double) {
    guard let mapPredicate = mapPredicate else {
      return
    }
    mapPredicate.setLatitude(minLat: minLat, maxLat: maxLat)
  }
  
  func updateLongitude(minLong: Double, maxLong: Double) {
    guard let mapPredicate = mapPredicate else {
      return
    }
    mapPredicate.setLongitude(minLong: minLong, maxLong: maxLong)
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
      mapPredicate.setDate(for: startDate, endDate: endDate)
      filterView.setDate(startDate: startDate, endDate: endDate)
    }
    // one date sent
    else if let startDate = startDate {
      mapPredicate.setDate(for: startDate, endDate: nil)
      filterView.setDate(startDate: startDate, endDate: startDate)
    }
  }
  
  
}

