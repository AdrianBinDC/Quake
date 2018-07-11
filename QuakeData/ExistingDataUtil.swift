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
  
  private override init() {
    super.init()
    fetchDates()
  }
  
  func fetchDates() {
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
}
