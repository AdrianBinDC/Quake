//
//  UIViewController+Extension.swift
//  CanvasQuake
//
//  Created by Adrian Bolinger on 5/31/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit

extension UIViewController {
  var appDelegate: AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
  }
  
  var canvasGradientArray: [Gradient] {
    let gradient1 = (color1: #colorLiteral(red: 0.07058823529, green: 0.5333333333, blue: 0.8666666667, alpha: 1), color2: #colorLiteral(red: 0.07843137255, green: 0.6117647059, blue: 1, alpha: 1))
    let gradient2 = (color1: #colorLiteral(red: 0.07843137255, green: 0.6117647059, blue: 1, alpha: 1), color2: #colorLiteral(red: 0.2431372549, green: 0.6588235294, blue: 0.8980392157, alpha: 1))
    let gradient3 = (color1: #colorLiteral(red: 0.2431372549, green: 0.6588235294, blue: 0.8980392157, alpha: 1), color2: #colorLiteral(red: 0.2666666667, green: 0.7294117647, blue: 1, alpha: 1))
    let gradient4 = (color1: #colorLiteral(red: 0.2666666667, green: 0.7294117647, blue: 1, alpha: 1), color2: #colorLiteral(red: 0.05490196078, green: 0.3921568627, blue: 0.631372549, alpha: 1))
    let gradient5 = (color1: #colorLiteral(red: 0.05490196078, green: 0.3921568627, blue: 0.631372549, alpha: 1), color2: #colorLiteral(red: 0.07058823529, green: 0.5333333333, blue: 0.8666666667, alpha: 1))

    
    return [gradient1, gradient2, gradient3, gradient4, gradient5]
  }
  
  // MARK: Haptic feedback
  // TODO: finish later
  // https://www.hackingwithswift.com/example-code/uikit/how-to-generate-haptic-feedback-with-uifeedbackgenerator
  
  func hapticSelectionChange() {
    let generator = UISelectionFeedbackGenerator()
    generator.selectionChanged()
  }
  
  func hapticFeedback(style: UIImpactFeedbackStyle) {
    let generator = UIImpactFeedbackGenerator(style: style)
    generator.impactOccurred()
  }
}
