//
//  FilterHeaderView.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 7/12/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit

@IBDesignable class FilterSectionHeaderView: UIView {
  
  // TODO: update UI, add animations where appropriate
  
  var view: UIView!

  @IBOutlet weak var sectionTitle: UILabel!
  @IBOutlet weak var selectAllButton: UIButton!
  @IBOutlet weak var expandButton: UIButton!
  
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
    let nib = UINib(nibName: "FilterSectionHeaderView", bundle: bundle)
    view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    view.frame = bounds
    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    addSubview(view)
    
    // Customize appearance
    updateAppearance()
  }
  
  private func updateAppearance() {
    selectAllButton.setTitle("All", for: .normal)
    selectAllButton.setTitle("None", for: .selected)
    
    expandButton.setImage(UIImage(named: "rightArrow"), for: .normal)
    expandButton.setImage(UIImage(named: "downArrow"), for: .selected)
  }
  
  @IBAction func selectAllAction(_ sender: UIButton) {
    selectAllButton.isSelected = !selectAllButton.isSelected
  }
  
  
  @IBAction func expandButtonAction(_ sender: UIButton) {
    expandButton.isSelected = !expandButton.isSelected
  }
  
}
