//
//  RetrievedDatesUtility.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 7/11/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit
import CoreData

// TODO: incorporate with data manager to reduce work
// TODO: implement with calendar to update retrieved dates when calendar loads

class ExistingDataUtil: NSObject {
  static let sharedInstance = ExistingDataUtil()
  
  public private (set) var retrievedDates: Set<Date>?
  
  private let appDelegate = UIApplication.shared.delegate as! AppDelegate
  private var moc: NSManagedObjectContext!
  
  // Initialized when program starts
  private override init() {
    super.init()
    fetchDates(nil)
    configureObservers()
  }
  
  private func configureObservers() {
    NotificationCenter.default.addObserver(self, selector: #selector(fetchDates), name: NSNotification.Name.NSManagedObjectContextDidSave, object: moc)
  }
  
  @objc public func fetchDates(_ notification: Notification?) {
    // FIXME: experiment with refactoring to fetching one property
    self.moc = appDelegate.persistentContainer.viewContext

    let fetchRequest = NSFetchRequest<EarthquakeEntity>(entityName: "EarthquakeEntity")
    
    let predicate = NSPredicate(format: "time < %@", argumentArray: [Date().startOfDay])

    fetchRequest.predicate = predicate

    var results: [EarthquakeEntity] = []

    do {
      results = try moc.fetch(fetchRequest)
    } catch {
      print("something went horribly wrong")
    }

    let dates = results.map{$0.time?.startOfDay}.compactMap{$0}

    retrievedDates = Set(dates)
  }
  
  public func insertDate(_ date: Date) {
    retrievedDates?.insert(date)
  }
  
  func datesNeeded(startDate: Date, endDate: Date) -> [Date] {
    var date = startDate.startOfDay
    var datesRequested: [Date] = []
    
    while date.startOfDay <= endDate.startOfDay {
      datesRequested.append(date)
      date = date.dateByAdding(days: 1)!
    }
    
    let requestedSet = Set(datesRequested)
    guard let retrievedDates = retrievedDates else { return Array(requestedSet) }
    let neededSet = requestedSet.subtracting(retrievedDates)
    
    return Array(neededSet)
    
  }
}
