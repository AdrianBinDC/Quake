//
//  FilterView.swift
//  CanvasQuake
//
//  Created by Adrian Bolinger on 6/2/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit
import WARangeSlider
import CoreData

// TODO: Set up a notification on the CalendarVC to update start and end date labels
// TODO: Add observer to pick up notifications
// TODO: Get rid of calendar delegate and just post a notification so "everyone" knows about updates

// Keep this as a struct, not a class...I'm only concerned with values from this class and I don't want anyone touching it.
struct QuakeParameters {
  var startDate: Date?
  var endDate: Date?
  var minMag: Double?
  var maxMag: Double?
  var minLat: Double?
  var maxLat: Double?
  var minLong: Double?
  var maxLong: Double?
}

// Minimize typos
struct GeoStrings {
  static let minMag = "0.0"
  static let maxMag = "10.0"
  static let minLat = "-90.0"
  static let maxLat = "90.0"
  static let minLong = "-180.0"
  static let maxLong = "180.0"
}

// MARK: FilterViewDelegate
protocol FilterViewDelegate: class {
  // This updates the FRC on the VC
  func updatePredicate(_ predicate: NSPredicate)
  func zoom(toDistance: Double)
  /*
   Documentation link for configurign distance
   https://developer.apple.com/documentation/mapkit/1452245-mkcoordinateregionmakewithdistan#
   */
}

// TODO: This is gonna get pretty chunky. Might want to subclass this when it's done and create the predicate when the search button is clicked.

// MARK: FilterViewDelegate Optional methods
extension FilterViewDelegate {
  
  func zoom(toDistance: Double) {
    // Empty stub to render it optional so TVC doesn't need to implement it
  }
  
  // TODO: Subclass this to a predicate factory
  // TODO: do a predicate for start & end date only, too in the factory
  /// Feed it parameters and it spits out a predicate the VC can use
  // call updatePredicate from search Button
  func predicate(from quakeParameters: QuakeParameters) -> NSPredicate {
    
    // TODO: Write predicates for these
    
    var predicateArray: [NSPredicate] = []
    
    // start date and end date predicate
    if let startDate = quakeParameters.startDate, let endDate = quakeParameters.endDate {
      // TODO: create predicate, chuck in array
    }
    
    if let startDate = quakeParameters.startDate {
      // TODO: create predicate, chuck in array
    }
    
    // TODO: Don't need to unwrap geographic or magnitude values...just provide default for nil.
    
    // TODO: magnitude predicate
    
    
    // TODO: longitude predicate
    
    
    // TODO: latitude predicate
    
    // zoomFactor value isn't part of the predicate USGS takes.
    
    return NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
    
  }
}

typealias SliderRange = (min: Float, max: Float) // FIXME: delete...

@IBDesignable class FilterView: UIView {
  
  var view: UIView!
  
  weak var delegate: FilterViewDelegate?
  
  var currentParameters: QuakeParameters! {
    didSet {
//      updateSliderValues(with: currentParameters)
//      print(currentParameters)
    }
  }
  
  // TODO: Add IBInspectable properties
  
  @IBInspectable var titleLabelColor: UIColor = UIColor.black {
    didSet {
      updateAppearance()
    }
  }
  
  @IBInspectable var subtitleLabelColor: UIColor = UIColor.darkGray {
    didSet {
      updateAppearance()
    }
  }
  
  @IBInspectable var magStackHidden: Bool = false {
    didSet {
      updateAppearance()
    }
  }
  
  @IBInspectable var latStackHidden: Bool = false {
    didSet {
      updateAppearance()
    }
  }
  
  @IBInspectable var longStackHidden: Bool = false {
    didSet {
      updateAppearance()
    }
  }
  
  @IBInspectable var zoomStackHidden: Bool = false {
    didSet {
      updateAppearance()
    }
  }
  
  @IBInspectable var sliderTintColor = UIColor.blue {
    didSet {
      updateAppearance()
    }
  }
  
  @IBOutlet weak var searchStack: UIStackView!
  
  @IBOutlet weak var startLabelTitle: UILabel!
  @IBOutlet weak var endLabelTitle: UILabel!
  
  // TODO: These need to be updated with a notification
  @IBOutlet weak var startDateLabel: UILabel!
  @IBOutlet weak var endDateLabel: UILabel!
  
  @IBOutlet weak var searchButton: UIButton!
  
  @IBOutlet weak var magnitudeStack: UIStackView!
  @IBOutlet weak var magnitudeLabel: UILabel!
  @IBOutlet weak var magnitudeSlider: RangeSlider!
  @IBOutlet weak var minMagLabel: UILabel!
  @IBOutlet weak var maxMagLabel: UILabel!
  
  @IBOutlet weak var latitudeStack: UIStackView!
  @IBOutlet weak var latitudeLabel: UILabel!
  @IBOutlet weak var latitudeSlider: RangeSlider!
  @IBOutlet weak var minLatLabel: UILabel!
  @IBOutlet weak var maxLatLabel: UILabel!
  
  @IBOutlet weak var longitudeStack: UIStackView!
  @IBOutlet weak var longitudeLabel: UILabel!
  @IBOutlet weak var longitudeSlider: RangeSlider!
  @IBOutlet weak var minLongLabel: UILabel!
  @IBOutlet weak var maxLongLabel: UILabel!
  
  @IBOutlet weak var zoomFactorStack: UIStackView!
  @IBOutlet weak var zoomFactorSlider: UISlider!
  @IBOutlet weak var zoomFactorLabel: UILabel!
  
  
  // MARK: Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    commonInit()
  }
  
  func commonInit() {
    let bundle = Bundle(for: type(of: self))
    let nib = UINib(nibName: "FilterView", bundle: bundle)
    view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    view.frame = bounds
    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    addSubview(view)
    
    currentParameters = QuakeParameters(startDate: Date().startOfDay,
                                        endDate: Date().endOfDay,
                                        minMag: magnitudeSlider.minimumValue,
                                        maxMag: magnitudeSlider.maximumValue,
                                        minLat: latitudeSlider.minimumValue,
                                        maxLat: latitudeSlider.maximumValue,
                                        minLong: longitudeSlider.minimumValue,
                                        maxLong: longitudeSlider.maximumValue)
    
    // Customize appearance
    updateAppearance()
    configureSliders()
  }
  
  func configureSliders() {
    magnitudeSlider.maximumValue = 10
    magnitudeSlider.minimumValue = 0
    minMagLabel.text = GeoStrings.minMag
    maxMagLabel.text = GeoStrings.maxMag
    
    latitudeSlider.minimumValue = -90.0
    latitudeSlider.maximumValue = 90
    minLatLabel.text = GeoStrings.minLat
    maxLatLabel.text = GeoStrings.maxLat
    
    longitudeSlider.minimumValue = -180
    longitudeSlider.maximumValue = 180
    minLatLabel.text = GeoStrings.minLat
    maxLatLabel.text = GeoStrings.maxLat
    
    zoomFactorSlider.minimumValue = 0.0
    zoomFactorSlider.maximumValue = 1_000.00
    
    let rangeSliders = view.subviews.filter{$0 is RangeSlider} as! [RangeSlider]
    rangeSliders.forEach{
//      $0.lowerValue = $0.minimumValue
//      $0.upperValue = $0.maximumValue
      $0.setValue($0.minimumValue, forKey: #keyPath(RangeSlider.lowerValue))
      $0.setValue($0.maximumValue, forKey: #keyPath(RangeSlider.upperValue))
    }
  }
  
  func updateAppearance() {
    
    // Title labels
    [startLabelTitle, endLabelTitle, magnitudeLabel, latitudeLabel, longitudeLabel, zoomFactorLabel].forEach{ titleLabel in
      titleLabel?.textColor = titleLabelColor
    }
    
    // Subtitle Labels
    [startDateLabel, endDateLabel, minMagLabel, maxMagLabel, minLatLabel, maxLatLabel, minLongLabel, maxLongLabel, zoomFactorLabel].forEach{ subtitle in
      subtitle?.textColor = subtitleLabelColor
    }
    
    magnitudeStack.isHidden = magStackHidden
    latitudeStack.isHidden = latStackHidden
    longitudeStack.isHidden = longStackHidden
    zoomFactorStack.isHidden = zoomStackHidden
    
    // colors
    
    // FIXME: perhaps remove this and set tint on the view instead...not familiar with the 3rd party framework, so doing it the "safe way" for now
    searchButton.tintColor = sliderTintColor
    
    [magnitudeSlider, latitudeSlider, longitudeSlider].forEach { customSlider in
      customSlider?.tintColor = sliderTintColor
    }
    
    zoomFactorSlider.tintColor = sliderTintColor // custom slider isn't same class
  }
  
  // MARK: IBActions
  /* These just set the values of the QuakeParameters struct. Search button will do the "work"*/
  @IBAction func magSliderAction(_ sender: RangeSlider) {
    currentParameters.minMag = sender.lowerValue
    currentParameters.maxMag = sender.upperValue
//    diagnose(name: "magSlider", sender: sender)
    // FIXME: Something flakey with this stack
    // gets correct values, but label doesn't update
    minMagLabel.text = String(sender.lowerValue.rounded(.towardZero))
    maxMagLabel.text = String(sender.upperValue.rounded(.towardZero))


  }
  
  @IBAction func latSliderAction(_ sender: RangeSlider) {
    currentParameters.minLat = sender.lowerValue
    currentParameters.maxLat = sender.upperValue
//    diagnose(name: "latSlider", sender: sender)
    minLatLabel.text = String(sender.lowerValue.rounded(.toNearestOrEven))
    maxLatLabel.text = String(sender.upperValue.rounded(.toNearestOrEven))
  }
  
  @IBAction func longSliderAction(_ sender: RangeSlider) {
    currentParameters.minLong = sender.lowerValue
    currentParameters.maxLong = sender.upperValue
//    diagnose(name: "longSlider", sender: sender)
    minLongLabel.text = String(sender.lowerValue.rounded(.toNearestOrEven))
    maxLongLabel.text = String(sender.upperValue.rounded(.toNearestOrEven))
  }
  
  @IBAction func zoomSliderAction(_ sender: UISlider) {
    // MapKit deals in Doubles.
    delegate?.zoom(toDistance: Double(sender.value))
    zoomFactorLabel.text = String(Double(sender.value).rounded(toPlaces: 0)) + " km"
  }
  
  // MARK: Update from results
  
  /// View controllers can update the view for new value
  public func updateSliderValues(with parameters: QuakeParameters) {
    // TODO: This gets called when FRC updates
    // TODO: Write method that grabs "outer boundaries" of [EarthQuakeStruct] to update slider values, which get fed to this. Quake parameters get overwritten
    
//    UIView.animate(withDuration: 0.3) {
//      self.magnitudeSlider.lowerValue = parameters.minMag ?? self.magnitudeSlider.minimumValue
//      self.magnitudeSlider.upperValue = parameters.maxMag ?? self.magnitudeSlider.maximumValue
//      self.minMagLabel.text = parameters.minMag?.asString(roundedTo: 1) ?? GeoStrings.minMag
//      self.maxMagLabel.text = parameters.maxMag?.asString(roundedTo: 1) ?? GeoStrings.maxMag
//
//      self.longitudeSlider.lowerValue = parameters.minLong ?? self.longitudeSlider.minimumValue
//      self.longitudeSlider.upperValue = parameters.maxLong ?? self.longitudeSlider.maximumValue
//      self.minLongLabel.text = parameters.minLong?.asString(roundedTo: 1) ?? GeoStrings.minLong
//      self.maxLongLabel.text = parameters.maxLong?.asString(roundedTo: 1) ?? GeoStrings.maxLong
//
//      self.latitudeSlider.lowerValue = parameters.minLat ?? self.latitudeSlider.minimumValue
//      self.latitudeSlider.maximumValue = parameters.maxLat ?? self.latitudeSlider.maximumValue
//      self.minLatLabel.text = parameters.minLat?.asString(roundedTo: 1) ?? GeoStrings.minLat
//      self.maxLatLabel.text = parameters.maxLat?.asString(roundedTo: 1) ?? GeoStrings.maxLat
//
//      // zoomSlider is controlled by the user. just set min and max scale
//    }
  }
  
  // MARK: Diagnnostic methods
  func diagnose(name: String, sender: RangeSlider) {
    print(name)
    print(sender.lowerValue)
    print(sender.upperValue)
  }
  
  func diagnose(name: String, sender: UISlider) {
    print("\(name) is \(sender.minimumValue), max is \(sender.maximumValue)")
    print("currentValue is \(sender.value)")
  }
}
