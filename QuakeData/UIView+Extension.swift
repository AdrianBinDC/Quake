//
//  UIView+Extension.swift
//  QuakeData
//
//  Created by Adrian Bolinger on 7/14/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit

extension UIView {
  func fadeTransition(_ duration:CFTimeInterval) {
    let animation = CATransition()
    animation.timingFunction = CAMediaTimingFunction(name:
      kCAMediaTimingFunctionEaseInEaseOut)
    animation.type = kCATransitionFade
    animation.duration = duration
    layer.add(animation, forKey: kCATransitionFade)
  }
}
