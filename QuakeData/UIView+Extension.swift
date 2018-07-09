//
//  UIView+Extension.swift
//  CanvasQuake
//
//  Created by Adrian Bolinger on 6/2/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit

extension UIView {
  func alert(message: String) {
    let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
    let okAction = UIAlertAction(title: "OK", style: .destructive, handler: nil)
    alert.addAction(okAction)
    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
  }
}
