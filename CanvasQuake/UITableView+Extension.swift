//
//  UITableView+Extension.swift
//  CanvasQuake
//
//  Created by Adrian Bolinger on 6/6/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit

extension UITableView {
  func indexPathForView(_ view: UIView) -> IndexPath? {
    let center = view.center
    let viewCenter = self.convert(center, from: view.superview)
    let indexPath = self.indexPathForRow(at: viewCenter)
    return indexPath
  }
}
