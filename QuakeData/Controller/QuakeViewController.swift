//
//  QuakeViewController.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 5/31/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit
import CoreData

class QuakeViewController: UIViewController {
  
  enum CellHeight: CGFloat {
    case expanded = 109
    case compact = 55.0
  }
  
  // MARK: IBOutlets
  
  
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  @IBOutlet weak var resetButton: UIBarButtonItem!
  @IBOutlet weak var mapButton: UIBarButtonItem!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  @IBOutlet weak var magSlider: UISlider!
  @IBOutlet weak var magLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var gradientView: UIViewCanvas!
  @IBOutlet weak var webView: ABWebView!
  
  var dataManager: QuakeDataManager? {
    didSet {
      if dataManager != nil {
        print("💰 dataManager initialized 💰")
      }
    }
  }
  
  // Vars for gradientAnimation
  var currentColorArrayIndex = -1
  var viewIsActive: Bool = true {
    didSet {
      if viewIsActive {
        animateBackgroundColor()
      }
    }
  }
  
  // This is used to set values for searching via segmentedControl
  @objc dynamic var startDate: Date?
  @objc dynamic var endDate: Date?
  
  var currentIndexPath: IndexPath? {
    // this keeps track of what's clicked
    didSet {
      tableView.beginUpdates()
      tableView.endUpdates()
    }
  }
  
  // MARK: Core Data properties
  
  var managedObjectContext: NSManagedObjectContext!
  
  var frcKeyPath: String = #keyPath(EarthquakeEntity.sectionDateString)
  
  var currentPredicate: NSPredicate? {
    didSet {
      if let predicate = currentPredicate {
        fetchedResultsController.fetchRequest.predicate = predicate
        fetchedResultsController.managedObjectContext.refreshAllObjects()
      }
    }
  }
  
  private lazy var fetchedResultsController: NSFetchedResultsController<EarthquakeEntity> = {
    let managedObjectContext = appDelegate.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<EarthquakeEntity> = EarthquakeEntity.fetchRequest()
    let dateSortDescriptor = NSSortDescriptor(key: #keyPath(EarthquakeEntity.time), ascending: false)
    fetchRequest.sortDescriptors = [dateSortDescriptor]
    let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: frcKeyPath, cacheName: nil)
    frc.delegate = self
    
    return frc
  }()
  
  func fetchResults() {
    do {
      fetchedResultsController.fetchRequest.fetchBatchSize = 35
      fetchedResultsController.fetchRequest.fetchLimit = 1_000
      try fetchedResultsController.performFetch()
    } catch let error {
      print("\(error) \(error.localizedDescription)")
    }
    DispatchQueue.main.async {
      self.tableView.reloadData()
      self.tableView.setContentOffset(.zero, animated: true)
      self.updateLabelsForResults()
    }
  }
  
  func updatePredicate() {
    // you need a start date or stop executing
    guard let startDate = startDate else { return }
    
    var predicateArray: [NSPredicate] = []
    
    if let endDate = endDate {
      // TODO: constrain results for date spans larger than one week
      
      if let numberOfDays = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day {
        if numberOfDays > 7 && magSlider.value < 2 {
          magSlider.setValue(2.0, animated: false)
          updateMagSliderLabel()
        }
      }

      let startEndPredicate = NSPredicate(format: "time >= %@ AND time <= %@", argumentArray: [startDate, endDate])
      predicateArray.append(startEndPredicate)
    } else {
      // use the startDate's end of day if endDate is nil
      let startPredicate = NSPredicate(format: "time >= %@ AND time <= %@", argumentArray: [startDate, startDate.endOfDay!])
      predicateArray.append(startPredicate)
    }
    
    
    // FIXME: update
    let sliderPredicate = NSPredicate(format: "magnitude >= %f", argumentArray: [magSlider.value])
    predicateArray.append(sliderPredicate)
    
    currentPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
    
    fetchResults()
  }
  
  // MARK: Lifecycle Methods
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    webView.delegate = self
    
    self.navigationItem.title = "Earthquakes"
    
    magSlider.isContinuous = false
    
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = CellHeight.compact.rawValue
    
    segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    
    // FIXME: connfigure slider
    
    configureCoreData()
    configureObservers()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    viewIsActive = true // used to turn on gradient animation if user switches screens
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    viewIsActive = false // used to turn off the gradient animation
  }
  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
  }
  
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    if !viewIsActive {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
        self.viewIsActive = true
      }
    }
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    // This is the keep animation from flickering when orientation changes
    super.viewWillTransition(to: size, with: coordinator)
    viewIsActive = false
    gradientView.layer.removeAllAnimations()
  }
  
  // MARK: Initial configuration
  fileprivate func configureCoreData() {
    dataManager?.delegate = self
    managedObjectContext = appDelegate.persistentContainer.viewContext
    tableView.delegate = self
    tableView.dataSource = self
  }
  
  // MARK: Observers
  override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    switch keyPath {
    case #keyPath(startDate):
      updatePredicate()
    case #keyPath(endDate):
      updatePredicate()
    default:
      if let keyPath = keyPath {
        print("** undefined case for \(keyPath) **")
      }
    }
  }
  
  // MARK: Observer configuration and handlers
  func configureObservers() {
    // configure observers for start date and end date
    addObserver(self, forKeyPath: #keyPath(startDate), options: [.initial, .new], context: nil)
    addObserver(self, forKeyPath: #keyPath(endDate), options: [.initial, .new], context: nil)
    
    // watch for core data changes
    NotificationCenter.default.addObserver(self, selector: #selector(managedObjectContextDidSave(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: managedObjectContext)
    
    // listen for search notifications
    NotificationCenter.default.addObserver(self, selector: #selector(handleSearch(notification:)), name: .searchBegan, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(handleSearch(notification:)), name: .searchEnded, object: nil)

  }
  
  @objc func managedObjectContextDidSave(_ notification: Notification) {
    print("managedObjectContextDidSave")
    guard let context = notification.object as? NSManagedObjectContext else { return }
    
    if context.parent == managedObjectContext {
      managedObjectContext.performAndWait {
        print(notification)
      }
    }
    updateLabelsForResults()
    NotificationCenter.default.post(name: .searchEnded, object: nil)
  }
  
  @objc func handleSearch(notification: Notification) {
    DispatchQueue.main.async {
      let name = notification.name
      
      print("Notification received")
      
      switch name {
      case .searchBegan:
        self.activityIndicator.superview?.bringSubview(toFront: self.activityIndicator)
        self.activityIndicator.startAnimating()
        break
      case .searchEnded:
        self.activityIndicator.stopAnimating()
        self.view.sendSubview(toBack: self.activityIndicator)
        self.magSlider.isEnabled = true
        break
      default:
        break
      }
    }
  }

  
  // MARK: Helpers
  
  // TODO: Add these in for where view deallocates (older versions of iOS will crash if they're not removed)
  func removeObservers() {
    removeObserver(self, forKeyPath: #keyPath(startDate))
    removeObserver(self, forKeyPath: #keyPath(endDate))
  }
  
  func updateMagSliderLabel() {
    magLabel.text = String(format: "%.1f", arguments: [magSlider.value])
  }
  
  func validateIndexPath(_ indexPath: IndexPath) -> Bool {
    if let sections = self.fetchedResultsController.sections,
      indexPath.section < sections.count {
      if indexPath.row < sections[indexPath.section].numberOfObjects {
        return true
      }
    }
    return false
  }
  
  
  func configureDates(period: SearchPeriod) {
    // set start date to now
    endDate = Date()
    
    // calendar to do computations
    let calendar = Calendar.current
    
    if let end = endDate {
      switch period {
      case .hour:
        startDate = calendar.date(byAdding: .hour, value: -1, to: end)
      case .day:
        startDate = calendar.date(byAdding: .day, value: -1, to: end)
      case .week:
        startDate = calendar.date(byAdding: .day, value: -7, to: end)
      case .month:
        startDate = calendar.date(byAdding: .day, value: -30, to: end)
      }
      
      if let end = endDate {
        dataManager = QuakeDataManager(startDate: startDate!, endDate: end)
        dataManager?.getQuakeData()
      } else {
        dataManager = QuakeDataManager(startDate: startDate!, endDate: nil)
        dataManager?.getQuakeData()
      }
      
      print("start: \(end.asDateAndTime())\n\(endDate!.asDateAndTime())")
    }
  }
  
  
  func resetStartAndEndDates() {
    startDate = nil
    endDate = nil
  }
  
  func updateLabelsForResults() {
    if let recordsFound = fetchedResultsController.fetchedObjects?.count {
      self.title = "\(recordsFound) Records Found"
      
      if recordsFound == 0 {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          self.title = "Earthquakes"
        }
      }
    } else {
      self.title = "Earthquakes"
    }
  }
  
  // MARK: IBActions
  
  enum SearchPeriod {
    case hour
    case day
    case week
    case month
  }
  
  @IBAction func magSliderAction(_ sender: UISlider) {
    magSlider.value = magSlider.value.rounded(.towardZero)
    updateMagSliderLabel()
    
    self.hapticFeedback(style: .light)
    
    updatePredicate()
  }
  
  
  @IBAction func resetButtonAction(_ sender: UIBarButtonItem) {
    // Observer picks this up and sets the start date to the end of day
    // There have been no earthquakes tomorrow, so the fetch is guaranteed to return no quakes.
    self.hapticFeedback(style: .medium)
    self.startDate = Date().dateByAdding(days: 1)
    segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    magSlider.setValue(0.0, animated: true)
    magLabel.text = "0.0"
  }
  
  @IBAction func mapButtonAction(_ sender: UIBarButtonItem) {
    
  }
  
  
  @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
    resetStartAndEndDates()
    
    currentIndexPath = nil
    
    DispatchQueue.main.async {
      // do it when you've got time
      NotificationCenter.default.post(name: .searchBegan, object: nil)
    }
    
    dataManager = nil // nuke it & start fresh
    self.dataManager = QuakeDataManager.init()
    self.dataManager?.delegate = self
    self.endDate = Date()
    
    switch sender.selectedSegmentIndex {
    case 0:
      print("hour")
      dataManager?.getQuakeData(usgsURL: .hour)
      self.startDate = Calendar.current.date(byAdding: .hour, value: -1, to: endDate!) // we set the end earlier in this method
    case 1:
      print("day")
      dataManager?.getQuakeData(usgsURL: .day)
      self.startDate = Calendar.current.date(byAdding: .day, value: -1, to: endDate!) // we set the end earlier in this method
    case 2:
      print("week")
      dataManager?.getQuakeData(usgsURL: .week)
      self.startDate = Calendar.current.date(byAdding: .day, value: -7, to: endDate!) // we set the end earlier in this method
    case 3:
      print("month")
      dataManager?.getQuakeData(usgsURL: .month)
      self.startDate = Calendar.current.date(byAdding: .month, value: -1, to: endDate!) // we set the end earlier in this method
    case 4:
      let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
      let calendarVC = storyboard.instantiateViewController(withIdentifier: StoryboardID.calendarVC) as! CalendarViewController
      calendarVC.delegate = self
      self.present(calendarVC, animated: false, completion: nil)
      
    default:
      break
    }
    
    magSlider.isEnabled = false
  }
  
  
  
  // MARK: Animation
  func animateBackgroundColor() {
    
    currentColorArrayIndex = currentColorArrayIndex == (canvasGradientArray.count - 1) ? 0 : currentColorArrayIndex + 1
    
    UIView.transition(with: gradientView, duration: 5, options: [.transitionCrossDissolve], animations: {
      self.gradientView.firstColor = self.canvasGradientArray[self.currentColorArrayIndex].color1
      self.gradientView.secondColor = self.canvasGradientArray[self.currentColorArrayIndex].color2
    }) { (success) in
      if self.viewIsActive == true {
        self.animateBackgroundColor()
      }
    }
  }
  
  // MARK: Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == SegueID.mapSegue {
      let destination = segue.destination as! MapViewController
      if let earthquakes = fetchedResultsController.fetchedObjects {
        destination.earthquakes = earthquakes
      }
    }
  }
}

// MARK: UITableViewDelegate, UITableViewDataSource
extension QuakeViewController: UITableViewDelegate, UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return fetchedResultsController.sections?.count ?? 0
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let sections = fetchedResultsController.sections {
      let currentSection = sections[section]
      return currentSection.numberOfObjects
    }
    return 0
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    guard let sectionInfo = fetchedResultsController.sections?[section] else {
      print("Something went wrong with titleForHeaderInSection")
      return ""
    }
    return sectionInfo.name + " | " + String(sectionInfo.numberOfObjects) + " records"
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath) as! QuakeTableViewCell
    cell.isSelected = !cell.isSelected
    if currentIndexPath == indexPath {
      currentIndexPath = nil
    } else {
      currentIndexPath = indexPath
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath) as! QuakeTableViewCell
    
    if self.validateIndexPath(indexPath) {
      let quake = fetchedResultsController.object(at: indexPath)
      cell.quake = quake
      let clearView = UIView(frame: cell.frame)
      clearView.backgroundColor = UIColor.white.withAlphaComponent(0.25)
      
      cell.selectedBackgroundView = clearView
      cell.delegate = self
    } else {
      print("Attempting to configure cell whose indexPath is out of bounds")
    }
        
    return cell
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if currentIndexPath == indexPath {
      return CellHeight.expanded.rawValue
    } else {
      return CellHeight.compact.rawValue
    }
  }
}

// MARK: NSFetchedResultsControllerDelegate methods

extension QuakeViewController: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                  didChange sectionInfo: NSFetchedResultsSectionInfo,
                  atSectionIndex sectionIndex: Int,
                  for type: NSFetchedResultsChangeType) {
    switch type {
    case .insert:
      tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
    case .delete:
      tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
    case .move:
      break
    case .update:
      break
    }
  }
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                  didChange anObject: Any,
                  at indexPath: IndexPath?,
                  for type: NSFetchedResultsChangeType,
                  newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      tableView.insertRows(at: [newIndexPath!], with: .fade)
    case .delete:
      tableView.deleteRows(at: [indexPath!], with: .fade)
    case .update:
      tableView.reloadRows(at: [indexPath!], with: .fade)
    case .move:
      tableView.moveRow(at: indexPath!, to: newIndexPath!)
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
}

// MARK: QuakeDataManagerDelegate methods

extension QuakeViewController: QuakeDataManagerDelegate {
  func errorAlert(_ error: String, sender: QuakeDataManager) {
    DispatchQueue.main.async {
      let alertController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
      let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
      alertController.addAction(okAction)
      self.present(alertController, animated: true, completion: nil)
    }
  }
  
  func updateFetchedResultsController() {
    DispatchQueue.main.async {
      self.fetchResults()
      self.dataManager = nil // nuke it and start fresh next time
    }
  }
}

// MARK: ABWebViewDelegate

extension QuakeViewController: ABWebViewDelegate {
  func hideWebView() {
    // nuke blurView
    view.subviews.filter{$0 is UIVisualEffectView}.forEach{
      $0.removeFromSuperview()
      print("Nuked UIVisualEffectView")
    }
    
    UIView.animate(withDuration: 0.3, animations: {
      self.webView.alpha = 0.0
    }) { _ in
      self.view.sendSubview(toBack: self.webView)
      self.webView.alpha = 1.0

    }
  }
}

// MARK: QuakeTableViewCellDelegate

extension QuakeViewController: QuakeTableViewCellDelegate {
  
  func mapPinSegue(quake: EarthquakeEntity) {
    // FIXME: re-enable later
//    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//    let mapViewController = storyboard.instantiateViewController(withIdentifier: StoryboardID.mapVC) as! MapViewController
//    mapViewController.earthquake = quake
//    navigationController?.pushViewController(mapViewController, animated: true)
  }
  
  func preLoad(urlString: String) {
    webView.url = urlString
  }
  
  func presentWebView(urlString: String) {    
    webView.url = urlString
    webView.alpha = 0.0
    self.view.bringSubview(toFront: self.webView)
    
    let visualEffectView = UIVisualEffectView(frame: self.view.bounds)
    visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.insertSubview(visualEffectView, belowSubview: self.webView)
    
    // add blurView
    UIView.animateKeyframes(withDuration: 0.8, delay: 0.0, options: [], animations: {
      UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.5, animations: {
        visualEffectView.effect = UIBlurEffect(style: .dark)
      })

      UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5, animations: {
        self.webView.alpha = 1.0
      })
    }) { _ in
      print("webView animation complete")
    }
  }
}


// MARK: CalendarViewControllerDelegate methods

extension QuakeViewController: CalendarViewControllerDelegate {
  func setDates(startDate: Date?, endDate: Date?) {
    segmentedControl.selectedSegmentIndex = UISegmentedControlNoSegment
    
    resetStartAndEndDates()

    if let start = startDate {
      self.startDate = start.startOfDay
      print("start =", start.asDate())
    }
    
    if let end = endDate {
      self.endDate = end.endOfDay
      print("end =", end.endOfDay?.asDate() ?? "")
    }
    dataManager = QuakeDataManager(startDate: self.startDate!, endDate: self.endDate)
    dataManager?.delegate = self
    dataManager?.getQuakeData()
  }
}

