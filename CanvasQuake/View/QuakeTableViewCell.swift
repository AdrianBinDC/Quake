//
//  QuakeTableViewCell.swift
//  CanvasQuake
//
//  Created by Adrian Bolinger on 5/31/18.
//  Copyright © 2018 Adrian Bolinger. All rights reserved.
//

import UIKit

protocol QuakeTableViewCellDelegate: class {
  func presentWebView(urlString: String)
  func preLoad(urlString: String)
}

class QuakeTableViewCell: UITableViewCell {
  
  var quake: EarthquakeEntity? {
    didSet {
      configureLabels()
    }
  }
  
  // MARK: IBOutlets
  @IBOutlet weak var topStack: UIStackView!
  @IBOutlet weak var bottomStack: UIStackView!
  
  @IBOutlet weak var magLabel: UILabel!
  @IBOutlet weak var timeLabel: UILabel!
  
  @IBOutlet weak var depthLabel: UILabel!
  @IBOutlet weak var placeLabel: UILabel!
  @IBOutlet weak var webButton: UIButton!
  
  weak var delegate: QuakeTableViewCellDelegate?
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    if selected {
      guard let urlString = quake?.url else { return }
      delegate?.preLoad(urlString: urlString)
    }
  }
  
  
  // MARK: Initial configuration
  func configureLabels() {
    
    if let mag = quake?.magnitude {
      magLabel.text = String(format: "%.1f", mag)
    } else {
      magLabel.text = "NA"
    }
    
    if let time = quake?.time {
      timeLabel.text = time.asDateAndTime()
    }
    
    if let depth = quake?.coordinate?.depth {
      depthLabel.text = String(format: "%.1f km", depth)
    }
    
    if let place = quake?.place {
      placeLabel.text = place
    }
  }
  
  // MARK: IBActions
  
  @IBAction func webViewAction(_ sender: UIButton) {
    guard let quakeURL = quake?.url else { return }
    delegate?.presentWebView(urlString: quakeURL)
  }
}









































