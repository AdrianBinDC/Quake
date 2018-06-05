//
//  CanvasEmptySet.swift
//  CanvasQuake
//
//  Created by Adrian Bolinger on 6/1/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit

@IBDesignable class CanvasEmptySet: UIView {
  
  @IBInspectable var bgColor: UIColor = UIColor.white {
    didSet {
      updateAppearance()
    }
  }
  
  @IBInspectable var borderRadius: CGFloat = 15.0 {
    didSet {
      self.layer.cornerRadius = borderRadius
      self.clipsToBounds = true
    }
  }
  
  private var view: UIView!

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
    let nib = UINib(nibName: "CanvasEmptySet", bundle: bundle)
    view = nib.instantiate(withOwner: self, options: nil).first as! UIView
    view.frame = bounds
    view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    addSubview(view)
    
    // Customize appearance
    updateAppearance()
  }
  
  func updateAppearance() {
    view.backgroundColor = bgColor
    self.layer.cornerRadius = borderRadius
    self.clipsToBounds = true
  }

}
