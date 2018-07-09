//
//  FilterView.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 6/2/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit
import WARangeSlider
import CoreData

// TODO: Set up a notification on the CalendarVC to update start and end date labels
// TODO: Add observer to pick up notifications

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
  func updateZoom(toDistance: Double)
  func updateMagnitude(minMag: Double, maxMag: Double)
  func updateLatitude(minLat: Double, maxLat: Double)
  func updateLongitude(minLong: Double, maxLong: Double)
  func filterButtonTapped()
  
  /*
   Documentation link for configurign distance
   Handle this on the Map Controller
   https://developer.apple.com/documentation/mapkit/1452245-mkcoordinateregionmakewithdistan#
   */
}


// MARK: FilterViewDelegate Optional methods
extension FilterViewDelegate {
  
  func updateZoom(toDistance: Double) {
    // Empty stub to render it optional so TVC doesn't need to implement it
  }
}

@IBDesignable class FilterView: UIView {
  
  var view: UIView!
  
  weak var delegate: FilterViewDelegate?
  
  var currentParameters: QuakeParameters! {
    didSet {
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
  
  @IBOutlet weak var filterButton: UIButton!
  
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
  @IBOutlet weak var zoomSlider: UISlider!
  @IBOutlet weak var zoomSliderLabel: UILabel!
  
  // This is just to keep track within the class
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
  
  private func commonInit() {
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
  
  private func configureSliders() {
    magnitudeSlider.maximumValue = 10
    magnitudeSlider.minimumValue = 0
    magnitudeSlider.upperValue = 10 // FIXME: bug in framework code, update
    magnitudeSlider.lowerValue = 0 // FIXME: bug in framework code, update
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
    
    startDateLabel.text = Date().asDate()
    endDateLabel.text = Date().asDate()
    
    // ** set the zoom with the method below.
    
    let rangeSliders = view.subviews.filter{$0 is RangeSlider} as! [RangeSlider]
    rangeSliders.forEach{
      $0.lowerValue = $0.minimumValue
      $0.upperValue = $0.maximumValue
    }
  }
  
  private func updateAppearance() {
    
    // Title labels
    [startLabelTitle, endLabelTitle, magnitudeLabel, latitudeLabel, longitudeLabel, zoomSliderLabel].forEach{ titleLabel in
      titleLabel?.textColor = titleLabelColor
    }
    
    // Subtitle Labels
    [startDateLabel, endDateLabel, minMagLabel, maxMagLabel, minLatLabel, maxLatLabel, minLongLabel, maxLongLabel, zoomSliderLabel].forEach{ subtitle in
      subtitle?.textColor = subtitleLabelColor
    }
    
    magnitudeStack.isHidden = magStackHidden
    latitudeStack.isHidden = latStackHidden
    longitudeStack.isHidden = longStackHidden
    zoomFactorStack.isHidden = zoomStackHidden
    
    // colors
    
    // FIXME: perhaps remove this and set tint on the view instead...not familiar with the 3rd party framework, so doing it the "safe way" for now
    filterButton.tintColor = sliderTintColor
    
    [magnitudeSlider, latitudeSlider, longitudeSlider].forEach { customSlider in
      customSlider?.tintColor = sliderTintColor
    }
    
    zoomSlider.tintColor = sliderTintColor // custom slider isn't same class
  }
  
  public func setDate(startDate: Date, endDate: Date) {
    self.startDateLabel.text = startDate.asDate()
    self.endDateLabel.text = endDate.asDate()
  }
  
  public func setZoom(min: Double, max: Double, value: Double) {
    zoomSlider.minimumValue = Float(min)
    zoomSlider.maximumValue = Float(max)
    zoomSlider.value = Float(value)
    zoomSliderLabel.text = String(Double(value).rounded(toPlaces: 0)) + " km"
  }
  
  // MARK: IBActions
  
  @IBAction func filterButtonAction(_ sender: UIButton) {
    delegate?.filterButtonTapped()
  }
  
  /* These just set the values of the QuakeParameters struct. Search button will do the "work"*/
  @IBAction private func magSliderAction(_ sender: RangeSlider) {
    currentParameters.minMag = sender.lowerValue
    currentParameters.maxMag = sender.upperValue
//    diagnose(name: "magSlider", sender: sender)
    // FIXME: Something flakey with this stack
    // gets correct values, but label doesn't update
    minMagLabel.text = String(sender.lowerValue.rounded(.towardZero))
    maxMagLabel.text = String(sender.upperValue.rounded(.towardZero))
    
    delegate?.updateMagnitude(minMag: sender.lowerValue, maxMag: sender.upperValue)
  }
  
  @IBAction private func latSliderAction(_ sender: RangeSlider) {
    currentParameters.minLat = sender.lowerValue
    currentParameters.maxLat = sender.upperValue
//    diagnose(name: "latSlider", sender: sender)
    minLatLabel.text = String(sender.lowerValue.rounded(.toNearestOrEven))
    maxLatLabel.text = String(sender.upperValue.rounded(.toNearestOrEven))
    
    delegate?.updateLatitude(minLat: sender.lowerValue, maxLat: sender.upperValue)
  }
  
  @IBAction private func longSliderAction(_ sender: RangeSlider) {
    currentParameters.minLong = sender.lowerValue
    currentParameters.maxLong = sender.upperValue
//    diagnose(name: "longSlider", sender: sender)
    minLongLabel.text = String(sender.lowerValue.rounded(.toNearestOrEven))
    maxLongLabel.text = String(sender.upperValue.rounded(.toNearestOrEven))
    
    delegate?.updateLongitude(minLong: sender.lowerValue, maxLong: sender.upperValue)
  }
  
  @IBAction private func zoomSliderAction(_ sender: UISlider) {
    // MapKit deals in Doubles.
    delegate?.updateZoom(toDistance: Double(sender.value))
    zoomSliderLabel.text = String(Double(sender.value).rounded(toPlaces: 0)) + " km"
    
    delegate?.updateZoom(toDistance: Double(sender.value))
  }
  
  // MARK: Diagnnostic methods
  private func diagnose(name: String, sender: RangeSlider) {
    print(name)
    print(sender.lowerValue)
    print(sender.upperValue)
  }
  
  private func diagnose(name: String, sender: UISlider) {
    print("\(name) is \(sender.minimumValue), max is \(sender.maximumValue)")
    print("currentValue is \(sender.value)")
  }
}
