//
//  QuakeFooter.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 7/16/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit

@IBDesignable class QuakeFooter: UIView {
  
  var view: UIView!
  // TODO: Add IBInspectable properties
  
  @IBOutlet weak var searchLabel: UILabel!
  
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
    let nib = UINib(nibName: "QuakeFooter", bundle: bundle)
    view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    view.frame = bounds
    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    addSubview(view)
    
    // Customize appearance
    updateAppearance()
  }
  
  private func updateAppearance() {
    // TODO: Implement
    if let text = searchLabel.text?.isEmpty {
      searchLabel.alpha = 1
    } else {
      searchLabel.alpha = 0
    }
  }
}

extension QuakeFooter {
  func setLabel(text: String?) {
    guard let text = text else {
      searchLabel.alpha = 0
      return
    }
    UIView.animate(withDuration: 0.3, animations: {
      self.searchLabel.alpha = 1.0
    }) { _ in
      self.searchLabel.fadeTransition(0.3)
      self.searchLabel.text = text
    }
  }
}
