/*
 Copyright © 2018 Adrian Bolinger
 Created by Adrian Bolinger on 06/01/17
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

import UIKit
import Alamofire
import CoreData


/*
 Notes:
 
 * to minimize network calls, downloading everything for a date & let FRC on the VC do the work of figuring out details...just get the data.
 * The FilterView will take care of creating predicates for the VCs.
 */

enum USGSSearch {
  case hour
  case day
  case week
  case month
}

protocol QuakeDataManagerDelegate: class {
  func errorAlert(_ error: String, sender: QuakeDataManager)
  func updateFetchedResultsController()
}

class QuakeDataManager: NSObject {
  //  static let sharedInstance = QuakeDataManager()
  
  private var startDate: Date!
  private var endDate: Date?
  
  /*
   DispatchGroup coordinates async threads. Running the networking task on its own async thread and core data on its own async thread can lead to errors with larger data sets. DispatchGroup resolves the issue.
   */
  
  private let group = DispatchGroup()
  
  private let networkingQueue = DispatchQueue(label: "networking", qos: .userInitiated, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
  private let coreDataQueue = DispatchQueue(label: "coreData", qos: .userInitiated, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
  
  // Core Data references
  private let appDelegate = UIApplication.shared.delegate as! AppDelegate
  private var manageObjectContext: NSManagedObjectContext!
  
  init(startDate: Date, endDate: Date?) {
    super.init()
    self.startDate = startDate
    self.endDate = endDate
    
    self.manageObjectContext = appDelegate.persistentContainer.viewContext
    
  }
  
  override init() {
    super.init()
    
    self.manageObjectContext = appDelegate.persistentContainer.viewContext

  }
  
  enum QuakeDataEntity: String {
    case earthquake = "EarthquakeEntity"
    case coordinates = "GeometryEntity"
    case searchQuery = "SearchEntity"
  }
  
  weak var delegate: QuakeDataManagerDelegate?
  
  // https://earthquake.usgs.gov/earthquakes/search/
  
  // MARK: - Data Retrieval Methods
  
  // TODO: create a method that mirrors this
  /*
   TODO: Create a method that takes an array of EarthQuake entities,
   */
  private func datesBetweenDates(startDate: Date, endDate: Date) -> [Date] {
    // sort the dates to ensure the earliest date is index 0
    let dateArray: [Date] = [startDate.startOfDay, endDate.startOfDay].sorted()
    
    var returnArray: [Date] = []
    
    var dateToIncrement = dateArray.first!
    
    while dateToIncrement.isBeforeDate(dateArray.last!) {
      returnArray.append(dateToIncrement)
      dateToIncrement = dateToIncrement.dateByAdding(days: 1)!
    }
    
    return returnArray
  }
  
  // TODO: create url creation function that takes all the parameters
  
  private func setURL(startDate: Date?, endDate: Date?) -> URL? {
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "earthquake.usgs.gov"
    urlComponents.path = "/fdsnws/event/1/query.geojson"
    
    // create a place to store URLQueryItems
    var queryArray: [URLQueryItem] = []
    
    // Handle Dates
    if startDate != nil && endDate != nil {
      if let startDate = startDate, let endDate = endDate {
        let endTimeQuery = URLQueryItem(name: "endtime", value: endDate.endOfDay!.iso8601String())
        queryArray.append(endTimeQuery)
        
        let startDateQuery = URLQueryItem(name: "starttime", value: startDate.startOfDay.iso8601String())
        queryArray.append(startDateQuery)
      }
    }
    
    if startDate != nil && endDate == nil {
      if let startDate = startDate {
        let endTimeQuery = URLQueryItem(name: "endtime", value: startDate.endOfDay!.iso8601String())
        queryArray.append(endTimeQuery)
        
        let startDateQuery = URLQueryItem(name: "starttime", value: startDate.startOfDay.iso8601String())
        queryArray.append(startDateQuery)
      }
    }
    
    
    let orderByQuery = URLQueryItem(name: "orderby", value: "time")
    queryArray.append(orderByQuery)
    
    urlComponents.queryItems = queryArray
    
    if let url = urlComponents.url {
      return url
    }
    
    return nil
  }
  
  public func getQuakeData(usgsURL: USGSSearch) {
    
    self.networkingQueue.async(group: group, qos: .userInitiated, flags: DispatchWorkItemFlags.inheritQoS) {
      var url: URL?
      
      switch usgsURL {
      case .hour:
        url = URL(string: USGSUrlString.day)
      case .day:
        url = URL(string: USGSUrlString.day)
      case .week:
        url = URL(string: USGSUrlString.week)
      case .month:
        url = URL(string: USGSUrlString.month)
      }
      
      guard let usgsURL = url else { return }
      
      Alamofire.request(usgsURL).responseJSON { response in
                
        switch response.result {
        case .success:
          if let data = response.data {
            let jsonDecoder = JSONDecoder()
            do {
              let jsonData = try jsonDecoder.decode(USGSData.self, from: data)
              
              self.coreDataQueue.async(group: self.group, qos: .userInteractive, flags: [], execute: {
                self.importToCoreData(dataToEvaluateArray: jsonData.features)
              })
              
            } catch {
              DispatchQueue.main.async {
                NotificationCenter.default.post(name: .searchEnded, object: nil)
              }
              self.delegate?.errorAlert(error.localizedDescription, sender: self)
            }
          }
        case .failure(let error):
          DispatchQueue.main.async {
            NotificationCenter.default.post(name: .searchEnded, object: nil)
          }
          self.delegate?.errorAlert(error.localizedDescription, sender: self)
        }
      } // end Alamofire

    }
  }
  
  //  public func getQuakeData(startDate: Date?, endDate: Date?) {
  public func getQuakeData() {
    self.networkingQueue.async(group: group, qos: .userInitiated, flags: [.inheritQoS]) {
      
      // 🤔 see if we need to make this request by Alamofire?
      var recordsExistBools: [Bool] = []
      
      if let startDate = self.startDate, let endDate = self.endDate {
        if startDate.isSameDate(endDate) {
          recordsExistBools.append(self.doRecordsExistForThisDate(startDate))
        } else {
          let dateSpan = self.datesBetweenDates(startDate: startDate, endDate: endDate)
          dateSpan.forEach{ date in
            recordsExistBools.append(self.doRecordsExistForThisDate(date))
          }
        }
      }
      
      if !recordsExistBools.contains(false) {
        print("🍺 Our work here is done")
        DispatchQueue.main.async {
          NotificationCenter.default.post(name: .searchEnded, object: nil)
        }
        self.delegate?.updateFetchedResultsController()
        return
      }
      
      
      let url = self.setURL(startDate: self.startDate, endDate: self.endDate)
      
      guard let constructedURL = url else { print("url not created"); return}
      
      Alamofire.request(constructedURL).responseJSON(queue: self.networkingQueue) { response in
        
        // FIXME: write code to handle timeout
        
        switch response.result {
        case .success:
          if let data = response.data {
            let jsonDecoder = JSONDecoder()
            do {
              let jsonData = try jsonDecoder.decode(USGSData.self, from: data)
              
              self.coreDataQueue.async(group: self.group, qos: .userInteractive, flags: [], execute: {
                self.importToCoreData(dataToEvaluateArray: jsonData.features)
              })
              
            } catch {
              DispatchQueue.main.async {
                NotificationCenter.default.post(name: .searchEnded, object: nil)
              }
              self.delegate?.errorAlert(error.localizedDescription, sender: self)
            }
          }
        case .failure(let error):
          DispatchQueue.main.async {
            NotificationCenter.default.post(name: .searchEnded, object: nil)
          }
          if let responseData = response.data {
            if let responseBody = String(data: responseData, encoding: .utf8) {
              self.delegate?.errorAlert(responseBody, sender: self)
            }
          } else {
            self.delegate?.errorAlert(error.localizedDescription, sender: self)
          }
        }
      } // end Alamofire
    }
  }
  
  // MARK: - Core Data Methods
  
  private func importToCoreData(dataToEvaluateArray: [Features]) {
    
    var dataToEvaluateArray = dataToEvaluateArray
    
    print("Coming into this method, dataToEvaluateArray.count =", dataToEvaluateArray.count)
    
    coreDataQueue.async(group: group, qos: .userInitiated, flags: [.inheritQoS]) {
      
      // Here, I extract all the dates from the inputted set.
      let datesToCheck = Set(dataToEvaluateArray.map{Date(timeIntervalSince1970: $0.properties.time/1_000).startOfDay})
      // we'll always evaluate today values for import, so datesToEvaluate includes it‼️
      datesToCheck.forEach({ date in
        // then, do a loop to see what's in core data already.
        // if true, then filter those out of the records to evaluate array
        if self.doRecordsExistForThisDate(date) {
          // nuke it by filtering it out
          print("Don't need records for", date.asDate())
          dataToEvaluateArray = dataToEvaluateArray.filter{!Date(timeIntervalSince1970: $0.properties.time/1_000).isSameDate(date)}
        }
      })
      
      print("After nuking redundannt records, dataToEvaluateArray.count =", dataToEvaluateArray.count)
      
      // if it's in there, filter out those dates from the dataToEvaluateArray
      
      // this is not redundant, as we donn't want to import today's records in
      
      let newDataToEvaluate = Set(dataToEvaluateArray.map{$0.id})
      let recordsInCoreData = self.getIdSetForCurrentPredicate()
      let newRecords = newDataToEvaluate.subtracting(recordsInCoreData)
      var itemsToImportArray: [Features] = []
      
      dataToEvaluateArray.forEach{ record in
        if newRecords.contains(record.id) {
          itemsToImportArray.append(record)
        }
      }
      
      print("newDataToEvaluate.count = ", newDataToEvaluate.count)
      print("recordsInCoreData.count", recordsInCoreData.count)
      print("newRecords.count = ", newRecords.count)
      print("itemsToImportArray.count = ", itemsToImportArray.count)
      
      // if it's already been searched, then stop looking
      
      var count = 0
      
      // THEN, import if you need to
      
      let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
      privateContext.persistentStoreCoordinator = self.manageObjectContext.persistentStoreCoordinator
      
      
      privateContext.performAndWait {
        itemsToImportArray.forEach { quakeStruct in
          let quakeEntity = NSEntityDescription.entity(forEntityName: QuakeDataEntity.earthquake.rawValue, in: privateContext)
          
          let quakeObject = EarthquakeEntity(entity: quakeEntity!, insertInto: privateContext)
          
          quakeObject.setValue(quakeStruct.type, forKey: "type")
          quakeObject.setValue(quakeStruct.properties.mag, forKey: "magnitude")
          quakeObject.setValue(quakeStruct.properties.place, forKey: "place")
          quakeObject.setValue(Date(timeIntervalSince1970: quakeStruct.properties.time/1_000), forKey: "time")
          quakeObject.setValue(Date(timeIntervalSince1970: quakeStruct.properties.updated/1_000), forKey: "lastUpdated")
          quakeObject.setValue(quakeStruct.properties.url, forKey: "url")
          quakeObject.setValue(quakeStruct.properties.detail, forKey: "detail")
          quakeObject.setValue(quakeStruct.properties.felt, forKey: "felt")
          quakeObject.setValue(quakeStruct.properties.cdi, forKey: "cdi")
          quakeObject.setValue(quakeStruct.properties.mmi, forKey: "mmi")
          quakeObject.setValue(quakeStruct.properties.alert, forKey: "alert")
          quakeObject.setValue(quakeStruct.properties.status, forKey: "status")
          quakeObject.setValue(Bool(truncating: quakeStruct.properties.tsunami as NSNumber), forKey: "tsunami")
          quakeObject.setValue(quakeStruct.properties.sig, forKey: "significance")
          quakeObject.setValue(quakeStruct.properties.net, forKey: "net")
          quakeObject.setValue(quakeStruct.properties.code, forKey: "code")
          quakeObject.setValue(quakeStruct.id, forKey: "id")
          // FIXME: make ids, sources, and types a standalone item and create array to populate it?
          quakeObject.setValue(quakeStruct.properties.ids, forKey: "ids")
          quakeObject.setValue(quakeStruct.properties.sources, forKey: "sources")
          quakeObject.setValue(quakeStruct.properties.types, forKey: "types")
          // FIXME: end fix
          quakeObject.setValue(quakeStruct.properties.nst, forKey: "nst")
          quakeObject.setValue(quakeStruct.properties.dmin, forKey: "dmin")
          quakeObject.setValue(quakeStruct.properties.rms, forKey: "rms")
          quakeObject.setValue(quakeStruct.properties.gap, forKey: "gap")
          quakeObject.setValue(quakeStruct.properties.magType, forKey: "magType")
          
          // coordinates
          let geometryEntity = NSEntityDescription.entity(forEntityName: QuakeDataEntity.coordinates.rawValue, in: privateContext)
          let geometryObject = GeometryEntity(entity: geometryEntity!, insertInto: privateContext)
          geometryObject.longitude = quakeStruct.geometry.coordinates[0]
          geometryObject.latitude = quakeStruct.geometry.coordinates[1]
          geometryObject.depth = quakeStruct.geometry.coordinates[2]
          quakeObject.coordinate = geometryObject
          count += 1
        }        
      }
      
      // ...then save it
      
      do {
        try privateContext.save()
        self.manageObjectContext.performAndWait {
          do {
            try self.manageObjectContext.save()
          } catch {
            print("self.manageObjectContext.save(): \(error.localizedDescription)")
          }
        }
      } catch {
        print("privateContext.save(): \(error.localizedDescription)")
      }
    }
  }
  
  func doRecordsExistForThisDate(_ date: Date) -> Bool {
    guard date != Date().startOfDay else { return false }
    
    var results: [EarthquakeEntity] = []

    if let end = date.endOfDay {
      let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
      privateContext.persistentStoreCoordinator = manageObjectContext.persistentStoreCoordinator
      
      privateContext.performAndWait {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: QuakeDataEntity.earthquake.rawValue)
        let predicate = NSPredicate(format: "time >= %@ AND time <= %@", argumentArray: [date.startOfDay, end])
        fetchRequest.predicate = predicate
        // we just need to know that something's there for that date, no need to get everything
        fetchRequest.fetchLimit = 1
        
        do {
          results = try privateContext.fetch(fetchRequest) as! [EarthquakeEntity]
        } catch {
          print("doRecordsExistForThisDate: ",error.localizedDescription)
        }
      }
    }
    
    if results.isEmpty {
      return false
    } else {
      return true
    }
  }
  
  func getIdSetForCurrentPredicate() -> Set<String> {
    let privateContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    privateContext.persistentStoreCoordinator = manageObjectContext.persistentStoreCoordinator
    
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: QuakeDataEntity.earthquake.rawValue)
    
    var existingIds: [EarthquakeEntity] = []
    
    do {
      existingIds = try privateContext.fetch(fetchRequest) as! [EarthquakeEntity]
    } catch let error {
      DispatchQueue.main.async {
        DispatchQueue.main.async {
          NotificationCenter.default.post(name: .searchEnded, object: nil)
        }
        self.delegate?.errorAlert(error.localizedDescription, sender: self)
      }
    }
    
    return Set<String>(existingIds.map{$0.id}.compactMap{$0})
  }
}

