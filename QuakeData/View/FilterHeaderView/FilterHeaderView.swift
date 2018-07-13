//
//  FilterHeaderView.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 7/12/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit

@IBDesignable class FilterHeaderView: UIView {
  
  // TODO: update UI, add animations where appropriate
  
  var view: UIView!

  @IBOutlet weak var sectionTitle: UILabel!
  @IBOutlet weak var toggleButton: UIButton!
  
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
    let nib = UINib(nibName: "FilterHeaderView", bundle: bundle)
    view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    view.frame = bounds
    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    addSubview(view)
    
    // Customize appearance
    updateAppearance()
  }
  
  private func updateAppearance() {
    toggleButton.setImage(UIImage(named: "subtract"), for: .selected)
    toggleButton.setImage(UIImage(named: "add"), for: .normal)
  }
  
  @IBAction func toggleButtonAction(_ sender: UIButton) {
    toggleButton.isSelected = !toggleButton.isSelected
  }
  
}
