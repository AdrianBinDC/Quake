//
//  FilterFooter.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 7/15/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit
import RangeSeekSlider

protocol FilterFooterDelegate: class {
  func updateMagnitude(minMag: Double, maxMag: Double)
}

@IBDesignable class FilterFooter: UIView {
  
  @IBOutlet weak var slider: RangeSeekSlider!
  
  weak var delegate: FilterFooterDelegate?
  

  var view: UIView!
  // TODO: Add IBInspectable properties
  
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
    let nib = UINib(nibName: "FilterFooter", bundle: bundle)
    view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    view.frame = bounds
    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    addSubview(view)
    
    // Customize appearance
    updateAppearance()
  }
  
  private func updateAppearance() {
    // TODO: Implement
    configureSlider()
  }
  
  fileprivate func configureSlider() {
    slider.numberFormatter.numberStyle = .decimal
    slider.numberFormatter.maximumFractionDigits = 1
    slider.numberFormatter.roundingMode = .down
    slider.numberFormatter.positiveFormat = "0.0"
    slider.delegate = self
  }

}

// MARK: Public API
//extension FilterFooter {
//
////  func updateRegionLabel(countryCount: Int) {
////    regionsSelectedLabel.fadeTransition(0.3)
////    switch countryCount {
////    case 0:
////      regionsSelectedLabel.text = ""
////    case 1:
////      regionsSelectedLabel.text = "One country selected"
////    default:
////      regionsSelectedLabel.text = "\(countryCount) countries selected"
////    }
////  }
//}

// MARK: RangeSeekSliderDelegate

extension FilterFooter: RangeSeekSliderDelegate {
  func rangeSeekSlider(_ slider: RangeSeekSlider, didChange minValue: CGFloat, maxValue: CGFloat) {
    let minMag = slider.selectedMinValue
    let maxMag = slider.selectedMaxValue
    delegate?.updateMagnitude(minMag: Double(minMag), maxMag: Double(maxMag))
  }
}

