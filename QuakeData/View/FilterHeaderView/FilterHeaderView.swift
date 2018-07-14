//
//  FilterHeaderView.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 7/14/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit

@IBDesignable class FilterHeaderView: UIView {

  var view: UIView!
  // TODO: Add IBInspectable properties
  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var clearButton: UIButton!
  @IBOutlet weak var labelStack: UIStackView!
  @IBOutlet weak var label: UILabel!
  
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
  
  func updateAppearance() {
    // TODO: Implement as needed
    labelStack.isHidden = true
    label.numberOfLines = 0
    label.lineBreakMode = .byWordWrapping
  }
  
  // MARK: Helpers
  public func updateTextView(with text: String?) {
    UIView.animate(withDuration: 0.3) {
      if let textViewText = text {
        self.label.text = textViewText
        self.label.fadeTransition(0.3)
        self.labelStack.isHidden = false
      } else {
        self.label.text = ""
        self.labelStack.isHidden = true
      }
    }
  }
}
